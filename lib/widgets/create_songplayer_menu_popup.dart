import 'package:flutter/material.dart';
import 'package:playlistmaster/states/app_state.dart';
import 'package:provider/provider.dart';

class CreateSongplayerMenuDialog extends StatelessWidget {
  void _onCancelPressed(BuildContext context) {
    Navigator.pop(context);
  }

  void _onFinishPressed(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    return Dialog(
      // backgroundColor: Colors.white,
      insetPadding: EdgeInsets.all(0.0),
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
              onTap: () {
                print('add to playlist');
                print(appState);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.playlist_add_rounded),
                      disabledColor: Colors.black.withOpacity(0.7),
                      onPressed: null,
                    ),
                    Expanded(
                      child: Text(
                        'Add to playlist',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
              onTap: () {
                print('remove from queue');
                if (appState.queue!.length != 1) {
                  if (appState.currentPlayingSongInQueue ==
                      appState.queue!.length - 1) {
                    appState.currentPlayingSongInQueue = 0;
                    appState.currentSong = (appState.queue!.isNotEmpty)
                        ? appState.queue![0]
                        : null;
                  } else {
                    appState.currentSong = (appState.queue!.isNotEmpty)
                        ? appState.queue![appState.currentPlayingSongInQueue!]
                        : null;
                  }
                  appState.isRemovingSongFromQueue = true;

                  appState
                      .removeSongInQueue(appState.currentPlayingSongInQueue!);
                  if (appState.initQueue?.length != 0) {
                    appState.initQueue!
                        .removeAt(appState.currentPlayingSongInQueue!);
                  }
                  Future.delayed(Duration(milliseconds: 200), () {
                    appState.isRemovingSongFromQueue = false;
                  });

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    // appState.coverRotatingController!.reset();
                    appState.player!.seek(Duration.zero,
                        index: appState.currentPlayingSongInQueue);
                    appState.carouselController
                        .jumpToPage(appState.currentPlayingSongInQueue!);
                  });
                } else {
                  appState.queue = [];
                  appState.currentDetailSong = null;
                  appState.currentPlayingSongInQueue = -1;
                  appState.currentSong = null;
                  appState.prevSong = null;
                  appState.isPlaying = false;
                  appState.player!.stop();
                  appState.player!.dispose();
                  appState.player = null;
                  appState.initQueue!.clear();
                }

                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_from_queue_rounded),
                      disabledColor: Colors.black.withOpacity(0.7),
                      onPressed: null,
                    ),
                    Expanded(
                      child: Text(
                        'Remove from queue',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
              onTap: () {
                print('song\'s detail');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.description_rounded),
                      disabledColor: Colors.black.withOpacity(0.7),
                      onPressed: null,
                    ),
                    Expanded(
                      child: Text(
                        'Song\'s detail',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
