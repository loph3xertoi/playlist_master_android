import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../entities/qq_music/qqmusic_detail_playlist.dart';
import '../mock_data.dart';
import '../states/app_state.dart';
import '../states/my_search_state.dart';
import '../utils/my_logger.dart';
import '../utils/my_toast.dart';
import '../utils/theme_manager.dart';
import '../widgets/bottom_player.dart';
import '../widgets/library_item_menu_popup.dart';
import '../widgets/multi_songs_select_popup.dart';
import '../widgets/my_searchbar.dart';
import '../widgets/song_item.dart';

class DetailLibraryPage extends StatefulWidget {
  @override
  State<DetailLibraryPage> createState() => _DetailLibraryPageState();
}

class _DetailLibraryPageState extends State<DetailLibraryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<BasicLibrary?> _detailLibrary;
  late MyAppState _appState;
  bool _changeRawQueue = true;

  void _refreshDetailLibraryPage(MyAppState appState) {
    setState(() {
      _detailLibrary = appState.fetchDetailLibrary(
          appState.openedLibrary!, appState.currentPlatform);
    });
  }

  @override
  void initState() {
    super.initState();
    // _songs = _detailLibrary.songs;
    final state = Provider.of<MyAppState>(context, listen: false);
    var isUsingMockData = state.isUsingMockData;
    var openedLibrary = state.rawOpenedLibrary;
    _appState = state;
    // var rawQueue = state.rawQueue;
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   state.rawQueue = null;
    // });
    // _tid = ModalRoute.of(context)!.settings.arguments as String;
    if (isUsingMockData) {
      _detailLibrary = Future.value(MockData.detailLibrary);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        state.rawQueue = MockData.songs;
        state.queue = MockData.songs;
        state.openedLibrary = state.rawOpenedLibrary;
      });
    } else {
      state.refreshDetailLibraryPage = _refreshDetailLibraryPage;
      _detailLibrary =
          state.fetchDetailLibrary(openedLibrary!, state.currentPlatform);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build detail library page');
    MyAppState appState = context.watch<MyAppState>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    var isUsingMockData = appState.isUsingMockData;
    var openedLibrary = appState.rawOpenedLibrary;
    var player = appState.player;
    var searchedSongs = appState.searchedSongs;
    var currentPlatform = appState.currentPlatform;
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
                      inDetailLibraryPage: true,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: theme.detailLibraryPageBg!,
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
                                  future: _detailLibrary,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SelectableText(
                                              '${snapshot.error}',
                                              textAlign: TextAlign.center,
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
                                              icon: Icon(
                                                MdiIcons.webRefresh,
                                                color: colorScheme.onPrimary,
                                              ),
                                              label: Text(
                                                'Retry',
                                                style: textTheme.labelMedium!
                                                    .copyWith(
                                                  color: colorScheme.onPrimary,
                                                ),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _detailLibrary = appState
                                                      .fetchDetailLibrary(
                                                          openedLibrary!,
                                                          appState
                                                              .currentPlatform);
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      dynamic detailLibrary;
                                      if (currentPlatform == 1 ||
                                          isUsingMockData) {
                                        detailLibrary = snapshot.data == null
                                            ? null
                                            : snapshot.data
                                                as QQMusicDetailPlaylist;
                                      } else {
                                        throw Exception(
                                            'Only implement qq music platform');
                                      }
                                      if (detailLibrary != null) {
                                        rawQueue = detailLibrary.songs;
                                        // if (searchedSongs.isEmpty) {
                                        //   searchedSongs =
                                        //       List.from(detailLibrary.songs);
                                        // }
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          // if (appState.rawQueue!.isEmpty ||
                                          // _changeRawQueue) {
                                          if (_changeRawQueue) {
                                            appState.rawQueue =
                                                detailLibrary.songs;
                                            appState.searchedSongs =
                                                detailLibrary.songs;
                                            _changeRawQueue = false;
                                          }
                                        });
                                      }
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
                                                            print(
                                                                detailLibrary);
                                                            print(
                                                                searchedSongs);
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
                                                                        detailLibrary
                                                                            .cover)
                                                                    : CachedNetworkImage(
                                                                        imageUrl: detailLibrary != null &&
                                                                                detailLibrary.cover.isNotEmpty
                                                                            ? detailLibrary.cover
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
                                                            detailLibrary !=
                                                                    null
                                                                ? detailLibrary
                                                                    .name
                                                                : 'Hidden library',
                                                            style: textTheme
                                                                .labelLarge!
                                                                .copyWith(
                                                              fontSize: 20.0,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                '${detailLibrary != null ? detailLibrary.itemCount : 0} songs',
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
                                                                '${detailLibrary != null ? detailLibrary.listenNum : 0} listened',
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
                                                                detailLibrary !=
                                                                        null
                                                                    ? detailLibrary
                                                                        .desc
                                                                    : 'This library is a hidden library.',
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
                                                  detailLibrary != null &&
                                                          detailLibrary
                                                                  .itemCount !=
                                                              0
                                                      ? searchedSongs.isNotEmpty
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
                                                                            () async {
                                                                          if (appState.player ==
                                                                              null) {
                                                                            appState.queue =
                                                                                searchedSongs.where((song) => !song.isTakenDown && (song.payPlay == 0)).toList();

                                                                            // Real index in queue, not in raw queue as some songs may be taken down.
                                                                            int realIndex =
                                                                                appState.queue!.indexOf(searchedSongs[0]);

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

                                                                            appState.currentPlayingSongInQueue =
                                                                                realIndex;

                                                                            appState.currentSong =
                                                                                appState.queue![realIndex];

                                                                            appState.prevSong =
                                                                                appState.currentSong;

                                                                            appState.currentDetailSong =
                                                                                null;

                                                                            appState.player!.play();
                                                                          } else {
                                                                            appState.queue =
                                                                                searchedSongs.where((song) => !song.isTakenDown && (song.payPlay == 0)).toList();

                                                                            // Real index in queue, not in raw queue as some songs may be taken down.
                                                                            int realIndex =
                                                                                appState.queue!.indexOf(searchedSongs[0]);

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

                                                                            appState.currentPlayingSongInQueue =
                                                                                realIndex;

                                                                            appState.currentSong =
                                                                                appState.queue![realIndex];

                                                                            appState.currentDetailSong =
                                                                                null;

                                                                            appState.prevSong =
                                                                                appState.currentSong;

                                                                            appState.player!.play();
                                                                          }
                                                                        },
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .playlist_play_rounded,
                                                                        ),
                                                                        color: colorScheme
                                                                            .tertiary,
                                                                        tooltip:
                                                                            'Play all',
                                                                      ),
                                                                      IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (_) => MultiSongsSelectPopup());
                                                                        },
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .checklist_rounded,
                                                                          // Icons
                                                                          //     .playlist_add_check_rounded,
                                                                        ),
                                                                        color: colorScheme
                                                                            .tertiary,
                                                                        tooltip:
                                                                            'Multi select',
                                                                      ),
                                                                      IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          showDialog(
                                                                            context:
                                                                                context,
                                                                            builder: (_) =>
                                                                                LibraryItemMenuPopup(
                                                                              library: detailLibrary,
                                                                              isInDetailLibraryPage: true,
                                                                            ),
                                                                          );
                                                                        },
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .more_vert_rounded,
                                                                        ),
                                                                        color: colorScheme
                                                                            .tertiary,
                                                                        tooltip:
                                                                            'Edit library',
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: ListView
                                                                      .builder(
                                                                    // TODO: fix this. Mock.songs have 10 songs only.
                                                                    // itemCount: _detailLibrary.songsCount,
                                                                    itemCount: isUsingMockData
                                                                        ? min(
                                                                            detailLibrary
                                                                                .itemCount,
                                                                            10)
                                                                        : searchedSongs
                                                                            .length,
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
                                                                            if (searchedSongs[index].payPlay ==
                                                                                1) {
                                                                              MyToast.showToast('This song need vip to play');
                                                                              MyLogger.logger.e('This song need vip to play');
                                                                            } else if (searchedSongs[index].isTakenDown) {
                                                                              MyToast.showToast('This song is taken down');
                                                                              MyLogger.logger.e('This song is taken down');
                                                                            } else {
                                                                              if (appState.player == null) {
                                                                                appState.queue = searchedSongs.where((song) => !song.isTakenDown && (song.payPlay == 0)).toList();

                                                                                // Real index in queue, not in raw queue as some songs may be taken down.
                                                                                int realIndex = appState.queue!.indexOf(searchedSongs[index]);

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

                                                                                appState.canSongPlayerPagePop = true;

                                                                                appState.currentPlayingSongInQueue = realIndex;

                                                                                appState.currentSong = appState.queue![realIndex];

                                                                                appState.prevSong = appState.currentSong;

                                                                                appState.currentDetailSong = null;

                                                                                appState.isFirstLoadSongPlayer = true;

                                                                                // appState.player!
                                                                                //     .seek(
                                                                                //         Duration
                                                                                //             .zero,
                                                                                //         index:
                                                                                //             index);
                                                                                appState.player!.play();
                                                                              } else if (appState.currentSong == searchedSongs[index]) {
                                                                                if (!player!.playerState.playing) {
                                                                                  player.play();
                                                                                }
                                                                              } else {
                                                                                appState.queue = searchedSongs.where((song) => !song.isTakenDown && (song.payPlay == 0)).toList();

                                                                                // Real index in queue, not in raw queue as some songs may be taken down.
                                                                                int realIndex = appState.queue!.indexOf(searchedSongs[index]);

                                                                                appState.canSongPlayerPagePop = true;

                                                                                appState.player!.stop();

                                                                                appState.player!.dispose();

                                                                                appState.player = null;

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

                                                                                appState.currentPlayingSongInQueue = realIndex;

                                                                                appState.currentSong = appState.queue![realIndex];

                                                                                appState.currentDetailSong = null;

                                                                                appState.prevSong = appState.currentSong;

                                                                                appState.isFirstLoadSongPlayer = true;

                                                                                appState.player!.play();
                                                                              }
                                                                              appState.isPlayerPageOpened = true;
                                                                              if (context.mounted) {
                                                                                Navigator.pushNamed(context, '/song_player_page');
                                                                              }
                                                                            }
                                                                          },
                                                                          child:
                                                                              SongItem(
                                                                            index:
                                                                                index,
                                                                            song:
                                                                                searchedSongs[index],
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                )
                                                              ],
                                                            )
                                                          : Center(
                                                              child: Text(
                                                                'Not found',
                                                                style: textTheme
                                                                    .labelMedium,
                                                              ),
                                                            )
                                                      : Center(
                                                          child: TextButton(
                                                            onPressed: () {
                                                              MyToast.showToast(
                                                                  'To be implement');
                                                            },
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
