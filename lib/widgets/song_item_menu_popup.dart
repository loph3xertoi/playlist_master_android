import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../entities/basic/basic_song.dart';
import '../entities/qq_music/qqmusic_playlist.dart';
import '../states/app_state.dart';

class CreateSongItemMenuDialog extends StatelessWidget {
  final BasicSong song;
  CreateSongItemMenuDialog({required this.song});

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
                print('add to library');
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
            (appState.currentPlatform == 1 &&
                    appState.openedLibrary!.itemCount > 0)
                ? InkWell(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    onTap: () {
                      print('Remove from library.');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.playlist_remove_rounded),
                            color: colorScheme.tertiary,
                            onPressed: () {
                              print('Remove from library.');
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
                    arguments: song);
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
                            arguments: song);
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
                appState.openedLibrary = BasicLibrary(
                  name: 'similar song',
                  cover: '',
                  itemCount: -1,
                );
                Navigator.popAndPushNamed(context, '/similar_songs_page',
                    arguments: song);
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
                        appState.openedLibrary = BasicLibrary(
                          name: 'similar song',
                          cover: '',
                          itemCount: -1,
                        );
                        Navigator.popAndPushNamed(
                            context, '/similar_songs_page',
                            arguments: song);
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
                    arguments: song);
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
                            arguments: song);
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
