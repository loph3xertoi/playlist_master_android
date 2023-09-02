import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/dto/result.dart';
import '../entities/pms/pms_detail_song.dart';
import '../entities/pms/pms_song.dart';
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
            if (appState.currentPlatform != 0)
              InkWell(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _addSongToLibrary(context, appState, true);
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
                          _addSongToLibrary(context, appState, true);
                        },
                      ),
                      Expanded(
                        child: Text(
                          'Add to pms',
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
                Navigator.pop(context);
                _addSongToLibrary(context, appState, false);
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
                        _addSongToLibrary(context, appState, false);
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
                  appState.songsAudioSource!.clear();
                  appState.songsPlayer!.dispose();
                  appState.songsPlayer = null;
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
                          appState.songsAudioSource!.clear();
                          appState.songsPlayer!.dispose();
                          appState.songsPlayer = null;
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
            if (!(appState.currentPlatform == 0 &&
                (appState.currentSong as PMSSong).type == 3))
              InkWell(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
                onTap: () {
                  _pushToDetailSongPage(context, appState);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.description_rounded),
                        color: colorScheme.tertiary,
                        onPressed: () {
                          _pushToDetailSongPage(context, appState);
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

  void _pushToDetailSongPage(BuildContext context, MyAppState appState) async {
    print('song\'s detail');
    appState.isSongsPlayerPageOpened = false;
    var currentPlatform = appState.currentPlatform;
    if (currentPlatform == 0) {
      int songType = (appState.currentSong as PMSSong).type;
      PMSDetailSong? pmsDetailSong = await appState
          .fetchDetailSong<PMSDetailSong>(appState.currentSong, 0);
      if (songType == 1 || songType == 2) {
        if (context.mounted) {
          Navigator.popAndPushNamed(context, '/detail_song_page',
              arguments: pmsDetailSong!.basicSong);
        }
      } else if (songType == 3) {
        appState.currentResource = pmsDetailSong!.biliResource;
        if (context.mounted) {
          Navigator.popAndPushNamed(context, '/detail_resource_page');
        }
      } else {
        throw 'Invalid song type';
      }
    } else {
      if (context.mounted) {
        Navigator.popAndPushNamed(context, '/detail_song_page',
            arguments: appState.currentSong);
      }
    }
  }

  void _addSongToLibrary(
      BuildContext context, MyAppState appState, bool addToPMS) async {
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
            addToPMS: addToPMS,
          );
        },
        anchors: [0, 0.45, 0.9],
        isSafeArea: true,
      );
      if (list != null) {
        List<Result?> results = await Future.wait<Result?>(list);
        for (Result? result in results) {
          if (result != null && result.success) {
            if (!addToPMS) {
              appState.refreshLibraries!(appState, true);
            }
            MyToast.showToast('Add song successfully');
            break;
          }
        }
      }
    }
  }
}
