import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:just_audio/just_audio.dart';
import 'package:playlistmaster/mock_data.dart';
import 'package:playlistmaster/states/app_state.dart';
import 'package:playlistmaster/third_lib_change/just_audio/common.dart';
import 'package:playlistmaster/third_lib_change/like_button/like_button.dart';
import 'package:playlistmaster/widgets/create_queue_popup.dart';
import 'package:playlistmaster/widgets/create_songplayer_menu_popup.dart';
import 'package:playlistmaster/widgets/my_lyrics_displayer.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SongPlayerPage extends StatefulWidget {
  const SongPlayerPage({super.key});

  @override
  State<SongPlayerPage> createState() => _SongPlayerPageState();
}

class _SongPlayerPageState extends State<SongPlayerPage>
    with SingleTickerProviderStateMixin {
  // MyAppState _appState = context.watch<MyAppState>();;
  // late MyAppState _appState;

  // late AudioPlayer _player;

  // Global playing mode, 0 for shuffle, 1 for repeat, 2 for repeat one.
  // 0 as default for the first using.
  // late int _userPlayingMode;

  // late int _currentSongIndex;

  // CarouselController _carouselController = CarouselController();

  // Songs of current queue.
  // late List<Song>? _queue;

  // Default volume.
  // late double? _defaultVolume;

  // Default speed.
  // late double? _defaultSpeed;

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   // final state = Provider.of<MyAppState>(context, listen: false);

  //   // _currentSongIndex = state.currentPlayingSongInQueue;
  //   // _userPlayingMode = state.userPlayingMode;
  //   // _queue = state.songsOfPlaylist;

  //   // _defaultVolume = state.volume;
  //   // _defaultSpeed = state.speed;
  //   // _initAudioPlayer();
  // }

  // @override
  // void dispose() {
  //   // Release decoders and buffers back to the operating system making them
  //   // available for other apps to use.
  //   // _player.dispose();
  //   super.dispose();
  // }
  late AnimationController _controller;
  late Animation<double> _songCoverRotateAnimation;
  bool _isFirstLoadSongPlayer = false;
  bool _toggleLyrics = false;
  bool _isPlaying = false;
  int _prevSongIndex = 0;
  // int _playProgress = 0;
  // bool _oldPlayingState = false;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    );
    _songCoverRotateAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();

    var player = appState.player;
    var queue = appState.queue;
    var currentPlayingSongInQueue = appState.currentPlayingSongInQueue;
    var currentSong = appState.currentSong;
    var userPlayingMode = appState.userPlayingMode;
    var volume = appState.volume;
    var speed = appState.speed;
    var positionDataStream = appState.positionDataStream;
    var carouselController = appState.carouselController;
    _isFirstLoadSongPlayer = appState.isFirstLoadSongPlayer;
    _isPlaying = appState.isPlaying;

    // playProgress = appState.playProgress ?? 0;
    if (_isFirstLoadSongPlayer) {
      player!.seek(Duration.zero, index: currentPlayingSongInQueue);
      _controller.repeat();
    }
    if ((queue?.isNotEmpty ?? false) &&
        (queue!.length > currentPlayingSongInQueue!) &&
        (currentSong!.name != queue[currentPlayingSongInQueue].name)) {
      _controller.reset();
    }
    // player?.stream.listen((event) {

    // });

    if (queue?.isEmpty ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (appState.canSongPlayerPagePop) {
          Navigator.of(context).pop();
          appState.isPlayerPageOpened = false;
          appState.canSongPlayerPagePop = false;
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((queue?.isNotEmpty ?? false) &&
          (currentSong!.name != queue?[currentPlayingSongInQueue!].name)) {
        appState.currentSong = queue?[currentPlayingSongInQueue!];
      }

      if (!_isFirstLoadSongPlayer) {
        if (player != null && player.playing == true) {
          _controller.repeat();
        } else {
          _controller.stop();
        }
      } else {
        Future.delayed(Duration(milliseconds: 200), () {
          appState.isFirstLoadSongPlayer = false;
          // appState.coverRotatingController = _controller;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_prevSongIndex != currentPlayingSongInQueue) {
        // carouselController.
        carouselController.jumpToPage(currentPlayingSongInQueue!);
        _prevSongIndex = currentPlayingSongInQueue;
      }
      //   player!.positionStream.listen((event) {
      //     setState(() {
      //       sliderProgress = event.inMilliseconds.toDouble();
      //       playProgress = event.inMilliseconds;
      //     });
      //   });
      //   player.durationStream.listen((event) {
      //     setState(() {
      //       max_value = event!.inMilliseconds.toDouble();
      //     });
      //   });
    });
    print(appState);

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
                      // _appState.initSongPlayer = true;
                      appState.isPlayerPageOpened = false;
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Text(
                            (queue?.isNotEmpty ?? false)
                                ? (queue![currentPlayingSongInQueue!].name)
                                : '',
                            style: TextStyle(
                              color: Color(0xE5FFFFFF),
                              fontFamily: 'Roboto',
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        Text(
                          (queue?.isNotEmpty ?? false)
                              ? (queue![currentPlayingSongInQueue!]
                                  .singers[0]
                                  .name)
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
                    onPressed: () {
                      // player
                      //     ?.createPositionStream(
                      //       steps: 2000,
                      //   minPeriod: Duration(milliseconds: 10),
                      //   maxPeriod: Duration(milliseconds: 10),
                      // )
                      //     .listen((event) {
                      //   setState(() {
                      //     playProgress = event.inMilliseconds;
                      //   });
                      // });
                      // _controller.repeat();
                      print(appState);
                      print('lyrics: $playProgress');
                      print('song: ${player!.position.inMilliseconds}');
                      print(
                          'diff: ${playProgress - player.position.inMilliseconds}');
                      setState(() {});
                      // print(max_value);
                    },
                  ),
                ]),
              ),
            ),
          ),
          Expanded(
            child: Stack(alignment: AlignmentDirectional.topCenter, children: [
              Positioned(
                top: 30.0,
                // height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                // top: (MediaQuery.of(context).size.height - 500.0) / 2,
                child: IgnorePointer(
                  ignoring: !_toggleLyrics,
                  child: AnimatedOpacity(
                    opacity: _toggleLyrics ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 500),
                    child: ShaderMask(
                      shaderCallback: (rect) {
                        return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.0, 0.1, 0.9, 1.0],
                          colors: [
                            Colors.transparent,
                            Colors.black,
                            Colors.black,
                            Colors.transparent
                          ],
                        ).createShader(
                            Rect.fromLTRB(0, 0, rect.width, rect.height));
                      },
                      blendMode: BlendMode.dstIn,
                      child: player != null
                          ? buildReaderWidget(player)
                          : Container(),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: (MediaQuery.of(context).size.height - 500.0) / 2,
                width: MediaQuery.of(context).size.width,
                child: IgnorePointer(
                  ignoring: _toggleLyrics,
                  child: AnimatedOpacity(
                    opacity: _toggleLyrics ? 0.0 : 1.0,
                    duration: Duration(milliseconds: 500),
                    child: Center(
                      child: SizedBox(
                        height: 250.0,
                        width: MediaQuery.of(context).size.width,
                        child: CarouselSlider.builder(
                          carouselController: carouselController,
                          options: CarouselOptions(
                            initialPage: player?.effectiveIndices!
                                    .indexOf(currentPlayingSongInQueue!) ??
                                0,
                            aspectRatio: 1.0,
                            viewportFraction: userPlayingMode == 0 ? 0.8 : 0.6,
                            enlargeCenterPage: true,
                            onPageChanged: (index, reason) {
                              if (reason == CarouselPageChangedReason.manual) {
                                player?.seek(Duration.zero,
                                    index: player.effectiveIndices![index]);
                                Future.delayed(Duration(milliseconds: 700), () {
                                  appState.currentPlayingSongInQueue =
                                      player?.effectiveIndices![index];

                                  if (!(player?.playerState.playing ?? true)) {
                                    player?.play();
                                    appState.isPlaying = true;
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
                          itemBuilder: (BuildContext context, int itemIndex,
                              int pageViewIndex) {
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
                                      offset: Offset(0.0,
                                          4.0), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: (player != null &&
                                        (player.effectiveIndices?.isNotEmpty ??
                                            false) &&
                                        player.effectiveIndices![itemIndex] ==
                                            currentPlayingSongInQueue)
                                    ? AnimatedBuilder(
                                        animation: _songCoverRotateAnimation,
                                        builder: (BuildContext context,
                                            Widget? child) {
                                          return Transform.rotate(
                                            angle: _songCoverRotateAnimation
                                                    .value *
                                                2 *
                                                pi,
                                            child: child,
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(150.0)),
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _toggleLyrics = true;
                                              });
                                              print(_toggleLyrics);
                                            },
                                            child: Image.asset(
                                              // (_userPlayingMode ==0)?
                                              // songsOfPlaylist[itemIndex].coverUri
                                              (queue?.isNotEmpty ?? false)
                                                  ? (queue![player
                                                              .effectiveIndices![
                                                          itemIndex]]
                                                      .coverUri)
                                                  : 'assets/images/songs_cover/tit.jpeg',
                                              fit: BoxFit.fitHeight,
                                              height: 230.0,
                                              width: 230.0,
                                            ),
                                          ),
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(150.0)),
                                        child: Image.asset(
                                          // (_userPlayingMode ==0)?
                                          // songsOfPlaylist[itemIndex].coverUri
                                          (player != null &&
                                                  (queue?.isNotEmpty ?? false))
                                              ? queue![player.effectiveIndices![
                                                      itemIndex]]
                                                  .coverUri
                                              : 'assets/images/songs_cover/tit.jpeg',
                                          fit: BoxFit.fitHeight,
                                          height: 230.0,
                                          width: 230.0,
                                        ),
                                      ),
                              ),
                            );
                          },
                          itemCount: queue?.length,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
                bottom: _toggleLyrics ? 20.0 : 90.0,
                width: MediaQuery.of(context).size.width,
                child: IgnorePointer(
                  ignoring: _toggleLyrics,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 500),
                    opacity: _toggleLyrics ? 0.0 : 1.0,
                    child: Padding(
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
                                //TODO: fix bug: volume more than 1 not works.
                                showSliderDialog(
                                  context: context,
                                  title: "Adjust volume",
                                  divisions: 10,
                                  min: 0.0,
                                  max: 1.0,
                                  value: volume!,
                                  stream: player!.volumeStream,
                                  onChanged: (volume) {
                                    player.setVolume(volume);
                                    appState.volume = volume;
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: Text(
                                '${speed!.toStringAsFixed(1)}x',
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
                                  value: speed,
                                  stream: player!.speedStream,
                                  onChanged: (speed) {
                                    player.setSpeed(speed);
                                    appState.speed = speed;
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
                                print(queue);
                                print(carouselController);
                                print(player);
                                setState(() {});
                              },
                            ),
                            IconButton(
                              color: Color(0xE5FFFFFF),
                              icon: Icon(Icons.more_vert_rounded),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  // builder: (context) => Dialog(
                                  //   child: Text('hello'),
                                  // ),
                                  builder: (_) => CreateSongplayerMenuDialog(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0.0,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 30.0,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      height: 30.0,
                      child: StreamBuilder<PositionData>(
                        stream: positionDataStream,
                        builder: (context, snapshot) {
                          final positionData = snapshot.data;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (_toggleLyrics) {
                              setState(() {
                                // playProgress = player.positionStream.
                                playProgress =
                                    positionData?.position.inMilliseconds ?? 0;
                                sliderProgress = playProgress.toDouble();
                              });
                            }
                          });
                          return SeekBar(
                            duration: positionData?.duration ?? Duration.zero,
                            position: positionData?.position ?? Duration.zero,
                            bufferedPosition:
                                positionData?.bufferedPosition ?? Duration.zero,
                            onChangeEnd: player?.seek,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ]),
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
                        if (userPlayingMode == 0) {
                          return IconButton(
                            icon: const Icon(Icons.shuffle_rounded),
                            color: Color(0xE5FFFFFF),
                            onPressed: () {
                              setState(() {
                                appState.userPlayingMode = 1;
                              });
                              player!.setShuffleModeEnabled(false);
                              player.setLoopMode(LoopMode.all);
                              carouselController.jumpToPage(player
                                  .effectiveIndices!
                                  .indexOf(player.currentIndex!));
                            },
                          );
                        } else if (userPlayingMode == 1) {
                          return IconButton(
                            icon: const Icon(Icons.repeat_rounded),
                            color: Color(0xE5FFFFFF),
                            onPressed: () {
                              setState(() {
                                appState.userPlayingMode = 2;
                              });
                              player!.setShuffleModeEnabled(false);
                              player.setLoopMode(LoopMode.one);
                            },
                          );
                        } else if (userPlayingMode == 2) {
                          return IconButton(
                            icon: const Icon(Icons.repeat_one_rounded),
                            color: Color(0xE5FFFFFF),
                            onPressed: () {
                              setState(() {
                                appState.userPlayingMode = 0;
                              });
                              player!.setShuffleModeEnabled(true);
                              player.shuffle();
                              player.setLoopMode(LoopMode.all);
                              carouselController.jumpToPage(player
                                  .effectiveIndices!
                                  .indexOf(player.currentIndex!));
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
                      player?.seek(Duration.zero,
                          index: userPlayingMode == 2
                              ? (player.currentIndex! +
                                      (queue?.length ?? 0) -
                                      1) %
                                  (queue?.length ?? 1)
                              : player.previousIndex);
                      carouselController.animateToPage(player?.effectiveIndices!
                              .indexOf(userPlayingMode == 2
                                  ? (player.currentIndex! +
                                          (queue?.length ?? 0) -
                                          1) %
                                      (queue?.length ?? 1)
                                  : player.previousIndex!) ??
                          0);
                      Future.delayed(Duration(milliseconds: 700), () {
                        appState.currentPlayingSongInQueue =
                            player?.currentIndex;

                        if (!(player?.playerState.playing ?? true)) {
                          player?.play();
                          appState.isPlaying = true;
                        }
                      });
                    },
                  ),
                  Material(
                    color: Colors.transparent,
                    child: Center(
                      child: StreamBuilder<PlayerState>(
                        stream: player?.playerStateStream,
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
                              onPressed: () {
                                player!.play();
                                // appState.isPlaying = true;
                                // player.positionStream.listen((event) {
                                //   // _sliderProgress = event.inMilliseconds.toDouble();
                                //   setState(() {
                                //     sliderProgress =
                                //         event.inMilliseconds.toDouble();
                                //     playProgress = event.inMilliseconds;
                                //     print(playProgress);
                                //   });
                                // });
                                // player.durationStream.listen((event) {
                                //   setState(() {
                                //     max_value =
                                //         event!.inMilliseconds.toDouble();
                                //   });
                                // });
                                setState(() {
                                  _controller.repeat();
                                });
                              },
                            );
                          } else if (processingState !=
                              ProcessingState.completed) {
                            return IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                  Icons.pause_circle_outline_rounded),
                              iconSize: 50.0,
                              color: Color(0xE5FFFFFF),
                              onPressed: () {
                                player?.pause();
                                // appState.isPlaying = false;
                                setState(() {
                                  _controller.stop();
                                });
                              },
                            );
                          } else {
                            return IconButton(
                              icon: const Icon(Icons.replay_rounded),
                              iconSize: 40.0,
                              color: Color(0xE5FFFFFF),
                              onPressed: () => player?.seek(Duration.zero),
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
                      player?.seek(Duration.zero,
                          index: userPlayingMode == 2
                              ? (player.currentIndex! + 1) %
                                  (queue?.length ?? 1)
                              : player.nextIndex);
                      carouselController.animateToPage(player?.effectiveIndices!
                              .indexOf(userPlayingMode == 2
                                  ? (player.currentIndex! + 1) %
                                      (queue?.length ?? 1)
                                  : player.nextIndex!) ??
                          0);
                      Future.delayed(Duration(milliseconds: 700), () {
                        appState.currentPlayingSongInQueue =
                            player?.currentIndex;

                        if (!(player?.playerState.playing ?? true)) {
                          player?.play();
                          appState.isPlaying = true;
                        }
                      });
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

  var lyricPadding = 40.0;
  var lyricModel = LyricsModelBuilder.create()
      .bindLyricToMain(MockData.normalLyric)
      .bindLyricToExt(MockData.transLyric)
      .getModel();
  double sliderProgress = 0;
  int playProgress = 0;
  // bool isPlaying = false;
  // double max_value = 211658;
// bool isTap = false;
  var lyricUI = MyLyricsDisplayer(
    defaultSize: 20.0,
    defaultExtSize: 14.0,
    otherMainSize: 18.0,
    inlineGap: 0.0,
  );
  // var myPlaying = false;

  Stack buildReaderWidget(AudioPlayer? player) {
    return Stack(
      children: [
        LyricsReader(
          padding: EdgeInsets.symmetric(horizontal: lyricPadding),
          model: lyricModel,
          position: playProgress,
          lyricUi: lyricUI,
          playing: _isPlaying,
          size:
              Size(double.infinity, MediaQuery.of(context).size.height - 280.0),
          onTap: () {
            setState(() {
              _toggleLyrics = !_toggleLyrics;
            });
          },
          emptyBuilder: () => Center(
            child: Text(
              "No lyrics",
              style: lyricUI.getOtherMainTextStyle(),
            ),
          ),
          selectLineBuilder: (progress, confirm) {
            return GestureDetector(
              onTap: () {
                LyricsLog.logD("Click event");
                confirm.call();
                setState(() {
                  player?.seek(Duration(milliseconds: progress));
                });
              },
              child: Container(
                color: Colors.transparent,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          LyricsLog.logD("Click event");
                          confirm.call();
                          setState(() {
                            player?.seek(Duration(milliseconds: progress));
                          });
                        },
                        icon: Icon(Icons.play_arrow_rounded,
                            color: Colors.white.withOpacity(0.25))),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.25)),
                        height: 1.0,
                        width: double.infinity,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 5.0),
                      child: Text(
                        RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                                .firstMatch(
                                    "${Duration(milliseconds: playProgress)}")
                                ?.group(1) ??
                            '${Duration(milliseconds: playProgress)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.25),
                          fontSize: 12.0,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
