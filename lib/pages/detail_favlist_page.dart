import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../entities/bilibili/bili_detail_fav_list.dart';
import '../entities/bilibili/bili_resource.dart';
import '../mock_data.dart';
import '../states/app_state.dart';
import '../states/my_search_state.dart';
import '../utils/my_logger.dart';
import '../utils/my_toast.dart';
import '../utils/theme_manager.dart';
import '../widgets/bili_resource_item.dart';
import '../widgets/bottom_player.dart';
import '../widgets/multi_songs_select_popup.dart';
import '../widgets/my_searchbar.dart';
import '../widgets/my_selectable_text.dart';

class DetailFavListPage extends StatefulWidget {
  @override
  State<DetailFavListPage> createState() => _DetailFavListPageState();
}

class _DetailFavListPageState extends State<DetailFavListPage> {
  // Current page number, only for bilibili.
  int _currentPage = 1;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<BasicLibrary?> _futureDetailLibrary;

  bool _changeRawQueue = true;

  // All resources fetched, in local storage.
  List<BiliResource> _localResources = [];

  bool _isLoading = false;

  // Whether has more libraries.
  bool _hasMore = true;

  late MyAppState _state;

  ScrollController _scrollController = ScrollController();

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasMore) {
        _fetchingResourcesInLibrary();
      } else {
        MyToast.showToast('No more resources');
      }
    }
  }

  // Only called in bilibili.
  Future<void> _fetchingResourcesInLibrary() async {
    int platform = _state.currentPlatform;
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
      _currentPage++;
      List<BiliResource>? pageResources;
      BiliDetailFavList? detailFavList = await _state.fetchDetailLibrary(
              _state.rawOpenedLibrary!, platform, _currentPage.toString())
          as BiliDetailFavList?;
      if (detailFavList != null) {
        _hasMore = detailFavList.hasMore;
        pageResources = detailFavList.resources;
        if (pageResources.isNotEmpty) {
          _localResources.addAll(pageResources);
        }
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    var isUsingMockData = state.isUsingMockData;
    var openedLibrary = state.rawOpenedLibrary;
    _state = state;
    if (isUsingMockData) {
      _futureDetailLibrary = Future.value(MockData.detailLibrary);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        state.rawQueue = MockData.songs;
        state.queue = MockData.songs;
        state.openedLibrary = state.rawOpenedLibrary;
      });
    } else {
      state.refreshDetailLibraryPage = _refreshDetailLibraryPage;
      _futureDetailLibrary =
          state.fetchDetailLibrary(openedLibrary!, state.currentPlatform, '1');
    }
    _scrollController.addListener(_scrollListener);
  }

  void _refreshDetailLibraryPage(MyAppState appState) {
    setState(() {
      _currentPage = 1;
      _hasMore = false;
      _futureDetailLibrary = appState.fetchDetailLibrary(
          appState.rawOpenedLibrary!, appState.currentPlatform, '1');
      _localResources.clear();
    });
  }

  void onSongTap(MyAppState appState, int index, BuildContext context,
      List<BiliResource> searchedResources) async {
    var currentPlatform = appState.currentPlatform;
    var player = appState.player;

    if (appState.player == null) {
      appState.queue = searchedResources;

      try {
        await appState.initAudioPlayer();
      } catch (e) {
        MyToast.showToast('Exception: $e');
        MyLogger.logger.e('Exception: $e');
        appState.disposeSongPlayer();
        return;
      }
      appState.canSongPlayerPagePop = true;
      appState.currentPlayingSongInQueue = index;
      appState.currentSong = appState.queue![index];
      appState.prevSong = appState.currentSong;
      appState.currentDetailSong = null;
      appState.isFirstLoadSongPlayer = true;
      appState.player!.play();
    } else if (appState.currentSong == searchedResources[index]) {
      if (!player!.playerState.playing) {
        player.play();
      }
    } else {
      appState.queue = searchedResources;

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
        appState.disposeSongPlayer();
        return;
      }
      appState.currentPlayingSongInQueue = index;
      appState.currentSong = appState.queue![index];
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

  @override
  Widget build(BuildContext context) {
    print('build detail fav list page');
    MyAppState appState = context.watch<MyAppState>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    var isUsingMockData = appState.isUsingMockData;
    var openedLibrary = appState.rawOpenedLibrary;
    var searchedResources = appState.searchedResources;
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
                                  future: _futureDetailLibrary,
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
                                                  _futureDetailLibrary = appState
                                                      .fetchDetailLibrary(
                                                          openedLibrary!,
                                                          appState
                                                              .currentPlatform,
                                                          '1');
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      BiliDetailFavList? detailFavList;
                                      if (isUsingMockData) {
                                        // detailFavList = snapshot.data == null
                                        //     ? null
                                        //     : snapshot.data
                                        //         as QQMusicDetailPlaylist;
                                        throw UnimplementedError(
                                            'Not yet implement mock data in bilibili');
                                      } else {
                                        detailFavList = snapshot.data == null
                                            ? null
                                            : snapshot.data
                                                as BiliDetailFavList;
                                        if (_currentPage == 1) {
                                          List<BiliResource>? libraries =
                                              detailFavList!.resources;
                                          _hasMore = detailFavList.hasMore;
                                          _localResources.addAll(libraries);
                                        }
                                      }
                                      if (detailFavList != null) {
                                        // WidgetsBinding.instance
                                        //     .addPostFrameCallback((_) {
                                        //   if (_changeRawQueue) {
                                        //     appState.rawQueue =
                                        //         detailFavList.songs;
                                        //     appState.searchedResources =
                                        //         detailFavList.songs;
                                        //     _changeRawQueue = false;
                                        //   }
                                        // });
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
                                                        // width: 100.0,
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
                                                                detailFavList);
                                                            print(
                                                                searchedResources);
                                                            setState(() {});
                                                          },
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4.0),
                                                            child: isUsingMockData
                                                                ? Image.asset(
                                                                    detailFavList!
                                                                        .cover,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )
                                                                : CachedNetworkImage(
                                                                    imageUrl: detailFavList !=
                                                                                null &&
                                                                            detailFavList
                                                                                .cover.isNotEmpty
                                                                        ? detailFavList
                                                                            .cover
                                                                        : MyAppState
                                                                            .defaultCoverImage,
                                                                    progressIndicatorBuilder: (context,
                                                                            url,
                                                                            downloadProgress) =>
                                                                        CircularProgressIndicator(
                                                                            value:
                                                                                downloadProgress.progress),
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Icon(MdiIcons
                                                                            .debian),
                                                                    fit: BoxFit
                                                                        .cover,
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
                                                            detailFavList!.name,
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
                                                                '${detailFavList.itemCount} resources',
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
                                                                '${detailFavList.viewCount} views',
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
                                                          Text(
                                                            'type: ${detailFavList.type}',
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: textTheme
                                                                .titleSmall,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          Text(
                                                            'upper: ${detailFavList.upperName}',
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
                                                                detailFavList
                                                                    .intro,
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
                                                  detailFavList.itemCount != 0
                                                      ? _localResources
                                                              .isNotEmpty
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
                                                                              appState,
                                                                              0,
                                                                              context,
                                                                              searchedResources);
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
                                                                        ),
                                                                        color: colorScheme
                                                                            .tertiary,
                                                                        tooltip:
                                                                            'Multi select',
                                                                      ),
                                                                      IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          // showDialog(
                                                                          //   context:
                                                                          //       context,
                                                                          //   builder: (_) =>
                                                                          //       LibraryItemMenuPopup(
                                                                          //     library: detailFavList,
                                                                          //     isInDetailLibraryPage: true,
                                                                          //   ),
                                                                          // );
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
                                                                    controller:
                                                                        _scrollController,
                                                                    itemCount: isUsingMockData
                                                                        ? min(
                                                                            detailFavList
                                                                                .itemCount,
                                                                            10)
                                                                        : _localResources.length +
                                                                            1,
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      if (index <
                                                                          _localResources
                                                                              .length) {
                                                                        return Material(
                                                                          color:
                                                                              Colors.transparent,
                                                                          child:
                                                                              InkWell(
                                                                            onTap:
                                                                                () {
                                                                              onSongTap(appState, index, context, searchedResources);
                                                                            },
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.all(12.0),
                                                                              child: BiliResourceItem(
                                                                                index: index,
                                                                                resource: _localResources[index],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        return _buildLoadingIndicator(
                                                                            colorScheme);
                                                                      }
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
                                                              'Add resources',
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

  Widget _buildLoadingIndicator(ColorScheme colorScheme) {
    return _isLoading
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: SizedBox(
                  height: 10.0,
                  width: 10.0,
                  child: CircularProgressIndicator(
                    color: colorScheme.onPrimary,
                    strokeWidth: 2.0,
                  )),
            ),
          )
        : Container();
  }
}
