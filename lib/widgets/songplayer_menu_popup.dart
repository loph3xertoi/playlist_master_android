import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../states/app_state.dart';

class CreateSongplayerMenuDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
      // backgroundColor: Colors.white,
      insetPadding: EdgeInsets.all(0.0),
      alignment: Alignment.bottomCenter,
      child: Material(
        color: colorScheme.primary,
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
                      color: colorScheme.tertiary,
                      onPressed: () {},
                    ),
                    Expanded(
                      child: Text(
                        'Add to playlist',
                        style: textTheme.labelMedium!.copyWith(
                          color: colorScheme.onSecondary,
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

                if (appState.queue!.length == 1) {
                  appState.queue = [];
                  appState.currentPlayingSongInQueue = 0;
                  appState.currentSong = null;
                  appState.prevSong = null;
                  appState.isPlaying = false;
                  appState.player!.stop();
                  appState.player!.dispose();
                  appState.player = null;
                  appState.initQueue!.clear();
                  Navigator.pop(context);
                  return;
                }

                appState.isRemovingSongFromQueue = true;
                appState.removeSongInQueue(appState.currentPlayingSongInQueue!);
                if (appState.initQueue?.length != 0) {
                  appState.initQueue!
                      .removeAt(appState.currentPlayingSongInQueue!);
                }
                Future.delayed(Duration(milliseconds: 200), () {
                  appState.isRemovingSongFromQueue = false;
                });

                appState.currentPlayingSongInQueue =
                    appState.currentPlayingSongInQueue! %
                        appState.queue!.length;
                appState.currentSong =
                    appState.queue![appState.currentPlayingSongInQueue!];

                appState.player!.seek(Duration.zero,
                    index: appState.currentPlayingSongInQueue);
                appState.carouselController
                    .jumpToPage(appState.currentPlayingSongInQueue!);
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_from_queue_rounded),
                      color: colorScheme.tertiary,
                      onPressed: () {
                        print('remove from queue');

                        if (appState.queue!.length == 1) {
                          appState.queue = [];
                          appState.currentPlayingSongInQueue = 0;
                          appState.currentSong = null;
                          appState.prevSong = null;
                          appState.isPlaying = false;
                          appState.player!.stop();
                          appState.player!.dispose();
                          appState.player = null;
                          appState.initQueue!.clear();
                          Navigator.pop(context);
                          return;
                        }

                        appState.isRemovingSongFromQueue = true;
                        appState.removeSongInQueue(
                            appState.currentPlayingSongInQueue!);
                        if (appState.initQueue?.length != 0) {
                          appState.initQueue!
                              .removeAt(appState.currentPlayingSongInQueue!);
                        }
                        Future.delayed(Duration(milliseconds: 200), () {
                          appState.isRemovingSongFromQueue = false;
                        });

                        appState.currentPlayingSongInQueue =
                            appState.currentPlayingSongInQueue! %
                                appState.queue!.length;
                        appState.currentSong = appState
                            .queue![appState.currentPlayingSongInQueue!];

                        appState.player!.seek(Duration.zero,
                            index: appState.currentPlayingSongInQueue);
                        appState.carouselController
                            .jumpToPage(appState.currentPlayingSongInQueue!);
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Remove from queue',
                        style: textTheme.labelMedium!.copyWith(
                          color: colorScheme.onSecondary,
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
                appState.isPlayerPageOpened = false;
                Navigator.popAndPushNamed(context, '/detail_song_page',
                    arguments: appState.currentSong);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.description_rounded),
                      color: colorScheme.tertiary,
                      onPressed: () {
                        appState.isPlayerPageOpened = false;
                        Navigator.popAndPushNamed(context, '/detail_song_page',
                            arguments: appState.currentSong);
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Song\'s detail',
                        style: textTheme.labelMedium!.copyWith(
                          color: colorScheme.onSecondary,
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
