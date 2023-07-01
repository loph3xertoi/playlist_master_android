import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/retry.dart';
import 'package:playlistmaster/entities/detail_playlist.dart';
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
  late Future<DetailPlaylist?> _detailPlaylist;

  // late List<Song> _songs;
  // late String _tid;

  Future<DetailPlaylist?> fetchDetailPlaylist(String tid) async {
    var url = Uri.http(
      API.host,
      '${API.detailPlaylist}/$tid/1',
    );
    final client = RetryClient(http.Client());
    try {
      var response = await client.get(url);
      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        var detailPlaylist = decodedResponse['data'];
        return Future.value(DetailPlaylist.fromJson(detailPlaylist));
      } else {
        return null;
        // return Future.value(MockData.detailPlaylist);
      }
    } finally {
      client.close();
    }
  }

  @override
  void initState() {
    super.initState();
    // _songs = _detailPlaylist.songs;
    final state = Provider.of<MyAppState>(context, listen: false);
    var isUsingMockData = state.isUsingMockData;
    var openedPlaylist = state.openedPlaylist;
    // _tid = ModalRoute.of(context)!.settings.arguments as String;
    if (isUsingMockData) {
      _detailPlaylist = Future.value(MockData.detailPlaylist);
    } else {
      _detailPlaylist = fetchDetailPlaylist(openedPlaylist!.tid);
    }
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();

    var isUsingMockData = appState.isUsingMockData;
    var openedPlaylist = appState.openedPlaylist;
    var player = appState.player;
    var currentPlayingSongInQueue = appState.currentPlayingSongInQueue;
    var ownerDirIdOfCurrentPlayingSong =
        appState.ownerDirIdOfCurrentPlayingSong;

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
                            child: FutureBuilder(
                                future: _detailPlaylist,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Center(
                                      child: Text('Error: ${snapshot.error}'),
                                    );
                                  } else {
                                    DetailPlaylist detailPlaylist =
                                        snapshot.data as DetailPlaylist;
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 130.0,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      right: 12.0,
                                                    ),
                                                    child: isUsingMockData
                                                        ? Image.asset(
                                                            detailPlaylist
                                                                .coverImage)
                                                        : Image.network(
                                                            detailPlaylist
                                                                    .coverImage
                                                                    .isNotEmpty
                                                                ? detailPlaylist
                                                                    .coverImage
                                                                : MyAppState
                                                                    .defaultCoverImage),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          detailPlaylist.name,
                                                          style: TextStyle(
                                                            fontSize: 20.0,
                                                            height: 1.0,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Text(
                                                          '${detailPlaylist.songsCount} songs',
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: TextStyle(
                                                            fontSize: 11.0,
                                                            color: Color(
                                                                0x42000000),
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 12.0),
                                                            child: Text(
                                                              detailPlaylist
                                                                  .description!,
                                                              style: TextStyle(
                                                                fontSize: 13.0,
                                                                color: Color(
                                                                    0xBF000000),
                                                                height: 1.2,
                                                              ),
                                                              maxLines: 3,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
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
                                            child: detailPlaylist.songsCount !=
                                                    0
                                                ? Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 40.0,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            IconButton(
                                                              onPressed: () {},
                                                              icon: Icon(
                                                                Icons
                                                                    .playlist_play_rounded,
                                                              ),
                                                              color: Color(
                                                                  0x42000000),
                                                            ),
                                                            IconButton(
                                                              onPressed: () {},
                                                              icon: Icon(
                                                                Icons
                                                                    .playlist_add_check_rounded,
                                                              ),
                                                              color: Color(
                                                                  0x42000000),
                                                            ),
                                                            IconButton(
                                                              onPressed: () {},
                                                              icon: Icon(
                                                                Icons
                                                                    .more_vert_rounded,
                                                              ),
                                                              color: Color(
                                                                  0x42000000),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: ListView.builder(
                                                          // TODO: fix this. Mock.songs have 10 songs only.
                                                          // itemCount: _detailPlaylist.songsCount,
                                                          itemCount: min(
                                                              detailPlaylist
                                                                  .songsCount,
                                                              10),
                                                          itemBuilder:
                                                              (context, index) {
                                                            return Material(
                                                              color: Colors
                                                                  .transparent,
                                                              child: InkWell(
                                                                // TODO: fix bug: the init cover will be wrong sometimes when first loading
                                                                // song player in shuffle mode.
                                                                onTap:
                                                                    () async {
                                                                  // TODO: fix this, the songs should be real data.

                                                                  // Init audio player when no player instance exist, otherwise
                                                                  // update the queue only.
                                                                  if (appState
                                                                          .player ==
                                                                      null) {
                                                                    appState.canSongPlayerPagePop =
                                                                        true;

                                                                    appState.queue =
                                                                        detailPlaylist
                                                                            .songs;

                                                                    appState.currentPlayingSongInQueue =
                                                                        index;

                                                                    appState
                                                                        .currentSong = appState
                                                                            .queue![
                                                                        index];

                                                                    appState.prevSong =
                                                                        appState
                                                                            .currentSong;

                                                                    // appState.currentPage =
                                                                    //     '/song_player';
                                                                    appState.ownerDirIdOfCurrentPlayingSong =
                                                                        detailPlaylist
                                                                            .dirId;

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
                                                                    appState
                                                                        .player!
                                                                        .play();
                                                                  } else if (ownerDirIdOfCurrentPlayingSong ==
                                                                          openedPlaylist!
                                                                              .dirId &&
                                                                      index ==
                                                                          currentPlayingSongInQueue &&
                                                                      appState.queue!
                                                                              .length ==
                                                                          detailPlaylist
                                                                              .songsCount) {
                                                                    if (!player!
                                                                        .playerState
                                                                        .playing) {
                                                                      player
                                                                          .play();
                                                                    }
                                                                  } else {
                                                                    appState.canSongPlayerPagePop =
                                                                        true;

                                                                    appState.queue =
                                                                        [];

                                                                    appState
                                                                        .player!
                                                                        .stop();

                                                                    appState
                                                                        .player!
                                                                        .dispose();

                                                                    appState.player =
                                                                        null;

                                                                    appState
                                                                        .initQueue!
                                                                        .clear();

                                                                    appState.ownerDirIdOfCurrentPlayingSong =
                                                                        detailPlaylist
                                                                            .dirId;

                                                                    appState.queue =
                                                                        detailPlaylist
                                                                            .songs;

                                                                    appState.currentPlayingSongInQueue =
                                                                        index;

                                                                    appState
                                                                        .currentSong = appState
                                                                            .queue![
                                                                        index];

                                                                    appState.prevSong =
                                                                        appState
                                                                            .currentSong;
                                                                    // appState.currentPage =
                                                                    //     '/song_player';
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
                                                                    appState
                                                                        .player!
                                                                        .play();
                                                                  }
                                                                  appState.isPlayerPageOpened =
                                                                      true;
                                                                  Navigator.pushNamed(
                                                                      context,
                                                                      '/song_player');
                                                                },
                                                                child: SongItem(
                                                                  index: index,
                                                                  song: detailPlaylist
                                                                          .songs[
                                                                      index],
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
                                                              MaterialStateProperty
                                                                  .all(
                                                            Colors.grey,
                                                          ),
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(
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
                                    );
                                  }
                                }),
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
