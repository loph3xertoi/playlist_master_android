import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:playlistmaster/entities/detail_playlist.dart';
import 'package:playlistmaster/entities/playlist.dart';
import 'package:playlistmaster/entities/song.dart';
import 'package:playlistmaster/http/api.dart';
import 'package:http/http.dart' as http;
import 'package:playlistmaster/mock_data.dart';
import 'package:playlistmaster/states/app_state.dart';
import 'package:playlistmaster/states/my_search_state.dart';
import 'package:playlistmaster/widgets/bottom_player.dart';
import 'package:playlistmaster/widgets/my_searchbar.dart';
import 'package:playlistmaster/widgets/song_item.dart';
import 'package:provider/provider.dart';

class PlaylistDetailPage extends StatefulWidget {
  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DetailPlaylist _detailPlaylist = MockData.detail_playlist;

  late List<Song> _songs;
  late String _tid;

  @override
  void initState() {
    super.initState();
    _songs = _detailPlaylist.songs;
    // _tid = ModalRoute.of(context)!.settings.arguments as String;
    // var url = Uri.http(
    //   '192.168.8.171:8080',
    //   '${API.detailPlaylist}/$_tid/1',
    //   // {'id': '2804161589'},
    // );
    // var response = await http.get(url);
    // var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    // print(decodedResponse);
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();

    var openedPlaylistDirId = appState.openedPlaylistDirId;
    var player = appState.player;
    var currentPlayingSongInQueue = appState.currentPlayingSongInQueue;

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
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
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
                                            child: Image.asset(
                                                _detailPlaylist.coverImage),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _detailPlaylist.name,
                                                  style: TextStyle(
                                                    fontSize: 20.0,
                                                    height: 1.0,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  '${_detailPlaylist.songsCount} songs',
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    fontSize: 11.0,
                                                    color: Color(0x42000000),
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 12.0),
                                                    child: Text(
                                                      _detailPlaylist
                                                          .description!,
                                                      style: TextStyle(
                                                        fontSize: 13.0,
                                                        color:
                                                            Color(0xBF000000),
                                                        height: 1.2,
                                                      ),
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                    child: _detailPlaylist.songsCount != 0
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
                                                        Icons
                                                            .playlist_play_rounded,
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
                                                  // itemCount: _detailPlaylist.songsCount,
                                                  itemCount: min(
                                                      _detailPlaylist
                                                          .songsCount,
                                                      10),
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        // TODO: fix bug: the init cover will be wrong sometimes when first loading
                                                        // song player in shuffle mode.
                                                        onTap: () async {
                                                          // TODO: fix this, the songs should be real data.

                                                          // Init audio player when no player instance exist, otherwise
                                                          // update the queue only.
                                                          if (appState.player ==
                                                              null) {
                                                            appState.canSongPlayerPagePop =
                                                                true;
                                                            appState.openedPlaylistDirId =
                                                                _detailPlaylist
                                                                    .dirId;
                                                            appState.songsOfPlaylist =
                                                                _songs;
                                                            appState.queue =
                                                                _songs;
                                                            appState.currentPlayingSongInQueue =
                                                                index;
                                                            appState.currentSong =
                                                                appState.queue![
                                                                    index];
                                                            appState.currentPage =
                                                                '/song_player';
                                                            appState.isFirstLoadSongPlayer =
                                                                true;
                                                            await appState
                                                                .initAudioPlayer();
                                                            // appState.player!
                                                            //     .seek(
                                                            //         Duration
                                                            //             .zero,
                                                            //         index:
                                                            //             index);
                                                            appState.player!
                                                                .play();
                                                          } else if (_detailPlaylist
                                                                      .dirId ==
                                                                  openedPlaylistDirId &&
                                                              index ==
                                                                  currentPlayingSongInQueue &&
                                                              appState.queue!
                                                                      .length ==
                                                                  appState
                                                                      .songsOfPlaylist!
                                                                      .length) {
                                                            if (!player!
                                                                .playerState
                                                                .playing) {
                                                              player.play();
                                                            }
                                                          } else {
                                                            appState.queue = [];
                                                            appState.player!
                                                                .stop();
                                                            appState.player!
                                                                .dispose();
                                                            appState.player =
                                                                null;
                                                            appState.initQueue!
                                                                .clear();

                                                            appState.openedPlaylistDirId =
                                                                _detailPlaylist.dirId;
                                                            appState.songsOfPlaylist =
                                                                _songs;
                                                            appState.queue =
                                                                _songs;
                                                            appState.currentPlayingSongInQueue =
                                                                index;
                                                            appState.currentSong =
                                                                appState.queue![
                                                                    index];
                                                            appState.currentPage =
                                                                '/song_player';
                                                            appState.isFirstLoadSongPlayer =
                                                                true;
                                                            await appState
                                                                .initAudioPlayer();
                                                            // appState.player!
                                                            //     .seek(
                                                            //         Duration
                                                            //             .zero,
                                                            //         index:
                                                            //             index);
                                                            appState.player!
                                                                .play();
                                                            // appState.openedPlaylist =
                                                            //     playlist;
                                                            // appState.songsOfPlaylist =
                                                            //     songs;
                                                            // appState.currentPlayingSongInQueue =
                                                            //     index;
                                                            // appState.currentPage =
                                                            //     '/song_player';

                                                            // appState.queue =
                                                            //     songs;

                                                            // appState.initQueue!
                                                            //     .clear();

                                                            // appState.initQueue!
                                                            //     .addAll(appState
                                                            //         .queue!
                                                            //         .map(
                                                            //           (e) => AudioSource
                                                            //               .asset(
                                                            //                   e.link),
                                                            //         )
                                                            //         .toList());

                                                            // if (!player!
                                                            //     .playerState
                                                            //     .playing) {
                                                            //   player.play();
                                                            //   appState.isPlaying =
                                                            //       true;
                                                            // }
                                                            // appState.updateSong =
                                                            //     true;
                                                          }
                                                          appState.isPlayerPageOpened =
                                                              true;
                                                          Navigator.pushNamed(
                                                              context,
                                                              '/song_player');
                                                        },
                                                        child: SongItem(
                                                          index: index,
                                                          song: _songs[index],
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
                        appState.isQueueEmpty ? Container() : BottomPlayer(),
                      ],
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
