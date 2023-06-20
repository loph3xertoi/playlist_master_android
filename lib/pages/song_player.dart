import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:playlistmaster/entities/song.dart';
import 'package:playlistmaster/mock_data.dart';
import 'package:playlistmaster/third_lib_change/just_audio/common.dart';
import 'package:playlistmaster/widgets/create_queue_popup.dart';
import 'package:rxdart/rxdart.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SongPlayerPage extends StatefulWidget {
  const SongPlayerPage({super.key});

  @override
  State<SongPlayerPage> createState() => _SongPlayerPageState();
}

class _SongPlayerPageState extends State<SongPlayerPage>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  late AnimationController _controller;
  // Global playing mode, 0 for shuffle, 1 for repeat, 2 for repeat one.
  // 0 as default for the first using.
  int _userPlayingMode = 0;
  late int _currentSong;

  // Define the queue
  late final ConcatenatingAudioSource queue;

  // Songs of current playlist.
  late List<Song> songsOfPlaylist;

  // Index of selected song.
  late int indexOfSelectedSong;

  late final Map<String, dynamic> args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    indexOfSelectedSong = args['index'];
    _currentSong = indexOfSelectedSong;
    songsOfPlaylist = args['songs'];
    _init();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      // lowerBound: 0.5,
      duration: const Duration(seconds: 5),
    );
  }

  Future<void> _init() async {
    _player = AudioPlayer();

    // Listen to errors during playback.
    _player.playbackEventStream.listen(
      (event) {
        if (event.currentIndex != null && event.currentIndex != _currentSong) {
          setState(() {
            _currentSong = event.currentIndex!;
          });
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
      queue = ConcatenatingAudioSource(
        // Start loading next item just before reaching it
        useLazyPreparation: true,
        // Customise the shuffle algorithm
        shuffleOrder: DefaultShuffleOrder(),
        // Specify the queue items
        children: songsOfPlaylist
            .map(
              (e) => AudioSource.asset(e.link),
            )
            .toList(),
      );
      await _player.setAudioSource(queue,
          initialIndex: indexOfSelectedSong, initialPosition: Duration.zero);
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
    } catch (e) {
      print("Error init audio player: $e");
    }
  }

  @override
  void dispose() {
    // Release decoders and buffers back to the operating system making them
    // available for other apps to use.
    _controller.dispose();
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Color(0xE5FFFFFF),
                    icon: Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Text(
                            songsOfPlaylist[_currentSong].name,
                            style: TextStyle(
                              color: Color(0xE5FFFFFF),
                              fontFamily: 'Roboto',
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        Text(
                          songsOfPlaylist[_currentSong].singers[0].name,
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
                    onPressed: () {},
                    color: Color(0xE5FFFFFF),
                    icon: Icon(Icons.share_rounded),
                  ),
                ]),
              ),
            ),
          ),
          Expanded(
            child: Center(),
            //   child: AnimatedBuilder(
            //     animation: _controller,
            //     builder: (BuildContext context, Widget? child) {
            //       return Stack(
            //         alignment: Alignment.center,
            //         children: [
            //           // Positioned(
            //           //   bottom: -20,
            //           //   right: 0,
            //           //   left: 0,
            //           //   child: Transform.translate(
            //           //     offset: Offset(50 * _controller.value, 0),
            //           //     child: Opacity(
            //           //       opacity: val ? 0.0 : 0.8,
            //           //       child: Image.asset(
            //           //         'assets/images/cloud2.png',
            //           //         fit: BoxFit.cover,
            //           //       ),
            //           //     ),
            //           //   ),
            //           // ),
            //           // Positioned(
            //           //   bottom: -20,
            //           //   right: 0,
            //           //   left: 0,
            //           //   child: Transform.translate(
            //           //     offset: Offset(100 * _controller.value, 0),
            //           //     child: Opacity(
            //           //       opacity: val ? 0.0 : 0.4,
            //           //       child: Image.asset(
            //           //         'assets/images/cloud3.png',
            //           //         fit: BoxFit.cover,
            //           //       ),
            //           //     ),
            //           //   ),
            //           // ),
            //           Positioned(
            //             left: -272.0,
            //             width: 155.0,
            //             height: 155.0,
            //             child: Transform.translate(
            //               offset: Offset(166.0 * _controller.value, 0),
            //               child: SizedBox(
            //                 width: 155.0,
            //                 height: 155.0,
            //                 child: ClipOval(
            //                   child: Image.asset(
            //                       'assets/images/songs_cover/owl.png'),
            //                 ),
            //               ),
            //             ),
            //           ),
            //           Positioned(
            //             left: -106.0,
            //             width: 155.0,
            //             height: 155.0,
            //             child: SizedBox(
            //               width: 155.0,
            //               height: 155.0,
            //               child: ClipOval(
            //                 child: Image.asset(
            //                     'assets/images/songs_cover/parrot.png'),
            //               ),
            //             ),
            //           ),
            //           Positioned(
            //             width: 240.0,
            //             height: 240.0,
            //             child: Transform.translate(
            //               offset: Offset(50 * _controller.value, 0),
            //               child: SizedBox(
            //                 width: 240.0,
            //                 height: 240.0,
            //                 child: ClipOval(
            //                   child: Image.asset(
            //                       'assets/images/songs_cover/tit.png'),
            //                 ),
            //               ),
            //             ),
            //           ),
            //           Positioned(
            //             right: -106.0,
            //             width: 155.0,
            //             height: 155.0,
            //             child: SizedBox(
            //               width: 155.0,
            //               height: 155.0,
            //               child: ClipOval(
            //                 child: Image.asset(
            //                     'assets/images/songs_cover/owl.png'),
            //               ),
            //             ),
            //           ),
            //           Positioned(
            //             right: -272.0,
            //             width: 155.0,
            //             height: 155.0,
            //             child: SizedBox(
            //               width: 155.0,
            //               height: 155.0,
            //               child: ClipOval(
            //                 child: Image.asset(
            //                     'assets/images/songs_cover/parrot.png'),
            //               ),
            //             ),
            //           ),
            //         ],
            //       );
            //     },
            //   ),
            // ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 91.0,
            ),
            child: SizedBox(
              height: 40.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {},
                    color: Color(0xE5FFFFFF),
                    icon: Icon(Icons.favorite_outline_rounded),
                  ),
                  IconButton(
                    onPressed: () {},
                    color: Color(0xE5FFFFFF),
                    icon: Icon(Icons.download_rounded),
                  ),
                  IconButton(
                    onPressed: () {},
                    color: Color(0xE5FFFFFF),
                    icon: Icon(Icons.more_vert_rounded),
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
                    if (_userPlayingMode == 0 &&
                        _player.currentIndex == _player.shuffleIndices?.last &&
                        _player.position.inSeconds ==
                            _player.duration?.inSeconds) {
                      _player.shuffle();
                    }
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
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 22.0),
          //   child: SizedBox(
          //     height: 50.0,
          //     child: Row(
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         // Opens volume slider dialog
          //         IconButton(
          //           icon: const Icon(Icons.volume_up),
          //           onPressed: () {
          //             showSliderDialog(
          //               context: context,
          //               title: "Adjust volume",
          //               divisions: 10,
          //               min: 0.0,
          //               max: 1.0,
          //               value: _player.volume,
          //               stream: _player.volumeStream,
          //               onChanged: _player.setVolume,
          //             );
          //           },
          //         ),

          //         /// This StreamBuilder rebuilds whenever the player state changes, which
          //         /// includes the playing/paused state and also the
          //         /// loading/buffering/ready state. Depending on the state we show the
          //         /// appropriate button or loading indicator.
          //         Material(
          //           child: StreamBuilder<PlayerState>(
          //             stream: _player.playerStateStream,
          //             builder: (context, snapshot) {
          //               final playerState = snapshot.data;
          //               final processingState = playerState?.processingState;
          //               final playing = playerState?.playing;
          //               if (processingState == ProcessingState.loading ||
          //                   processingState == ProcessingState.buffering) {
          //                 return Container(
          //                   margin: const EdgeInsets.all(8.0),
          //                   width: 64.0,
          //                   height: 64.0,
          //                   child: const CircularProgressIndicator(),
          //                 );
          //               } else if (playing != true) {
          //                 return IconButton(
          //                   icon: const Icon(Icons.play_arrow),
          //                   iconSize: 64.0,
          //                   onPressed: _player.play,
          //                 );
          //               } else if (processingState !=
          //                   ProcessingState.completed) {
          //                 return IconButton(
          //                   icon: const Icon(Icons.pause),
          //                   iconSize: 64.0,
          //                   onPressed: _player.pause,
          //                 );
          //               } else {
          //                 return IconButton(
          //                   icon: const Icon(Icons.replay),
          //                   iconSize: 64.0,
          //                   onPressed: () => _player.seek(Duration.zero),
          //                 );
          //               }
          //             },
          //           ),
          //         ),
          //         // Opens speed slider dialog
          //         StreamBuilder<double>(
          //           stream: _player.speedStream,
          //           builder: (context, snapshot) => IconButton(
          //             icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
          //                 style: const TextStyle(fontWeight: FontWeight.bold)),
          //             onPressed: () {
          //               showSliderDialog(
          //                 context: context,
          //                 title: "Adjust speed",
          //                 divisions: 10,
          //                 min: 0.5,
          //                 max: 1.5,
          //                 value: _player.speed,
          //                 stream: _player.speedStream,
          //                 onChanged: _player.setSpeed,
          //               );
          //             },
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

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
                    // onPressed: _player.seekToPrevious,
                    onPressed: () {
                      _controller.value = 0.0;
                      // ..value = 1.0
                      // ..reverse(from: 1.0);
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
                      _controller
                        ..value = 0.0
                        ..forward(from: 0.0);
                      // _player.seekToNext();
                      // print(
                      //     'daw=====${_player.currentIndex}=========${_player.nextIndex}=====');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.queue_music_rounded),
                    color: Color(0xE5FFFFFF),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (_) =>
                              ShowQueueDialog(songsQueue: MockData.songs));
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
