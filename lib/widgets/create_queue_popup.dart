import 'package:flutter/material.dart';
import 'package:playlistmaster/states/app_state.dart';
import 'package:playlistmaster/widgets/create_confirm_popup.dart';
import 'package:playlistmaster/widgets/song_item_in_queue.dart';
import 'package:provider/provider.dart';

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
    var isPlayerPageOpened = appState.isPlayerPageOpened;
    if (queue!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (appState.player != null && mounted) {
          appState.queue = [];
          appState.isPlaying = false;
          appState.player!.stop();
          appState.player!.dispose();
          appState.player = null;
          appState.initQueue!.clear();
          Navigator.of(context).pop();
        }
      });
    }
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.all(0.0),
      alignment: Alignment.bottomCenter,
      child: Material(
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
                      style: TextStyle(
                        color: Color(0x42000000),
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded),
                    color: Color(0x42000000),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => ShowConfirmDialog(),
                      );
                    },
                  )
                ]),
              ),
              Expanded(
                child: (appState.isQueueEmpty)
                    ? Center(child: Text('Empty Queue'))
                    : ListView.builder(
                        itemCount: queueLength,
                        itemBuilder: (context, index) {
                          var songName = queue[index].name;
                          var singers = queue[index].singers;
                          var coverUri = queue[index].coverUri;
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (currentPlayingSongInQueue == index) {
                                  return;
                                }
                                appState.currentPlayingSongInQueue = index;
                                if (!isPlayerPageOpened) {
                                  appState.currentSong = queue[index];
                                }
                                // appState.carouselController.animateToPage(
                                //     player!.effectiveIndices!.indexOf(index));
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  appState.player!
                                      .seek(Duration.zero, index: index);
                                  if (appState.isPlayerPageOpened) {
                                    carouselController.animateToPage(
                                      player!.effectiveIndices!.indexOf(index),
                                    );
                                  }
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
                                  name: songName,
                                  coverUri: coverUri,
                                  singers: singers,
                                  isPlaying:
                                      (currentPlayingSongInQueue == index)
                                          ? true
                                          : false,
                                  onClose: () {
                                    appState.removeSongInQueue(index);
                                    appState.initQueue!.removeAt(index);
                                    appState.isRemovingSongFromQueue = true;
                                    if (index < currentPlayingSongInQueue!) {
                                      appState.currentPlayingSongInQueue =
                                          currentPlayingSongInQueue - 1;
                                      if (!isPlayerPageOpened) {
                                        appState.currentSong = (queue
                                                .isNotEmpty)
                                            ? queue[
                                                currentPlayingSongInQueue - 1]
                                            : null;
                                      }
                                      // appState.updateSong = true;
                                    } else if (index >
                                        currentPlayingSongInQueue) {
                                      // player!.seek(Duration.zero,
                                      //     index: 0);
                                      // appState.updateSong = true;
                                    } else {
                                      // Set the new playing song to the first if the current
                                      // removed song is the last and is playing.
                                      if (currentPlayingSongInQueue ==
                                          queueLength - 1) {
                                        appState.currentPlayingSongInQueue = 0;
                                        if (!isPlayerPageOpened) {
                                          appState.currentSong =
                                              (queue.isNotEmpty)
                                                  ? queue[0]
                                                  : null;
                                        }
                                      }
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        appState.player!.seek(Duration.zero,
                                            index: currentPlayingSongInQueue);
                                        if (!isPlayerPageOpened) {
                                          appState.currentSong = (queue
                                                  .isNotEmpty)
                                              ? queue[currentPlayingSongInQueue]
                                              : null;
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
                                    // } else if (index ==
                                    //         currentPlayingSongInQueue &&
                                    //     currentPlayingSongInQueue ==
                                    //         queueLength - 1) {
                                    //   appState.currentPlayingSongInQueue = 0;
                                    //   if (!player!.playerState.playing) {
                                    //     player.play();
                                    //     appState.isPlaying = true;
                                    //   }
                                    // } else if (index ==
                                    //         currentPlayingSongInQueue &&
                                    //     currentPlayingSongInQueue !=
                                    //         queueLength - 1) {
                                    //   if (!player!.playerState.playing) {
                                    //     player.play();
                                    //     appState.isPlaying = true;
                                    //   }
                                    // }

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
