import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../entities/basic/basic_song.dart';
import '../states/app_state.dart';
import 'confirm_popup.dart';

class CreateSongItemMenuDialog extends StatefulWidget {
  CreateSongItemMenuDialog({required this.song});

  final BasicSong song;

  @override
  State<CreateSongItemMenuDialog> createState() =>
      _CreateSongItemMenuDialogState();
}

class _CreateSongItemMenuDialogState extends State<CreateSongItemMenuDialog> {
  void _removeSongFromLibrary(BuildContext context, MyAppState appState) async {
    appState.rawOpenedLibrary!.itemCount -= 1;
    appState.rawQueue!.remove(widget.song);
    appState.searchedSongs.remove(widget.song);
    await appState.removeSongsFromLibrary(
        [widget.song], appState.openedLibrary!, appState.currentPlatform);
    appState.refreshLibraries!(appState, true);
    appState.refreshDetailLibraryPage!(appState);
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
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
                Navigator.pop(context, "Add to library");
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.playlist_add_rounded),
                      color: colorScheme.tertiary,
                      onPressed: () {
                        Navigator.pop(context, 'Add to library');
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
            appState.openedLibrary!.itemCount > 0
                ? InkWell(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => ShowConfirmDialog(
                          title:
                              'Do you want to remove this song from library?',
                          onConfirm: () {
                            print('Remove from library.');
                            _removeSongFromLibrary(context, appState);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.playlist_remove_rounded),
                            color: colorScheme.tertiary,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => ShowConfirmDialog(
                                  title:
                                      'Do you want to remove this song from library?',
                                  onConfirm: () {
                                    print('Remove from library.');
                                    _removeSongFromLibrary(context, appState);
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          ),
                          Expanded(
                            child: Text(
                              'Remove from library',
                              style: textTheme.labelMedium!.copyWith(
                                color: colorScheme.onSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
            InkWell(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
              onTap: () {
                Navigator.popAndPushNamed(context, '/related_videos_page',
                    arguments: widget.song);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.ondemand_video_rounded),
                      color: colorScheme.tertiary,
                      onPressed: () {
                        Navigator.popAndPushNamed(
                            context, '/related_videos_page',
                            arguments: widget.song);
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Play video',
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
                appState.isPlayerPageOpened = false;
                BasicLibrary originLibrary = appState.openedLibrary!;
                appState.openedLibrary = BasicLibrary(
                  name: 'similar song',
                  cover: '',
                  itemCount: -1,
                );
                Navigator.popAndPushNamed(context, '/similar_songs_page',
                        arguments: widget.song)
                    .then((_) => appState.openedLibrary = originLibrary);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.library_music_rounded),
                      color: colorScheme.tertiary,
                      onPressed: () {
                        appState.isPlayerPageOpened = false;
                        BasicLibrary originLibrary = appState.openedLibrary!;
                        appState.openedLibrary = BasicLibrary(
                          name: 'similar song',
                          cover: '',
                          itemCount: -1,
                        );
                        Navigator.popAndPushNamed(
                                context, '/similar_songs_page',
                                arguments: widget.song)
                            .then(
                                (_) => appState.openedLibrary = originLibrary);
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Similar songs',
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
                    arguments: widget.song);
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
                            arguments: widget.song);
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
