import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../entities/basic/basic_song.dart';
import '../entities/pms/pms_detail_song.dart';
import '../entities/pms/pms_song.dart';
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
  late MyAppState _appState;

  void _removeSongFromLibrary(BuildContext context, MyAppState appState) async {
    appState.rawOpenedLibrary!.itemCount -= 1;
    appState.rawSongsInLibrary!.remove(widget.song);
    appState.searchedSongs.remove(widget.song);
    await appState.removeSongsFromLibrary(
        [widget.song], appState.openedLibrary!, appState.currentPlatform);
    appState.refreshLibraries!(appState, true);
    appState.refreshDetailLibraryPage!(appState);
  }

  void _pushToDetailSongPage() async {
    print('song\'s detail');
    _appState.isSongsPlayerPageOpened = false;
    var currentPlatform = _appState.currentPlatform;
    if (currentPlatform == 0) {
      int songType = (widget.song as PMSSong).type;
      PMSDetailSong? pmsDetailSong =
          await _appState.fetchDetailSong<PMSDetailSong>(widget.song, 0);
      if (songType == 1 || songType == 2) {
        if (mounted) {
          Navigator.popAndPushNamed(context, '/detail_song_page',
              arguments: pmsDetailSong!.basicSong);
        }
      } else if (songType == 3) {
        _appState.currentResource = pmsDetailSong!.biliResource;
        if (mounted) {
          Navigator.popAndPushNamed(context, '/detail_resource_page');
        }
      } else {
        throw 'Invalid song type';
      }
    } else {
      if (mounted) {
        Navigator.popAndPushNamed(context, '/detail_song_page',
            arguments: widget.song);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    _appState = state;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    _appState = appState;
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
            if (appState.currentPlatform != 0)
              InkWell(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
                onTap: () {
                  Navigator.pop(context, 'Add to pms');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.playlist_add_rounded),
                        color: colorScheme.tertiary,
                        onPressed: () {
                          Navigator.pop(context, 'Add to pms');
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
                Navigator.pop(context, 'Add to library');
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
                if (widget.song is PMSSong &&
                    (widget.song as PMSSong).type == 3) {
                  _pushToDetailSongPage();
                } else {
                  Navigator.popAndPushNamed(context, '/related_videos_page',
                      arguments: widget.song);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.ondemand_video_rounded),
                      color: colorScheme.tertiary,
                      onPressed: () {
                        if (widget.song is PMSSong &&
                            (widget.song as PMSSong).type == 3) {
                          _pushToDetailSongPage();
                        } else {
                          Navigator.popAndPushNamed(
                              context, '/related_videos_page',
                              arguments: widget.song);
                        }
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
                appState.isSongsPlayerPageOpened = false;
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
                        appState.isSongsPlayerPageOpened = false;
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
            if (!(widget.song is PMSSong && (widget.song as PMSSong).type == 3))
              InkWell(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
                onTap: _pushToDetailSongPage,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.description_rounded),
                        color: colorScheme.tertiary,
                        onPressed: _pushToDetailSongPage,
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
