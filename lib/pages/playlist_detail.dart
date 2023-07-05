import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/retry.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:playlistmaster/entities/detail_playlist.dart';
import 'package:playlistmaster/entities/playlist.dart';
import 'package:playlistmaster/http/api.dart';
import 'package:http/http.dart' as http;
import 'package:playlistmaster/http/my_http.dart';
import 'package:playlistmaster/mock_data.dart';
import 'package:playlistmaster/states/app_state.dart';
import 'package:playlistmaster/states/my_search_state.dart';
import 'package:playlistmaster/utils/my_logger.dart';
import 'package:playlistmaster/utils/my_toast.dart';
import 'package:playlistmaster/utils/theme_manager.dart';
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

  Future<DetailPlaylist?> fetchDetailPlaylist(Playlist playlist) async {
    DefaultCacheManager cacheManager = MyHttp.cacheManager;
    Uri url = Uri.http(
      API.host,
      '${API.detailPlaylist}/${playlist.tid}/1',
    );
    String urlString = url.toString();
    dynamic result = await cacheManager.getFileFromMemory(urlString);
    if (result == null || !(result as FileInfo).file.existsSync()) {
      result = await cacheManager.getFileFromCache(urlString);
      if (result == null || !(result as FileInfo).file.existsSync()) {
        MyLogger.logger.d('Loading detail playlist from network...');
        final client = RetryClient(http.Client());
        try {
          var response = await client.get(url);
          var decodedResponse =
              jsonDecode(utf8.decode(response.bodyBytes)) as Map;
          if (response.statusCode == 200 &&
              decodedResponse['success'] == true) {
            result = DetailPlaylist.fromJson(decodedResponse['data']);
            await cacheManager.putFile(
              urlString,
              response.bodyBytes,
              fileExtension: 'json',
            );
          } else if (response.statusCode == 200 &&
              decodedResponse['success'] == false) {
            MyToast.showToast('Request failure, tid is 0');
            MyLogger.logger.e('Request failure, tid is 0');

            DetailPlaylist detailPlaylist = DetailPlaylist(
              name: playlist.name,
              coverImage: playlist.coverImage,
              songsCount: playlist.songsCount,
              listenNum: 0,
              dirId: playlist.dirId,
              tid: playlist.tid,
              songs: [],
            );
            result = detailPlaylist;
            decodedResponse['data'] = detailPlaylist.toJson();
            String jsonString = jsonEncode(decodedResponse);
            List<int> bodyBytes = utf8.encode(jsonString);
            Uint8List uint8List = Uint8List.fromList(bodyBytes);
            await cacheManager.putFile(
              urlString,
              uint8List,
              fileExtension: 'json',
            );
          } else {
            MyToast.showToast(
                'Response error with code: ${response.statusCode}');
            MyLogger.logger
                .e('Response error with code: ${response.statusCode}');
            result = null;
          }
        } catch (e) {
          MyToast.showToast('Exception thrown: $e');
          MyLogger.logger.e('Network error with exception: $e');
          rethrow;
        } finally {
          client.close();
        }
      } else {
        MyLogger.logger.d('Loading detail playlist from cache...');
      }
    } else {
      MyLogger.logger.d('Loading detail playlist from memory...');
    }
    if (result is DetailPlaylist) {
      result = Future.value(result);
    } else if (result is FileInfo) {
      var decodedResponse =
          jsonDecode(utf8.decode(result.file.readAsBytesSync())) as Map;
      result = DetailPlaylist.fromJson(decodedResponse['data']);
      result = Future.value(result);
    } else {}
    return result;
  }

  @override
  void initState() {
    super.initState();
    // _songs = _detailPlaylist.songs;
    final state = Provider.of<MyAppState>(context, listen: false);
    var isUsingMockData = state.isUsingMockData;
    var openedPlaylist = state.openedPlaylist;
    var rawQueue = state.rawQueue;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      state.rawQueue = null;
    });
    // _tid = ModalRoute.of(context)!.settings.arguments as String;
    if (isUsingMockData) {
      _detailPlaylist = Future.value(MockData.detailPlaylist);
    } else {
      _detailPlaylist = fetchDetailPlaylist(openedPlaylist!);
    }
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    var isUsingMockData = appState.isUsingMockData;
    var openedPlaylist = appState.openedPlaylist;
    var player = appState.player;
    var currentPlayingSongInQueue = appState.currentPlayingSongInQueue;
    var ownerDirIdOfCurrentPlayingSong =
        appState.ownerDirIdOfCurrentPlayingSong;
    var rawQueue = appState.rawQueue;

    return Consumer<ThemeNotifier>(
      builder: (context, theme, _) => Material(
        child: Scaffold(
          key: _scaffoldKey,
          body: SafeArea(
            child: ChangeNotifierProvider(
              create: (context) => MySearchState(),
              child: Column(
                children: [
                  Container(
                    color: colorScheme.primary,
                    child: MySearchBar(
                      myScaffoldKey: _scaffoldKey,
                      notInHomepage: true,
                      inPlaylistDetailPage: true,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: theme.playlistDetailPageBg!,
                          stops: [0.0, 0.33, 0.67, 1.0],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              margin:
                                  EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
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
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SelectableText(
                                              'Exception: ${snapshot.error}',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontFamily: 'Roboto',
                                                fontSize: 16.0,
                                              ),
                                            ),
                                            TextButton.icon(
                                              style: ButtonStyle(
                                                shadowColor:
                                                    MaterialStateProperty.all(
                                                  colorScheme.primary,
                                                ),
                                                overlayColor:
                                                    MaterialStateProperty.all(
                                                  Colors.grey,
                                                ),
                                              ),
                                              icon: Icon(MdiIcons.webRefresh),
                                              label: Text(
                                                'Retry',
                                                style: textTheme.labelMedium,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _detailPlaylist =
                                                      fetchDetailPlaylist(
                                                          openedPlaylist!);
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      DetailPlaylist detailPlaylist =
                                          snapshot.data as DetailPlaylist;
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 130.0,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(15.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        right: 12.0,
                                                      ),
                                                      child: Container(
                                                        width: 100.0,
                                                        height: 100.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            4.0,
                                                          ),
                                                        ),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            print(appState);
                                                            setState(() {});
                                                          },
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4.0),
                                                            child:
                                                                isUsingMockData
                                                                    ? Image.asset(
                                                                        detailPlaylist
                                                                            .coverImage)
                                                                    : CachedNetworkImage(
                                                                        imageUrl: detailPlaylist.coverImage.isNotEmpty
                                                                            ? detailPlaylist.coverImage
                                                                            : MyAppState.defaultCoverImage,
                                                                        progressIndicatorBuilder: (context,
                                                                                url,
                                                                                downloadProgress) =>
                                                                            CircularProgressIndicator(value: downloadProgress.progress),
                                                                        errorWidget: (context,
                                                                                url,
                                                                                error) =>
                                                                            Icon(MdiIcons.debian),
                                                                      ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SelectableText(
                                                            detailPlaylist.name,
                                                            style: textTheme
                                                                .labelLarge!
                                                                .copyWith(
                                                                    fontSize:
                                                                        20.0),
                                                            // overflow: TextOverflow
                                                            //     .ellipsis,
                                                          ),
                                                          Text(
                                                            '${detailPlaylist.songsCount} songs',
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: textTheme
                                                                .titleSmall,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top:
                                                                          12.0),
                                                              child: Text(
                                                                detailPlaylist
                                                                    .description!,
                                                                style: textTheme
                                                                    .labelLarge!
                                                                    .copyWith(
                                                                        fontSize:
                                                                            10.0),
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
                                              child:
                                                  detailPlaylist.songsCount != 0
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
                                                                    onPressed:
                                                                        () {},
                                                                    icon: Icon(
                                                                      Icons
                                                                          .playlist_play_rounded,
                                                                    ),
                                                                    color: colorScheme
                                                                        .tertiary,
                                                                  ),
                                                                  IconButton(
                                                                    onPressed:
                                                                        () {},
                                                                    icon: Icon(
                                                                      Icons
                                                                          .playlist_add_check_rounded,
                                                                    ),
                                                                    color: colorScheme
                                                                        .tertiary,
                                                                  ),
                                                                  IconButton(
                                                                    onPressed:
                                                                        () {},
                                                                    icon: Icon(
                                                                      Icons
                                                                          .more_vert_rounded,
                                                                    ),
                                                                    color: colorScheme
                                                                        .tertiary,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: ListView
                                                                  .builder(
                                                                // TODO: fix this. Mock.songs have 10 songs only.
                                                                // itemCount: _detailPlaylist.songsCount,
                                                                itemCount: isUsingMockData
                                                                    ? min(
                                                                        detailPlaylist
                                                                            .songsCount,
                                                                        10)
                                                                    : detailPlaylist
                                                                        .songsCount,
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  return Material(
                                                                    color: Colors
                                                                        .transparent,
                                                                    child:
                                                                        InkWell(
                                                                      // TODO: fix bug: the init cover will be wrong sometimes when first loading
                                                                      // song player in shuffle mode.
                                                                      onTap:
                                                                          () async {
                                                                        // TODO: fix this, the songs should be real data.

                                                                        // Init audio player when no player instance exist, otherwise
                                                                        // update the queue only.

                                                                        if (appState.player ==
                                                                            null) {
                                                                          appState.queue =
                                                                              detailPlaylist.songs;

                                                                          appState.rawQueue =
                                                                              detailPlaylist.songs;

                                                                          await appState
                                                                              .initAudioPlayer();

                                                                          if (true) {
                                                                            bool
                                                                                hasValidSong =
                                                                                false;
                                                                            if (index ==
                                                                                -1) {
                                                                              index = 0;
                                                                              MyToast.showToast('This song is taken down.');
                                                                            }
                                                                            for (int i = index;
                                                                                i < index + detailPlaylist.songsCount;
                                                                                i++) {
                                                                              if (appState.rawQueue![i % detailPlaylist.songsCount].isTakenDown) {
                                                                                continue;
                                                                              }
                                                                              hasValidSong = true;
                                                                              index = appState.queue!.indexOf(appState.rawQueue![i % detailPlaylist.songsCount]);
                                                                              break;
                                                                            }

                                                                            if (!hasValidSong) {
                                                                              MyToast.showToast('All songs in playlist is taken down.');
                                                                              return;
                                                                            }
                                                                          }

                                                                          appState.canSongPlayerPagePop =
                                                                              true;

                                                                          appState.currentPlayingSongInQueue =
                                                                              index;

                                                                          appState.currentSong =
                                                                              appState.queue![index];

                                                                          appState.prevSong =
                                                                              appState.currentSong;

                                                                          appState.currentDetailSong =
                                                                              null;

                                                                          // appState.currentPage =
                                                                          //     '/song_player';
                                                                          appState.ownerDirIdOfCurrentPlayingSong =
                                                                              detailPlaylist.dirId;

                                                                          appState.isFirstLoadSongPlayer =
                                                                              true;

                                                                          // appState.player!
                                                                          //     .seek(
                                                                          //         Duration
                                                                          //             .zero,
                                                                          //         index:
                                                                          //             index);
                                                                          appState
                                                                              .player!
                                                                              .play();
                                                                        } else if (ownerDirIdOfCurrentPlayingSong == openedPlaylist!.dirId &&
                                                                            (index = appState.queue!.indexOf(appState.rawQueue![index])) ==
                                                                                currentPlayingSongInQueue) {
                                                                          if (!player!
                                                                              .playerState
                                                                              .playing) {
                                                                            player.play();
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

                                                                          appState.queue =
                                                                              detailPlaylist.songs;

                                                                          appState.rawQueue =
                                                                              detailPlaylist.songs;

                                                                          await appState
                                                                              .initAudioPlayer();

                                                                          if (true) {
                                                                            bool
                                                                                hasValidSong =
                                                                                false;
                                                                            if (index ==
                                                                                -1) {
                                                                              index = 0;
                                                                              MyToast.showToast('This song is taken down.');
                                                                            }
                                                                            for (int i = index;
                                                                                i < index + detailPlaylist.songsCount;
                                                                                i++) {
                                                                              if (appState.rawQueue![i % detailPlaylist.songsCount].isTakenDown) {
                                                                                continue;
                                                                              }
                                                                              hasValidSong = true;
                                                                              index = appState.queue!.indexOf(appState.rawQueue![i % detailPlaylist.songsCount]);
                                                                              break;
                                                                            }

                                                                            if (!hasValidSong) {
                                                                              MyToast.showToast('All songs in playlist is taken down.');
                                                                              return;
                                                                            }
                                                                          }

                                                                          appState.ownerDirIdOfCurrentPlayingSong =
                                                                              detailPlaylist.dirId;

                                                                          appState.currentPlayingSongInQueue =
                                                                              index;

                                                                          appState.currentSong =
                                                                              appState.queue![index];

                                                                          appState.currentDetailSong =
                                                                              null;

                                                                          appState.prevSong =
                                                                              appState.currentSong;
                                                                          // appState.currentPage =
                                                                          //     '/song_player';
                                                                          appState.isFirstLoadSongPlayer =
                                                                              true;

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
                                                                      child:
                                                                          SongItem(
                                                                        index:
                                                                            index,
                                                                        song: rawQueue ==
                                                                                null
                                                                            ? detailPlaylist.songs[index]
                                                                            : appState.rawQueue![index],
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
                                                              shadowColor:
                                                                  MaterialStateProperty
                                                                      .all(
                                                                colorScheme
                                                                    .primary,
                                                              ),
                                                              overlayColor:
                                                                  MaterialStateProperty
                                                                      .all(
                                                                Colors.grey,
                                                              ),
                                                            ),
                                                            child: Text(
                                                              'Add songs',
                                                              style: textTheme
                                                                  .labelMedium,
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
      ),
    );
  }
}
