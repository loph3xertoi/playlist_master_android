import 'package:flutter/material.dart';
import 'package:playlistmaster/entities/playlist.dart';
import 'package:playlistmaster/mock_data.dart';
import 'package:playlistmaster/widgets/create_playlist_popup.dart';
import 'package:playlistmaster/widgets/playlist_item.dart';

class MyContentArea extends StatefulWidget {
  @override
  State<MyContentArea> createState() => _MyContentAreaState();
}

class _MyContentAreaState extends State<MyContentArea> {
  List<Playlist> _playlists = MockData.playlists;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      // height: 587.0,
      child: Column(
        children: [
          SizedBox(
            height: 40.0,
            child: Row(children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 13.0),
                  child: Text(
                    'Create Playlists (${_playlists.length})',
                    style: TextStyle(
                      fontSize: 12.0,
                      letterSpacing: 0.25,
                      color: Color(0x59000000),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.library_add_rounded),
                    color: Color(0x42000000),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (_) => CreatePlaylistDialog());
                    },
                  ),
                  IconButton(
                    color: Color(0x42000000),
                    icon: Icon(Icons.more_vert_rounded),
                    onPressed: () {
                      // Add your search icon onPressed logic here
                    },
                  ),
                ],
              ),
            ]),
          ),
          Expanded(
            child: _playlists.isNotEmpty
                ? ListView.builder(
                    itemCount: _playlists.length,
                    itemBuilder: (context, index) {
                      return PlaylistItem(
                        playlist: _playlists[index],
                      );
                    },
                  )
                : Center(child: Text('Empty Playlists')),
          ),
        ],
      ),
    );
  }
}
