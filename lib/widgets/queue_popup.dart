import 'dart:math';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_song.dart';
import '../states/app_state.dart';
import 'confirm_popup.dart';
import 'song_item_in_queue.dart';

class ShowQueueDialog extends StatefulWidget {
  @override
  State<ShowQueueDialog> createState() => _ShowQueueDialogState();
}

class _ShowQueueDialogState extends State<ShowQueueDialog>
    with SingleTickerProviderStateMixin {
  ScrollController _scrollController = ScrollController();
  late int _currentPlatform;
  MyAppState? _appState;
  int? _queueLength;
  late CarouselController _carouselController;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    _currentPlatform = state.currentPlatform;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentPlatform == 3) {
        int index = state.currentPlayingResourceInQueue!;
        int realIndex = index <= 2
            ? 0
            : index >= (state.resourcesQueue!.length - 9)
                ? max(state.resourcesQueue!.length - 11, 0)
                : index - 2;
        _scrollController.jumpTo(realIndex * 40.0);
      } else {
        int index = state.currentPlayingSongInQueue!;
        int realIndex = index <= 2
            ? 0
            : index >= (state.songsQueue!.length - 9)
                ? max(state.songsQueue!.length - 11, 0)
                : index - 2;
        _scrollController.jumpTo(realIndex * 40.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    _appState = appState;
    _carouselController = appState.carouselController;
    var songsQueue = appState.songsQueue;
    var resourcesQueue = appState.resourcesQueue;
    var queue = _currentPlatform == 3 ? resourcesQueue : songsQueue;
    if (queue == null || queue.isEmpty) {
      _queueLength = 0;
    } else {
      _queueLength = queue.length;
    }

    var currentPlayingSongInQueue = appState.currentPlayingSongInQueue;
    var currentPlayingResourceInQueue = appState.currentPlayingResourceInQueue;
    var player = appState.songsPlayer;
    if (_queueLength == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (player != null && mounted) {
          appState.songsQueue = [];
          appState.currentPlayingSongInQueue = 0;
          appState.currentSong = null;
          appState.prevSong = null;
          appState.isSongPlaying = false;
          player.stop();
          player.dispose();
          appState.songsPlayer = null;
          appState.songsAudioSource!.clear();
          Navigator.of(context).pop();
        }
      });
    }
    return Dialog(
      insetPadding: EdgeInsets.all(0.0),
      alignment: Alignment.bottomCenter,
      child: Material(
        color: colorScheme.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
        child: SizedBox(
          height: 480,
          width: double.infinity,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(25.0, 0.0, 12.0, 0.0),
                child: Row(children: [
                  Expanded(
                    child: Text(
                      'Queue($_queueLength)',
                      style: textTheme.labelMedium!.copyWith(
                        fontSize: 14.0,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded),
                    color: colorScheme.onPrimary,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => ShowConfirmDialog(
                          title: 'Do you want to empty the queue?',
                          onConfirm: () {
                            if (_currentPlatform == 3) {
                              appState.resourcesQueue = [];
                            } else {
                              appState.songsQueue = [];
                            }
                          },
                        ),
                      );
                    },
                  )
                ]),
              ),
              Expanded(
                child: _queueLength == 0
                    ? Center(
                        child: Text(
                        'Empty queue',
                        style: textTheme.labelMedium,
                      ))
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _queueLength,
                        controller: _scrollController,
                        itemBuilder: (context, index) {
                          if (_currentPlatform == 3) {
                          } else {}
                          String name = _currentPlatform == 3
                              ? resourcesQueue![index].title
                              : songsQueue![index].name;
                          dynamic singers = _currentPlatform == 3
                              ? resourcesQueue![index].upperName
                              : songsQueue![index].singers;
                          String cover = _currentPlatform == 3
                              ? resourcesQueue![index].cover
                              : songsQueue![index].cover;
                          int payPlayType = _currentPlatform == 3
                              ? 0
                              : songsQueue![index].payPlay;
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (_currentPlatform == 3) {
                                  if (currentPlayingResourceInQueue == index) {
                                    return;
                                  }
                                  appState.currentPlayingResourceInQueue =
                                      index;
                                  appState.currentResource =
                                      resourcesQueue![index];
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    player!.seek(Duration.zero, index: index);
                                  });
                                  if (!player!.playerState.playing) {
                                    player.play();
                                    appState.isResourcePlaying = true;
                                  }
                                } else {
                                  if (currentPlayingSongInQueue == index) {
                                    return;
                                  }
                                  appState.currentPlayingSongInQueue = index;
                                  appState.currentSong = songsQueue![index];
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    player!.seek(Duration.zero, index: index);
                                  });
                                  if (!player!.playerState.playing) {
                                    player.play();
                                    appState.isSongPlaying = true;
                                  }
                                }
                              },
                              child: Container(
                                margin:
                                    EdgeInsets.fromLTRB(25.0, 0.0, 12.0, 0.0),
                                child: SongItemInQueue(
                                    name: name,
                                    payPlayType: payPlayType,
                                    cover: cover,
                                    singers: singers,
                                    isPlaying:
                                        currentPlayingSongInQueue == index
                                            ? true
                                            : false,
                                    onClose: () {
                                      onCloseSongItem(index, appState);
                                    }),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onCloseSongItem(int index, MyAppState appState) {
    appState.removeSongInQueue(index);
    int currentPlayingSongInQueue = appState.currentPlayingSongInQueue!;
    AudioPlayer player = appState.songsPlayer!;
    List<BasicSong> songsQueue = appState.songsQueue!;
    if (appState.songsAudioSource?.length != 0) {
      appState.songsAudioSource!.removeAt(index);
    }
    appState.isRemovingSongFromQueue = true;
    if (index < currentPlayingSongInQueue) {
      appState.currentPlayingSongInQueue =
          (currentPlayingSongInQueue - 1) % _queueLength!;
      currentPlayingSongInQueue = appState.currentPlayingSongInQueue!;

      appState.currentSong = _queueLength != 0
          ? songsQueue[(currentPlayingSongInQueue - 1) % _queueLength!]
          : null;
    } else if (index > currentPlayingSongInQueue) {
    } else {
      // Set the new playing song to the first if the current
      // removed song is the last and is playing.
      if (currentPlayingSongInQueue == _queueLength! - 1) {
        appState.currentPlayingSongInQueue = 0;
        currentPlayingSongInQueue = 0;
        appState.currentSong = (songsQueue.isNotEmpty) ? songsQueue[0] : null;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (songsQueue.isNotEmpty) {
          appState.songsPlayer!
              .seek(Duration.zero, index: currentPlayingSongInQueue);
          appState.currentSong = (songsQueue.isNotEmpty)
              ? songsQueue[currentPlayingSongInQueue]
              : null;
          appState.currentPlayingSongInQueue = currentPlayingSongInQueue;
        }
      });

      if (!player.playerState.playing) {
        player.play();
        appState.isSongPlaying = true;
      }
    }
    //TODO: fix bug: when the song is removed from the queue
    // is above the current playing song in queue, and the song player
    // is open, the song cover animation will be wired.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (appState.isSongsPlayerPageOpened) {
        _carouselController.jumpToPage(
          player.effectiveIndices!.indexOf(appState.currentPlayingSongInQueue!),
        );
      }
    });

    Future.delayed(Duration(milliseconds: 200), () {
      appState.isRemovingSongFromQueue = false;
    });
  }
}
