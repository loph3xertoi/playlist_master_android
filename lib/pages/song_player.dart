import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:playlistmaster/entities/song.dart';
import 'package:playlistmaster/states/app_state.dart';
import 'package:playlistmaster/third_lib_change/just_audio/common.dart';
import 'package:playlistmaster/third_lib_change/like_button/like_button.dart';
import 'package:playlistmaster/widgets/create_queue_popup.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SongPlayerPage extends StatefulWidget {
  final bool isPlaying;
  const SongPlayerPage({
    super.key,
    required this.isPlaying,
  });

  @override
  State<SongPlayerPage> createState() => _SongPlayerPageState();
}

class _SongPlayerPageState extends State<SongPlayerPage> {
  // MyAppState _appState = context.watch<MyAppState>();;
  late MyAppState _appState;

  late AudioPlayer _player;

  // Global playing mode, 0 for shuffle, 1 for repeat, 2 for repeat one.
  // 0 as default for the first using.
  late int _userPlayingMode;

  late int _currentSongIndex;

  CarouselController _carouselController = CarouselController();

  // Define the queue
  late ConcatenatingAudioSource _initQueue;

  // Songs of current queue.
  late List<Song>? _queue;

  // Previous queue for delete.
  late List<Song>? _originQueue;

  // Default volume.
  late double? _defaultVolume;

  // Default speed.
  late double? _defaultSpeed;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);

    _currentSongIndex = state.currentPlayingSongInQueue;
    _userPlayingMode = state.userPlayingMode;
    _queue = state.songsOfPlaylist;
    _originQueue = List.from(_queue!);
    _defaultVolume = state.volume;
    _defaultSpeed = state.speed;
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    _player = AudioPlayer();
    // Listen to errors during playback.
    _player.playbackEventStream.listen(
      (event) {
        bool skip = false;
        if (_queue!.length != _originQueue!.length && _queue!.isNotEmpty) {
          for (int i = 0; i < _originQueue!.length; i++) {
            if (!_queue!.contains(_originQueue![i])) {
              _initQueue.removeAt(i);
              _originQueue!.removeAt(i);
              // if (i <= _currentSongIndex) {
              //   // TODO: fix bug: when call _initQueue.removeAt(i); the _currentSongIndex
              //   // will be subtracted one more time.
              //   // _player.seek(Duration.zero, index: _currentSongIndex);
              //   skip = true;
              //   return;
              // }
              break;
            }
          }
        }
        if (event.currentIndex != null &&
            event.currentIndex != _currentSongIndex &&
            event.currentIndex! < _queue!.length &&
            true) {
          _currentSongIndex = event.currentIndex!;

          _carouselController.jumpToPage(_currentSongIndex);
          Future.delayed(Duration(milliseconds: 300), () {
            _appState.currentPlayingSongInQueue = _currentSongIndex;
          });

          if (_userPlayingMode == 0) {
            // _player.shuffle();
            // _player.seek(Duration.zero, index: _player.effectiveIndices?[0]);
          }

          setState(() {});
        }
      },
      onError: (Object e, StackTrace stackTrace) {
        print('A stream error occurred: $e');
      },
    );

    // Try to load audio from a source and catch any errors.
    try {
      // AAC example: https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.aac
      // await _player.setAudioSource(AudioSource.uri(Uri.parse(
      //     "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3")));
      // await _player.setAsset('assets/audios/parrot.mp3');
      _initQueue = ConcatenatingAudioSource(
        // Start loading next item just before reaching it
        useLazyPreparation: true,
        // Customise the shuffle algorithm
        shuffleOrder: DefaultShuffleOrder(),
        // Specify the queue items
        children: _queue!
            .map(
              (e) => AudioSource.asset(e.link),
            )
            .toList(),
      );
      await _player.setAudioSource(_initQueue,
          initialIndex: _currentSongIndex, initialPosition: Duration.zero);

      // Set the playing mode of the player.
      if (_userPlayingMode == 0) {
        await _player.setShuffleModeEnabled(true);
        await _player.setLoopMode(LoopMode.all);
      } else if (_userPlayingMode == 1) {
        await _player.setShuffleModeEnabled(false);
        await _player.setLoopMode(LoopMode.all);
      } else if (_userPlayingMode == 2) {
        await _player.setShuffleModeEnabled(false);
        await _player.setLoopMode(LoopMode.one);
      } else {
        throw Exception('Invalid playing mode');
      }

      // Set the volume.
      await _player.setVolume(_defaultVolume!);

      // Set the speed.
      await _player.setSpeed(_defaultSpeed!);

      if (widget.isPlaying) await _player.play();
    } catch (e) {
      print("Error init audio player: $e");
    }
  }

  @override
  void dispose() {
    // Release decoders and buffers back to the operating system making them
    // available for other apps to use.
    _player.dispose();
    super.dispose();
  }

  /// Collects the data useful for displaying in a seek bar, using a handy
  /// feature of rx_dart to combine the 3 streams of interest into one.
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    setState(() {
      _appState = appState;
    });

    _queue = appState.queue;
    if (_queue!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Pop the song player page.
        Navigator.of(context).pop();
      });
    }
    appState.addListener(() {
      if (mounted && appState.currentPlayingSongInQueue != _currentSongIndex) {
        _currentSongIndex = appState.currentPlayingSongInQueue;
        Future.delayed(Duration(milliseconds: 0), () {
          _player.seek(Duration.zero, index: _currentSongIndex);
          _carouselController.jumpToPage(appState.currentPlayingSongInQueue);
          if (!_player.playerState.playing) {
            _player.play();
          }
        });
        setState(() {});
      }
      if (mounted && appState.isPlaying != _player.playerState.playing) {
        appState.isPlaying = _player.playerState.playing;
      }
    });

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF011934),
            Color(0xFF092B47),
            Color(0xFF142B41),
            Color(0xFF393747),
          ],
          stops: [0.0, 0.33, 0.67, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Container(
              height: 75.0,
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                height: 42.0,
                child: Row(children: [
                  IconButton(
                    color: Color(0xE5FFFFFF),
                    icon: Icon(Icons.arrow_back_rounded),
                    onPressed: () {
                      _appState.initSongPlayer = true;
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Text(
                            _queue!.isNotEmpty
                                ? _queue![_currentSongIndex].name
                                : '',
                            style: TextStyle(
                              color: Color(0xE5FFFFFF),
                              fontFamily: 'Roboto',
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        Text(
                          _queue!.isNotEmpty
                              ? _queue![_currentSongIndex].singers[0].name
                              : '',
                          style: TextStyle(
                            color: Color(0x80FFFFFF),
                            fontFamily: 'Roboto',
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    color: Color(0xE5FFFFFF),
                    icon: Icon(Icons.share_rounded),
                    onPressed: () {},
                  ),
                ]),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                height: 250.0,
                width: double.infinity,
                child: CarouselSlider.builder(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    initialPage: _currentSongIndex,
                    aspectRatio: 1.0,
                    viewportFraction: _userPlayingMode == 0 ? 0.8 : 0.6,
                    enlargeCenterPage: true,
                    onPageChanged: (index, reason) {
                      if (reason == CarouselPageChangedReason.manual) {
                        Future.delayed(Duration(milliseconds: 300), () {
                          _player.seek(Duration.zero,
                              index: _player.effectiveIndices![index]);
                          if (!_player.playerState.playing) {
                            _player.play();
                          }
                        });
                      }
                    },
                    onScrolled: (position) {
                      // print(position);
                    },
                    // enlargeStrategy: CenterPageEnlargeStrategy.scale,
                    enlargeFactor: 0.45,
                  ),
                  // items: imageSliders,
                  itemBuilder:
                      (BuildContext context, int itemIndex, int pageViewIndex) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        top: 10.0,
                        bottom: 10.0,
                      ),
                      child: Container(
                        width: 230.0,
                        height: 230.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x40000000),
                              spreadRadius: 0.0,
                              blurRadius: 4.0,
                              offset: Offset(
                                  0.0, 4.0), // changes position of shadow
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.all(Radius.circular(150.0)),
                          child: Image.asset(
                            // (_userPlayingMode ==0)?
                            // songsOfPlaylist[itemIndex].coverUri
                            _queue!.isNotEmpty
                                ? _queue![itemIndex].coverUri
                                : 'assets/images/songs_cover/tit.jpeg',
                            fit: BoxFit.fitHeight,
                            height: 230.0,
                            width: 230.0,
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: _queue!.length,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
            ),
            child: SizedBox(
              height: 50.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    color: Color(0xE5FFFFFF),
                    icon: Icon(Icons.volume_up_rounded),
                    onPressed: () {
                      showSliderDialog(
                        context: context,
                        title: "Adjust volume",
                        divisions: 10,
                        min: 0.0,
                        max: 2.0,
                        value: _appState.volume ?? 1.0,
                        stream: _player.volumeStream,
                        onChanged: (volume) {
                          _player.setVolume(volume);
                          _appState.volume = volume;
                          _defaultVolume = volume;
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: Text(
                      '${_appState.speed?.toStringAsFixed(1) ?? 1.0}x',
                      style: const TextStyle(
                        color: Color(0xE5FFFFFF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      showSliderDialog(
                        context: context,
                        title: "Adjust speed",
                        divisions: 99,
                        min: 0.1,
                        max: 10.0,
                        value: _appState.speed ?? 1.0,
                        stream: _player.speedStream,
                        onChanged: (speed) {
                          _player.setSpeed(speed);
                          _appState.speed = speed;
                          _defaultSpeed = speed;
                        },
                      );
                    },
                  ),
                  SizedBox(
                    width: 50.0,
                    child: LikeButton(
                      size: 24.0,
                      isLiked: false,
                      iconColor: Color(0xE5FFFFFF),
                    ),
                  ),
                  IconButton(
                    color: Color(0xE5FFFFFF),
                    icon: Icon(Icons.download_rounded),
                    onPressed: () {
                      print(appState);
                      print(_queue);
                      setState(() {});
                    },
                  ),
                  IconButton(
                    color: Color(0xE5FFFFFF),
                    icon: Icon(Icons.more_vert_rounded),
                    onPressed: () {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),

          // Display seek bar.
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 30.0,
            ),
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                height: 30.0,
                child: StreamBuilder<PositionData>(
                  stream: _positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data;
                    return SeekBar(
                      duration: positionData?.duration ?? Duration.zero,
                      position: positionData?.position ?? Duration.zero,
                      bufferedPosition:
                          positionData?.bufferedPosition ?? Duration.zero,
                      onChangeEnd: _player.seek,
                    );
                  },
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 22.0),
            child: SizedBox(
              height: 50.0,
              child: Row(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: Builder(
                      builder: (context) {
                        if (_userPlayingMode == 0) {
                          print('hello');
                          return IconButton(
                            icon: const Icon(Icons.shuffle_rounded),
                            color: Color(0xE5FFFFFF),
                            onPressed: () {
                              setState(() {
                                _userPlayingMode = 1;
                                _appState.userPlayingMode = _userPlayingMode;
                              });
                              _player.setShuffleModeEnabled(false);
                              _player.setLoopMode(LoopMode.all);
                            },
                          );
                        } else if (_userPlayingMode == 1) {
                          return IconButton(
                            icon: const Icon(Icons.repeat_rounded),
                            color: Color(0xE5FFFFFF),
                            onPressed: () {
                              setState(() {
                                _userPlayingMode = 2;
                                _appState.userPlayingMode = _userPlayingMode;
                              });
                              _player.setShuffleModeEnabled(false);
                              _player.setLoopMode(LoopMode.one);
                            },
                          );
                        } else if (_userPlayingMode == 2) {
                          return IconButton(
                            icon: const Icon(Icons.repeat_one_rounded),
                            color: Color(0xE5FFFFFF),
                            onPressed: () {
                              setState(() {
                                _userPlayingMode = 0;
                                _appState.userPlayingMode = _userPlayingMode;
                              });
                              _player.setShuffleModeEnabled(true);
                              _player.shuffle();
                              _player.setLoopMode(LoopMode.all);
                            },
                          );
                        } else {
                          throw Exception('Invalid user playing mode.');
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded),
                    color: Color(0xE5FFFFFF),
                    onPressed: () {
                      _player.seekToPrevious();
                      if (!_player.playerState.playing) {
                        _player.play();
                      }
                    },
                  ),
                  Material(
                    color: Colors.transparent,
                    child: Center(
                      child: StreamBuilder<PlayerState>(
                        stream: _player.playerStateStream,
                        builder: (context, snapshot) {
                          final playerState = snapshot.data;
                          final processingState = playerState?.processingState;
                          final playing = playerState?.playing;
                          if (processingState == ProcessingState.loading ||
                              processingState == ProcessingState.buffering) {
                            return SizedBox(
                              // margin: const EdgeInsets.all(10.0),
                              width: 50.0,
                              height: 50.0,
                              child: const CircularProgressIndicator(),
                            );
                          } else if (playing != true) {
                            return IconButton(
                              padding: EdgeInsets.zero,
                              icon:
                                  const Icon(Icons.play_circle_outline_rounded),
                              iconSize: 50.0,
                              color: Color(0xE5FFFFFF),
                              onPressed: _player.play,
                            );
                          } else if (processingState !=
                              ProcessingState.completed) {
                            return IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                  Icons.pause_circle_outline_rounded),
                              iconSize: 50.0,
                              color: Color(0xE5FFFFFF),
                              onPressed: _player.pause,
                            );
                          } else {
                            return IconButton(
                              icon: const Icon(Icons.replay_rounded),
                              iconSize: 40.0,
                              color: Color(0xE5FFFFFF),
                              onPressed: () => _player.seek(Duration.zero),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded),
                    color: Color(0xE5FFFFFF),
                    onPressed: () {
                      _player.seekToNext();
                      if (!_player.playerState.playing) {
                        _player.play();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.queue_music_rounded),
                    color: Color(0xE5FFFFFF),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => ShowQueueDialog(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
