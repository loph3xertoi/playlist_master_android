import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/retry.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:playlistmaster/entities/detail_playlist.dart';
import 'package:playlistmaster/entities/playlist.dart';
import 'package:playlistmaster/entities/song.dart';
import 'package:playlistmaster/http/api.dart';
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
  bool _changeRawQueue = true;

  @override
  void initState() {
    super.initState();
    // _songs = _detailPlaylist.songs;
    final state = Provider.of<MyAppState>(context, listen: false);
    var isUsingMockData = state.isUsingMockData;
    var openedPlaylist = state.rawOpenedPlaylist;
    // var rawQueue = state.rawQueue;
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   state.rawQueue = null;
    // });
    // _tid = ModalRoute.of(context)!.settings.arguments as String;
    if (isUsingMockData) {
      _detailPlaylist = Future.value(MockData.detailPlaylist);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        state.rawQueue = MockData.songs;
        state.queue = MockData.songs;
        state.openedPlaylist = state.rawOpenedPlaylist;
      });
    } else {
      _detailPlaylist = state.fetchDetailPlaylist(openedPlaylist!);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build playlist detail');
    MyAppState appState = context.watch<MyAppState>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    var isUsingMockData = appState.isUsingMockData;
    var openedPlaylist = appState.rawOpenedPlaylist;
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
                                                style: textTheme.labelMedium!
                                                    .copyWith(
                                                  color: colorScheme.primary,
                                                ),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _detailPlaylist = appState
                                                      .fetchDetailPlaylist(
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
                                      rawQueue = detailPlaylist.songs;
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        if (appState.rawQueue!.isEmpty ||
                                            _changeRawQueue) {
                                          appState.rawQueue =
                                              detailPlaylist.songs;
                                          _changeRawQueue = false;
                                        }
                                      });

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
                                                          Row(
                                                            children: [
                                                              Text(
                                                                '${detailPlaylist.songsCount} songs',
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: textTheme
                                                                    .titleSmall,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                              SizedBox(
                                                                width: 10.0,
                                                                child: Text(
                                                                  '|',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    color: colorScheme
                                                                        .onSecondary,
                                                                  ),
                                                                ),
                                                              ),
                                                              Text(
                                                                '${detailPlaylist.listenNum} listened',
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: textTheme
                                                                    .titleSmall,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ],
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
                                                                        if (rawQueue![index].payPlay ==
                                                                            1) {
                                                                          MyToast.showToast(
                                                                              'This song need vip to play');
                                                                          MyLogger
                                                                              .logger
                                                                              .e('This song need vip to play');
                                                                        } else if (rawQueue![index]
                                                                            .isTakenDown) {
                                                                          MyToast.showToast(
                                                                              'This song is taken down');
                                                                          MyLogger
                                                                              .logger
                                                                              .e('This song is taken down');
                                                                        } else {
                                                                          if (appState.player ==
                                                                              null) {
                                                                            appState.queue =
                                                                                detailPlaylist.songs.where((song) => !song.isTakenDown && (song.payPlay == 0)).toList();

                                                                            // Real index in queue, not in raw queue as some songs may be taken down.
                                                                            int realIndex =
                                                                                appState.queue!.indexOf(appState.rawQueue![index]);

                                                                            try {
                                                                              await appState.initAudioPlayer();
                                                                            } catch (e) {
                                                                              MyToast.showToast('Exception: $e');
                                                                              MyLogger.logger.e('Exception: $e');
                                                                              appState.queue = [];
                                                                              appState.currentDetailSong = null;
                                                                              appState.currentPlayingSongInQueue = 0;
                                                                              appState.currentSong = null;
                                                                              appState.prevSong = null;
                                                                              appState.isPlaying = false;
                                                                              appState.player!.stop();
                                                                              appState.player!.dispose();
                                                                              appState.player = null;
                                                                              appState.initQueue!.clear();
                                                                              appState.isPlayerPageOpened = false;
                                                                              appState.canSongPlayerPagePop = false;
                                                                              return;
                                                                            }

                                                                            appState.canSongPlayerPagePop =
                                                                                true;

                                                                            appState.currentPlayingSongInQueue =
                                                                                realIndex;

                                                                            appState.currentSong =
                                                                                appState.queue![realIndex];

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
                                                                            appState.player!.play();
                                                                          } else if (ownerDirIdOfCurrentPlayingSong == openedPlaylist!.dirId &&
                                                                              appState.queue!.indexOf(appState.rawQueue![index]) == currentPlayingSongInQueue) {
                                                                            if (!player!.playerState.playing) {
                                                                              player.play();
                                                                            }
                                                                          } else {
                                                                            appState.queue =
                                                                                detailPlaylist.songs.where((song) => !song.isTakenDown && (song.payPlay == 0)).toList();

                                                                            // Real index in queue, not in raw queue as some songs may be taken down.
                                                                            int realIndex =
                                                                                appState.queue!.indexOf(appState.rawQueue![index]);

                                                                            print(realIndex);

                                                                            appState.canSongPlayerPagePop =
                                                                                true;

                                                                            appState.player!.stop();

                                                                            appState.player!.dispose();

                                                                            appState.player =
                                                                                null;

                                                                            appState.initQueue!.clear();

                                                                            try {
                                                                              await appState.initAudioPlayer();
                                                                            } catch (e) {
                                                                              MyToast.showToast('Exception: $e');
                                                                              MyLogger.logger.e('Exception: $e');
                                                                              appState.queue = [];
                                                                              appState.currentDetailSong = null;
                                                                              appState.currentPlayingSongInQueue = 0;
                                                                              appState.currentSong = null;
                                                                              appState.prevSong = null;
                                                                              appState.isPlaying = false;
                                                                              appState.player!.stop();
                                                                              appState.player!.dispose();
                                                                              appState.player = null;
                                                                              appState.initQueue!.clear();
                                                                              appState.isPlayerPageOpened = false;
                                                                              appState.canSongPlayerPagePop = false;
                                                                              return;
                                                                            }

                                                                            appState.ownerDirIdOfCurrentPlayingSong =
                                                                                detailPlaylist.dirId;

                                                                            appState.currentPlayingSongInQueue =
                                                                                realIndex;

                                                                            appState.currentSong =
                                                                                appState.queue![realIndex];

                                                                            appState.currentDetailSong =
                                                                                null;

                                                                            appState.prevSong =
                                                                                appState.currentSong;
                                                                            // appState.currentPage =
                                                                            //     '/song_player';
                                                                            appState.isFirstLoadSongPlayer =
                                                                                true;

                                                                            appState.player!.play();
                                                                          }
                                                                          appState.isPlayerPageOpened =
                                                                              true;
                                                                          if (context
                                                                              .mounted) {
                                                                            Navigator.pushNamed(context,
                                                                                '/song_player');
                                                                          }
                                                                        }
                                                                      },
                                                                      child:
                                                                          SongItem(
                                                                        index:
                                                                            index,
                                                                        dirId: detailPlaylist
                                                                            .dirId,
                                                                        song: rawQueue![
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
                          appState.currentSong == null
                              ? Container()
                              : BottomPlayer(),
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
