import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:playlistmaster/states/app_state.dart';
import 'package:playlistmaster/third_lib_change/just_audio/common.dart';
import 'package:playlistmaster/third_lib_change/like_button/like_button.dart';
import 'package:playlistmaster/widgets/create_queue_popup.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SongPlayerPage extends StatefulWidget {
  const SongPlayerPage({super.key});

  @override
  State<SongPlayerPage> createState() => _SongPlayerPageState();
}

class _SongPlayerPageState extends State<SongPlayerPage> {
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

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();

    var player = appState.player;
    var queue = appState.queue;
    var currentPlayingSongInQueue = appState.currentPlayingSongInQueue;
    var userPlayingMode = appState.userPlayingMode;
    var volume = appState.volume;
    var speed = appState.speed;
    var positionDataStream = appState.positionDataStream;
    var carouselController = appState.carouselController;
    var updateSong = appState.updateSong;

    if (queue!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (appState.canSongPlayerPagePop) {
          Navigator.of(context).pop();
          appState.isPlayerPageOpened = false;
          appState.canSongPlayerPagePop = false;
        }
      });
    }

    if (updateSong) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // if (player!.currentIndex == currentPlayingSongInQueue) {
        //   return;
        // }
        player!.seek(Duration.zero, index: currentPlayingSongInQueue);
        // player!
        //     .seek(appState.player!.duration, index: currentPlayingSongInQueue);
        // TODO: fix bug: if the song removed from queue is over the current playing song, the
        // animation will be wired.
        carouselController.jumpToPage(
            player.effectiveIndices!.indexOf(currentPlayingSongInQueue!));
        appState.updateSong = false;
      });
    }
    // appState.addListener(() {
    //   if(currentPlayingSongInQueue != appState.currentPlayingSongInQueue){
    //     print('daw---');
    //   }
    //   // if (mounted &&
    //   //     currentPlayingSongInQueue != appState.currentPlayingSongInQueue) {
    //   //   _currentSongIndex = appState.currentPlayingSongInQueue;
    //   //   Future.delayed(Duration(milliseconds: 0), () {
    //   //     _player.seek(Duration.zero, index: _currentSongIndex);
    //   //     _carouselController.jumpToPage(appState.currentPlayingSongInQueue);
    //   //     if (!_player.playerState.playing) {
    //   //       _player.play();
    //   //     }
    //   //   });
    //   //   setState(() {});
    //   // }
    //   // if (mounted && appState.isPlaying != _player.playerState.playing) {
    //   //   appState.isPlaying = _player.playerState.playing;
    //   // }
    // });

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
                            queue.isNotEmpty
                                ? queue[currentPlayingSongInQueue!].name
                                : '',
                            style: TextStyle(
                              color: Color(0xE5FFFFFF),
                              fontFamily: 'Roboto',
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        Text(
                          queue.isNotEmpty
                              ? queue[currentPlayingSongInQueue!]
                                  .singers[0]
                                  .name
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
                            queue.isNotEmpty
                                ? queue[player!.effectiveIndices![itemIndex]]
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
                  itemCount: queue.length,
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
                  stream: positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data;
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
                              ? (player.currentIndex! + queue.length - 1) %
                                  queue.length
                              : player.previousIndex);
                      carouselController.animateToPage(player?.effectiveIndices!
                              .indexOf(userPlayingMode == 2
                                  ? (player.currentIndex! + queue.length - 1) %
                                      queue.length
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
                                player?.play();
                                appState.isPlaying = true;
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
                                appState.isPlaying = false;
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
                              ? (player.currentIndex! + 1) % queue.length
                              : player.nextIndex);
                      carouselController.animateToPage(player?.effectiveIndices!
                              .indexOf(userPlayingMode == 2
                                  ? (player.currentIndex! + 1) % queue.length
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
}
