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
    if (queue!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
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
                                carouselController.animateToPage(
                                    player!.effectiveIndices!.indexOf(index));
                                player.seek(Duration.zero, index: index);
                                if (!player.playerState.playing) {
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
                                    if (index < currentPlayingSongInQueue!) {
                                      appState.currentPlayingSongInQueue =
                                          currentPlayingSongInQueue - 1;
                                    } else if (index >
                                        currentPlayingSongInQueue) {
                                    } else if (index ==
                                            currentPlayingSongInQueue &&
                                        currentPlayingSongInQueue ==
                                            queueLength - 1) {
                                      appState.currentPlayingSongInQueue = 0;
                                      if (!player!.playerState.playing) {
                                        player.play();
                                        appState.isPlaying = true;
                                      }
                                    } else if (index ==
                                            currentPlayingSongInQueue &&
                                        currentPlayingSongInQueue !=
                                            queueLength - 1) {
                                      if (!player!.playerState.playing) {
                                        player.play();
                                        appState.isPlaying = true;
                                      }
                                    }
                                    appState.removeSongInQueue(index);
                                    appState.initQueue!.removeAt(index);

                                    appState.updateSong = true;
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
