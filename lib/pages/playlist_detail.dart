import 'dart:math';

import 'package:flutter/material.dart';
import 'package:playlistmaster/entities/playlist.dart';
import 'package:playlistmaster/mock_data.dart';
import 'package:playlistmaster/widgets/song_item.dart';
import 'package:provider/provider.dart';

import '../entities/song.dart';
import '../states/my_search_state.dart';
import '../widgets/my_searchbar.dart';

class PlaylistDetailPage extends StatefulWidget {
  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Song> songs = MockData.songs;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Playlist playlist =
        ModalRoute.of(context)!.settings.arguments as Playlist;
    return Material(
      child: Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: ChangeNotifierProvider(
            create: (context) => MySearchState(),
            child: Column(
              children: [
                MySearchBar(
                  myScaffoldKey: _scaffoldKey,
                  notInHomepage: true,
                  inPlaylistDetailPage: true,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1B3142),
                          Color(0xFF355467),
                          Color(0xFF5E777A),
                          Color(0xFFCE8B46),
                        ],
                        stops: [0.0, 0.33, 0.67, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 130.0,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 12.0,
                                      ),
                                      child: Image.asset(playlist.coverImage),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            playlist.name,
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              height: 1.0,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${playlist.songsCount} songs',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontSize: 11.0,
                                              color: Color(0x42000000),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 12.0),
                                              child: Text(
                                                playlist.description!,
                                                style: TextStyle(
                                                  fontSize: 13.0,
                                                  color: Color(0xBF000000),
                                                  height: 1.2,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: playlist.songsCount != 0
                                  ? Column(
                                      children: [
                                        SizedBox(
                                          height: 40.0,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                onPressed: () {},
                                                icon: Icon(
                                                  Icons.playlist_play_rounded,
                                                ),
                                                color: Color(0x42000000),
                                              ),
                                              IconButton(
                                                onPressed: () {},
                                                icon: Icon(
                                                  Icons
                                                      .playlist_add_check_rounded,
                                                ),
                                                color: Color(0x42000000),
                                              ),
                                              IconButton(
                                                onPressed: () {},
                                                icon: Icon(
                                                  Icons.more_vert_rounded,
                                                ),
                                                color: Color(0x42000000),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: ListView.builder(
                                            // TODO: fix this. Mock.songs have 10 songs only.
                                            // itemCount: playlist.songsCount,
                                            itemCount:
                                                min(playlist.songsCount, 10),
                                            itemBuilder: (context, index) {
                                              return Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/song_player',
                                                      arguments: {
                                                        'index': index,
                                                        'songs': songs,
                                                      },
                                                    );
                                                  },
                                                  child: SongItem(
                                                    index: index,
                                                    song: songs[index],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      ],
                                    )
                                  : Center(
                                      child: TextButton(
                                        onPressed: () {},
                                        style: ButtonStyle(
                                            overlayColor:
                                                MaterialStateProperty.all(
                                              Colors.grey,
                                            ),
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                              Colors.white,
                                            )),
                                        child: Text(
                                          'Add songs',
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
