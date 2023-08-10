import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../entities/basic/basic_song.dart';
import '../entities/netease_cloud_music/ncm_detail_playlist.dart';
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
import '../widgets/my_selectable_text.dart';
import '../widgets/song_item.dart';

class DetailLibraryPage extends StatefulWidget {
  @override
  State<DetailLibraryPage> createState() => _DetailLibraryPageState();
}

class _DetailLibraryPageState extends State<DetailLibraryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<BasicLibrary?> _detailLibrary;

  // Current fav list.
  late BasicLibrary _currentLibrary;

  MyAppState? _appState;

  bool _changeRawQueue = true;

  // Current platform.
  late int _currentPlatform;

  // Is using mock data?
  late bool _isUsingMockData;

  void _refreshDetailLibraryPage(MyAppState appState) {
    setState(() {
      _detailLibrary =
          appState.fetchDetailLibrary(_currentLibrary, _currentPlatform);
    });
  }

  void onSongTap(
      int index, List<BasicSong> searchedSongs, MyAppState appState) async {
    var isTakenDown = searchedSongs[index].isTakenDown;
    var payPlayType = searchedSongs[index].payPlay;
    var songsPlayer = appState.songsPlayer;

    if (_currentPlatform == 1 && payPlayType == 1) {
      MyToast.showToast('This song need vip to play');
      MyLogger.logger.e('This song need vip to play');
      return;
    }

    if (isTakenDown) {
      MyToast.showToast('This song is taken down');
      MyLogger.logger.e('This song is taken down');
      return;
    }

    if (songsPlayer == null) {
      if (_currentPlatform == 2) {
        appState.songsQueue =
            searchedSongs.where((song) => !song.isTakenDown).toList();
      } else {
        appState.songsQueue = searchedSongs
            .where((song) => !song.isTakenDown && (song.payPlay == 0))
            .toList();
      }
      // Real index in songsQueue, not in raw songsQueue as some songs may be taken down.
      int realIndex = appState.songsQueue!.indexOf(searchedSongs[index]);
      appState.currentPlayingSongInQueue = realIndex;
      try {
        await appState.initSongsPlayer();
      } catch (e) {
        MyToast.showToast('Exception: $e');
        MyLogger.logger.e('Exception: $e');
        appState.disposeSongsPlayer();
        return;
      }
      appState.canSongsPlayerPagePop = true;
      appState.currentSong = appState.songsQueue![realIndex];
      appState.prevSong = appState.currentSong;
      appState.currentDetailSong = null;
      appState.isFirstLoadSongsPlayer = true;
      appState.songsPlayer!.play();
    } else if (appState.currentSong == searchedSongs[index]) {
      if (!songsPlayer.playerState.playing) {
        songsPlayer.play();
      }
    } else {
      if (_currentPlatform == 2) {
        appState.songsQueue =
            searchedSongs.where((song) => !song.isTakenDown).toList();
      } else {
        appState.songsQueue = searchedSongs
            .where((song) => !song.isTakenDown && (song.payPlay == 0))
            .toList();
      }
      // Real index in songsQueue, not in raw songsQueue as some songs may be taken down.
      int realIndex = appState.songsQueue!.indexOf(searchedSongs[index]);
      appState.canSongsPlayerPagePop = true;
      appState.songsPlayer!.stop();
      appState.songsPlayer!.dispose();
      appState.songsPlayer = null;
      appState.songsAudioSource!.clear();
      appState.currentPlayingSongInQueue = realIndex;
      try {
        await appState.initSongsPlayer();
      } catch (e) {
        MyToast.showToast('Exception: $e');
        MyLogger.logger.e('Exception: $e');
        appState.disposeSongsPlayer();
        return;
      }
      appState.currentSong = appState.songsQueue![realIndex];
      appState.currentDetailSong = null;
      appState.prevSong = appState.currentSong;
      appState.isFirstLoadSongsPlayer = true;
      appState.songsPlayer!.play();
    }
    appState.isSongsPlayerPageOpened = true;
    if (context.mounted) {
      Navigator.pushNamed(context, '/songs_player_page');
    }
  }

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    _isUsingMockData = state.isUsingMockData;
    _currentPlatform = state.currentPlatform;
    _currentLibrary = state.rawOpenedLibrary!;
    if (_isUsingMockData) {
      _detailLibrary = Future.value(MockData.detailLibrary);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        state.rawSongsInLibrary = MockData.songs;
        state.songsQueue = MockData.songs;
        state.openedLibrary = state.rawOpenedLibrary;
      });
    } else {
      state.refreshDetailLibraryPage = _refreshDetailLibraryPage;
      _detailLibrary =
          state.fetchDetailLibrary(_currentLibrary, _currentPlatform);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build detail library page');
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    _isUsingMockData = appState.isUsingMockData;
    _currentPlatform = appState.currentPlatform;
    _currentLibrary = appState.rawOpenedLibrary!;
    var searchedSongs = appState.searchedSongs;
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
                                    } else if (snapshot.hasError ||
                                        snapshot.data == null) {
                                      return Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            MySelectableText(
                                              snapshot.hasError
                                                  ? '${snapshot.error}'
                                                  : appState.errorMsg,
                                              style: textTheme.labelMedium!
                                                  .copyWith(
                                                color: colorScheme.onPrimary,
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
                                                  _changeRawQueue = true;
                                                  _detailLibrary = appState
                                                      .fetchDetailLibrary(
                                                          _currentLibrary,
                                                          _currentPlatform);
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      dynamic detailLibrary;
                                      if (_isUsingMockData) {
                                        detailLibrary = snapshot.data == null
                                            ? null
                                            : snapshot.data
                                                as QQMusicDetailPlaylist;
                                      } else {
                                        if (_currentPlatform == 0) {
                                          throw UnimplementedError(
                                              'Not yet implement pms platform');
                                        } else if (_currentPlatform == 1) {
                                          detailLibrary = snapshot.data == null
                                              ? null
                                              : snapshot.data
                                                  as QQMusicDetailPlaylist;
                                        } else if (_currentPlatform == 2) {
                                          detailLibrary = snapshot.data == null
                                              ? null
                                              : snapshot.data
                                                  as NCMDetailPlaylist;
                                        } else if (_currentPlatform == 3) {
                                          throw UnimplementedError(
                                              'Not yet implement bilibili platform');
                                        } else {
                                          throw UnsupportedError(
                                              'Invalid platform');
                                        }
                                      }

                                      if (detailLibrary != null) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          if (_changeRawQueue) {
                                            appState.rawSongsInLibrary =
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
                                                                _isUsingMockData
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
                                                          MySelectableText(
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
                                                                '${detailLibrary != null ? detailLibrary.playCount : 0} listened',
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
                                                                        .description
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
                                                                            () {
                                                                          onSongTap(
                                                                              0,
                                                                              searchedSongs,
                                                                              appState);
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
                                                                  child:
                                                                      RefreshIndicator(
                                                                    color: colorScheme
                                                                        .onPrimary,
                                                                    strokeWidth:
                                                                        2.0,
                                                                    onRefresh:
                                                                        () async {
                                                                      setState(
                                                                          () {
                                                                        _changeRawQueue =
                                                                            true;
                                                                        _detailLibrary = appState.fetchDetailLibrary(
                                                                            _currentLibrary,
                                                                            _currentPlatform);
                                                                      });
                                                                    },
                                                                    child: ListView
                                                                        .builder(
                                                                      physics:
                                                                          const AlwaysScrollableScrollPhysics(),
                                                                      // TODO: fix this. Mock.songs have 10 songs only.
                                                                      // itemCount: _detailLibrary.songsCount,
                                                                      itemCount: _isUsingMockData
                                                                          ? min(
                                                                              detailLibrary.itemCount,
                                                                              10)
                                                                          : searchedSongs.length,
                                                                      itemBuilder:
                                                                          (context,
                                                                              index) {
                                                                        return Material(
                                                                          color:
                                                                              Colors.transparent,
                                                                          child:
                                                                              InkWell(
                                                                            // TODO: fix bug: the init cover will be wrong sometimes when first loading
                                                                            // song songsPlayer in shuffle mode.
                                                                            onTap:
                                                                                () {
                                                                              onSongTap(index, searchedSongs, appState);
                                                                            },
                                                                            child:
                                                                                SongItem(
                                                                              index: index,
                                                                              song: searchedSongs[index],
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
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
