import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:playlistmaster/entities/playlist.dart';
import 'package:playlistmaster/states/app_state.dart';
import 'package:provider/provider.dart';

class PlaylistItem extends StatelessWidget {
  final Playlist playlist;
  const PlaylistItem({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    var isUsingMockData = appState.isUsingMockData;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          appState.rawOpenedPlaylist = playlist;
          appState.openedPlaylist = playlist;
          appState.rawQueue = [];
          Navigator.pushNamed(
            context,
            '/playlist_detail',
          );
        },
        child: Ink(
          height: 60.0,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(13.0, 7.0, 0.0, 7.0),
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: SizedBox(
                    width: 46.0,
                    height: 46.0,
                    child: isUsingMockData
                        ? Image.asset(playlist.coverImage)
                        : CachedNetworkImage(
                            imageUrl: playlist.coverImage.isNotEmpty
                                ? playlist.coverImage
                                : MyAppState.defaultPlaylistCover,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                            errorWidget: (context, url, error) =>
                                Icon(MdiIcons.debian),
                          ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 7.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            playlist.name,
                            style:
                                textTheme.labelSmall!.copyWith(fontSize: 13.0),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${playlist.songsCount} songs',
                          style: textTheme.labelSmall!.copyWith(fontSize: 11.0),
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuButton(
                  color: colorScheme.tertiary,
                  shadowColor: Colors.transparent,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      child: Text(
                        'Option 1',
                        style: textTheme.labelSmall,
                      ),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Text(
                        'Option 2',
                        style: textTheme.labelSmall,
                      ),
                    ),
                    PopupMenuItem(
                      value: 3,
                      child: Text(
                        'Option 3',
                        style: textTheme.labelSmall,
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    // Handle selection in the popup menu
                  },
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
