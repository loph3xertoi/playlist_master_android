import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../states/app_state.dart';
import 'confirm_popup.dart';
import 'song_item_in_queue.dart';

class ShowQueueDialog extends StatefulWidget {
  @override
  State<ShowQueueDialog> createState() => _ShowQueueDialogState();
}

class _ShowQueueDialogState extends State<ShowQueueDialog>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    var queue = appState.queue;
    var queueLength = queue?.length ?? 0;
    var currentPlayingSongInQueue = appState.currentPlayingSongInQueue;
    var carouselController = appState.carouselController;
    var player = appState.player;
    if (queue!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (appState.player != null && mounted) {
          appState.queue = [];
          // appState.currentDetailSong = null;
          appState.currentPlayingSongInQueue = 0;
          appState.currentSong = null;
          appState.prevSong = null;
          appState.isPlaying = false;
          appState.player!.stop();
          appState.player!.dispose();
          appState.player = null;
          appState.initQueue!.clear();
          Navigator.of(context).pop();
        }
      });
    }
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
      // backgroundColor: Colors.black  ,
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
                      'Queue($queueLength)',
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
                            appState.queue = [];
                          },
                        ),
                      );
                    },
                  )
                ]),
              ),
              Expanded(
                child: (appState.isQueueEmpty)
                    ? Center(
                        child: Text(
                        'Empty Queue',
                        style: textTheme.labelMedium,
                      ))
                    : ListView.builder(
                        itemCount: queueLength,
                        itemBuilder: (context, index) {
                          var name = queue[index].name;
                          var singers = queue[index].singers;
                          var cover = queue[index].cover;
                          var payPlayType = queue[index].payPlay;
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (currentPlayingSongInQueue == index) {
                                  return;
                                }
                                appState.currentPlayingSongInQueue = index;
                                // if (!isPlayerPageOpened) {
                                appState.currentSong = queue[index];
                                // }
                                // appState.carouselController.animateToPage(
                                //     player!.effectiveIndices!.indexOf(index));
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  appState.player!
                                      .seek(Duration.zero, index: index);
                                  // Future.delayed(Duration(seconds: 1), () {
                                  //   if (appState.isPlayerPageOpened) {
                                  //     carouselController.animateToPage(
                                  //       player!.effectiveIndices!
                                  //           .indexOf(index),
                                  //     );
                                  //   }
                                  // });
                                });

                                if (!player!.playerState.playing) {
                                  player.play();
                                  appState.isPlaying = true;
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
                                      (currentPlayingSongInQueue == index)
                                          ? true
                                          : false,
                                  onClose: () {
                                    appState.removeSongInQueue(index);
                                    if (appState.initQueue?.length != 0) {
                                      appState.initQueue!.removeAt(index);
                                    }
                                    appState.isRemovingSongFromQueue = true;
                                    if (index < currentPlayingSongInQueue!) {
                                      appState.currentPlayingSongInQueue =
                                          (currentPlayingSongInQueue! - 1) %
                                              queue.length;
                                      currentPlayingSongInQueue =
                                          appState.currentPlayingSongInQueue;
                                      // if (!isPlayerPageOpened) {
                                      appState.currentSong = (queue.isNotEmpty)
                                          ? queue[
                                              (currentPlayingSongInQueue! - 1) %
                                                  queue.length]
                                          : null;
                                      // }
                                      // appState.updateSong = true;
                                    } else if (index >
                                        currentPlayingSongInQueue!) {
                                      // player!.seek(Duration.zero,
                                      //     index: 0);
                                      // appState.updateSong = true;
                                    } else {
                                      // Set the new playing song to the first if the current
                                      // removed song is the last and is playing.
                                      if (currentPlayingSongInQueue ==
                                          queueLength - 1) {
                                        appState.currentPlayingSongInQueue = 0;
                                        currentPlayingSongInQueue = 0;
                                        // if (!isPlayerPageOpened) {
                                        appState.currentSong =
                                            (queue.isNotEmpty)
                                                ? queue[0]
                                                : null;
                                        // }
                                      }
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        if (queue.isNotEmpty) {
                                          appState.player!.seek(Duration.zero,
                                              index: currentPlayingSongInQueue);
                                          // if (!isPlayerPageOpened) {
                                          appState.currentSong = (queue
                                                  .isNotEmpty)
                                              ? queue[
                                                  currentPlayingSongInQueue!]
                                              : null;
                                          // }
                                          appState.currentPlayingSongInQueue =
                                              currentPlayingSongInQueue;
                                        }
                                      });

                                      if (!player!.playerState.playing) {
                                        player.play();
                                        appState.isPlaying = true;
                                      }
                                    }
                                    //TODO: fix bug: when the song is removed from the queue
                                    // is above the current playing song in queue, and the song player
                                    // is open, the song cover animation will be wired.
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      if (appState.isPlayerPageOpened) {
                                        carouselController.jumpToPage(
                                          player!.effectiveIndices!.indexOf(
                                              appState
                                                  .currentPlayingSongInQueue!),
                                        );
                                      }
                                    });

                                    Future.delayed(Duration(milliseconds: 200),
                                        () {
                                      appState.isRemovingSongFromQueue = false;
                                    });

                                    // appState.updateSong = true;
                                    // TODO: fix bug, seek not working.
                                    // player.seek(Duration.zero,
                                    //     index: currentPlayingSongInQueue);
                                  },
                                ),
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
}
