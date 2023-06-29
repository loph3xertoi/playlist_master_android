import 'package:flutter/material.dart';
import 'package:playlistmaster/entities/playlist.dart';

class PlaylistItem extends StatelessWidget {
  final Playlist playlist;
  const PlaylistItem({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/playlist_detail', arguments: playlist.tid);
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
                    child: Image.asset(playlist.coverImage),
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
                        Text(
                          playlist.name,
                          style: TextStyle(
                            fontSize: 12.0,
                            letterSpacing: 0.25,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          '${playlist.songsCount} songs',
                          style: TextStyle(
                            fontSize: 11.0,
                            letterSpacing: 0.25,
                            color: Color(0x42000000),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuButton(
                  color: Color(0x42000000),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      child: Text('Option 1'),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Text('Option 2'),
                    ),
                    PopupMenuItem(
                      value: 3,
                      child: Text('Option 3'),
                    ),
                  ],
                  onSelected: (value) {
                    // Handle selection in the popup menu
                  },
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
