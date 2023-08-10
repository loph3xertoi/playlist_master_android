import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/dto/result.dart';
import '../states/app_state.dart';
import '../utils/my_toast.dart';
import 'select_library_popup.dart';

class CreateSongplayerMenuDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
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
                Navigator.pop(context);
                _addSongToLibrary(context, appState);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.playlist_add_rounded),
                      color: colorScheme.tertiary,
                      onPressed: () {
                        Navigator.pop(context);
                        _addSongToLibrary(context, appState);
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Add to library',
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
                if (appState.songsQueue!.length == 1) {
                  Navigator.pop(context);
                  appState.songsQueue = [];
                  appState.currentPlayingSongInQueue = 0;
                  appState.currentSong = null;
                  appState.prevSong = null;
                  appState.isSongPlaying = false;
                  appState.songsPlayer!.stop();
                  appState.songsPlayer!.dispose();
                  appState.songsPlayer = null;
                  appState.songsAudioSource!.clear();
                  return;
                }
                Navigator.pop(context);
                appState.isRemovingSongFromQueue = true;
                appState.removeSongInQueue(appState.currentPlayingSongInQueue!);
                if (appState.songsAudioSource?.length != 0) {
                  appState.songsAudioSource!
                      .removeAt(appState.currentPlayingSongInQueue!);
                }
                Future.delayed(Duration(milliseconds: 200), () {
                  appState.isRemovingSongFromQueue = false;
                });

                appState.currentPlayingSongInQueue =
                    appState.currentPlayingSongInQueue! %
                        appState.songsQueue!.length;
                appState.currentSong =
                    appState.songsQueue![appState.currentPlayingSongInQueue!];

                appState.songsPlayer!.seek(Duration.zero,
                    index: appState.currentPlayingSongInQueue);
                appState.carouselController
                    .jumpToPage(appState.currentPlayingSongInQueue!);
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
                        if (appState.songsQueue!.length == 1) {
                          Navigator.pop(context);
                          appState.songsQueue = [];
                          appState.currentPlayingSongInQueue = 0;
                          appState.currentSong = null;
                          appState.prevSong = null;
                          appState.isSongPlaying = false;
                          appState.songsPlayer!.stop();
                          appState.songsPlayer!.dispose();
                          appState.songsPlayer = null;
                          appState.songsAudioSource!.clear();
                          return;
                        }
                        Navigator.pop(context);
                        appState.isRemovingSongFromQueue = true;
                        appState.removeSongInQueue(
                            appState.currentPlayingSongInQueue!);
                        if (appState.songsAudioSource?.length != 0) {
                          appState.songsAudioSource!
                              .removeAt(appState.currentPlayingSongInQueue!);
                        }
                        Future.delayed(Duration(milliseconds: 200), () {
                          appState.isRemovingSongFromQueue = false;
                        });

                        appState.currentPlayingSongInQueue =
                            appState.currentPlayingSongInQueue! %
                                appState.songsQueue!.length;
                        appState.currentSong = appState
                            .songsQueue![appState.currentPlayingSongInQueue!];

                        appState.songsPlayer!.seek(Duration.zero,
                            index: appState.currentPlayingSongInQueue);
                        appState.carouselController
                            .jumpToPage(appState.currentPlayingSongInQueue!);
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
                appState.isSongsPlayerPageOpened = false;
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
                        appState.isSongsPlayerPageOpened = false;
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

  void _addSongToLibrary(BuildContext context, MyAppState appState) async {
    if (context.mounted) {
      List<Future<Result?>>? list =
          await showFlexibleBottomSheet<List<Future<Result?>>>(
        minHeight: 0,
        initHeight: 0.45,
        maxHeight: 0.9,
        context: context,
        bottomSheetColor: Colors.transparent,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        builder: (
          BuildContext context,
          ScrollController scrollController,
          double bottomSheetOffset,
        ) {
          return SelectLibraryPopup(
            scrollController: scrollController,
            songs: [appState.currentSong!],
            action: 'add',
          );
        },
        anchors: [0, 0.45, 0.9],
        isSafeArea: true,
      );
      if (list != null) {
        List<Result?> results = await Future.wait<Result?>(list);
        for (Result? result in results) {
          if (result != null && result.success) {
            appState.refreshLibraries!(appState, true);
            MyToast.showToast('Add song successfully');
            break;
          }
        }
      }
    }
  }
}
