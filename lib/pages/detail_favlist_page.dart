import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:humanize_big_int/humanize_big_int.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../entities/bilibili/bili_detail_fav_list.dart';
import '../entities/bilibili/bili_fav_list.dart';
import '../entities/bilibili/bili_resource.dart';
import '../http/api.dart';
import '../http/my_http.dart';
import '../states/app_state.dart';
import '../states/my_search_state.dart';
import '../utils/my_logger.dart';
import '../utils/my_toast.dart';
import '../utils/theme_manager.dart';
import '../widgets/bili_resource_item.dart';
import '../widgets/library_item_menu_popup.dart';
import '../widgets/multi_resources_select_popup.dart';
import '../widgets/my_searchbar.dart';
import '../widgets/my_selectable_text.dart';

class DetailFavListPage extends StatefulWidget {
  @override
  State<DetailFavListPage> createState() => _DetailFavListPageState();
}

class _DetailFavListPageState extends State<DetailFavListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Current fav list.
  late BasicLibrary _currentBiliFavList;

  // Current page number of original resources.
  int _currentPageNumberInOriginalResources = 1;

  // Current page number of searched resources.
  int _currentPageNumberInSearchedResources = 1;

  // All original resources of this fav list.
  List<BiliResource> _originalResources = [];

  // All searched resources of this fav list.
  List<BiliResource> _searchedResources = [];

  // The future detail fav list with first page of resources.
  late Future<BasicLibrary?> _firstFutureDetailFavList;

  // Current platform.
  late int _currentPlatform;

  // Is using mock data?
  late bool _isUsingMockData;

  // Is loding the new resources?
  bool _isLoading = false;

  // Is searching this fav list?
  bool _inSearchMode = false;

  // Keyword for searching.
  String _keyword = '';

  // Are there more original resources?
  bool _hasMoreOriginalResources = false;

  // Are there more searched resources?
  bool _hasMoreSearchedResources = false;

  MyAppState? _appState;

  ScrollController _scrollController = ScrollController();

  bool _changeRawQueue = true;

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if ((_inSearchMode && _hasMoreSearchedResources) ||
          (!_inSearchMode && _hasMoreOriginalResources)) {
        _fetchMoreResources(_appState!);
      } else {
        MyToast.showToast('No more resources');
      }
    }
  }

  // Fetch more original/searched resources in this fav list.
  Future<void> _fetchMoreResources(MyAppState appState) async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      List<BiliResource>? pagedResources;
      BiliDetailFavList? newDetailFavList;
      if (_inSearchMode) {
        _currentPageNumberInSearchedResources++;
        newDetailFavList = await appState.fetchDetailLibrary(
          _currentBiliFavList,
          _currentPlatform,
          pn: _currentPageNumberInSearchedResources as String?,
          keyword: _keyword,
        ) as BiliDetailFavList?;
        if (newDetailFavList != null) {
          _hasMoreSearchedResources = newDetailFavList.hasMore;
          pagedResources = newDetailFavList.resources;
        } else {
          throw Exception('Failed to fetch new resources');
        }
        if (pagedResources.isNotEmpty) {
          _searchedResources.addAll(pagedResources);
        }
      } else {
        _currentPageNumberInOriginalResources++;
        newDetailFavList = await appState.fetchDetailLibrary(
          _currentBiliFavList,
          _currentPlatform,
          pn: _currentPageNumberInOriginalResources.toString(),
        ) as BiliDetailFavList?;
        if (newDetailFavList != null) {
          _hasMoreOriginalResources = newDetailFavList.hasMore;
          pagedResources = newDetailFavList.resources;
        } else {
          throw Exception('Failed to fetch new resources');
        }
        if (pagedResources.isNotEmpty) {
          _originalResources.addAll(pagedResources);
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
    _isUsingMockData = state.isUsingMockData;
    _currentPlatform = state.currentPlatform;
    _currentBiliFavList = state.rawOpenedLibrary!;
    _inSearchMode = state.isDetailFavListPageInSearchMode;
    // _state = state;
    if (_isUsingMockData) {
      // _firstFutureDetailFavList = Future.value(MockData.detailLibrary);
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   state.rawSongsInLibrary = MockData.songs;
      //   state.queue = MockData.songs;
      //   state.openedLibrary = state.rawOpenedLibrary;
      // });
      throw UnimplementedError('Not yet implement mock data for bilibili');
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        state.refreshDetailFavListPage = _refreshDetailFavListPage;
        state.isDetailFavListPageInSearchMode = false;
      });
      _firstFutureDetailFavList = state
          .fetchDetailLibrary(_currentBiliFavList, _currentPlatform, pn: '1');
    }
    _scrollController.addListener(_scrollListener);
  }

  void _refreshDetailFavListPage(MyAppState appState) {
    setState(() {
      _currentPageNumberInOriginalResources = 1;
      _currentPageNumberInSearchedResources = 1;
      _hasMoreOriginalResources = false;
      _hasMoreSearchedResources = false;
      _originalResources = [];
      _searchedResources = [];
      _inSearchMode = false;
      _firstFutureDetailFavList = appState
          .fetchDetailLibrary(_currentBiliFavList, _currentPlatform, pn: '1');
    });
  }

  void onResourceTap(int index, MyAppState appState) async {
    if (context.mounted) {
      if (_inSearchMode) {
        appState.currentResource = _searchedResources[index];
      } else {
        appState.currentResource = _originalResources[index];
      }
      appState.currentResourceIndexInFavList = index;
      appState.inDetailFavlistPage = true;
      Navigator.pushNamed(context, '/detail_resource_page');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build detail fav list page');
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    _appState = appState;
    _isUsingMockData = appState.isUsingMockData;
    _inSearchMode = appState.isDetailFavListPageInSearchMode;
    _searchedResources = appState.searchedResources;
    _currentPlatform = appState.currentPlatform;
    if (appState.rawOpenedLibrary == null) {
      return Container();
    } else {
      _currentBiliFavList = appState.rawOpenedLibrary!;
      return Consumer<ThemeNotifier>(
        builder: (context, theme, _) => Material(
          child: Scaffold(
            key: _scaffoldKey,
            body: SafeArea(
              child: ChangeNotifierProvider(
                create: (context) => MySearchState(),
                child: WillPopScope(
                  onWillPop: () async {
                    _appState!.refreshLibraries!(appState, false);
                    return true;
                  },
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
                                  margin: EdgeInsets.fromLTRB(
                                      12.0, 12.0, 12.0, 0.0),
                                  child: FutureBuilder(
                                      future: _firstFutureDetailFavList,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        } else if (snapshot.hasError ||
                                            snapshot.data == null) {
                                          MyLogger.logger.e(snapshot.hasError
                                              ? '${snapshot.error}'
                                              : appState.errorMsg);
                                          return Material(
                                            child: Scaffold(
                                              appBar: AppBar(
                                                title: Text(
                                                  'Got some error',
                                                  style: textTheme.labelLarge,
                                                ),
                                                backgroundColor:
                                                    colorScheme.primary,
                                                iconTheme: IconThemeData(
                                                    color: colorScheme
                                                        .onSecondary),
                                              ),
                                              body: Center(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    MySelectableText(
                                                      snapshot.hasError
                                                          ? '${snapshot.error}'
                                                          : appState.errorMsg,
                                                      style: textTheme
                                                          .labelMedium!
                                                          .copyWith(
                                                        color: colorScheme
                                                            .onSecondary,
                                                      ),
                                                    ),
                                                    TextButton.icon(
                                                      style: ButtonStyle(
                                                        shadowColor:
                                                            MaterialStateProperty
                                                                .all(
                                                          colorScheme.primary,
                                                        ),
                                                        overlayColor:
                                                            MaterialStateProperty
                                                                .all(
                                                          Colors.grey,
                                                        ),
                                                      ),
                                                      icon: Icon(
                                                        MdiIcons.webRefresh,
                                                        color: colorScheme
                                                            .onSecondary,
                                                      ),
                                                      label: Text(
                                                        'Retry',
                                                        style: textTheme
                                                            .labelMedium!
                                                            .copyWith(
                                                          color: colorScheme
                                                              .onSecondary,
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          _firstFutureDetailFavList =
                                                              appState.fetchDetailLibrary(
                                                                  _currentBiliFavList,
                                                                  _currentPlatform,
                                                                  pn: '1');
                                                          if (_inSearchMode) {
                                                            _currentPageNumberInSearchedResources =
                                                                1;
                                                            _searchedResources =
                                                                [];
                                                          } else {
                                                            _currentPageNumberInOriginalResources =
                                                                1;
                                                            _originalResources =
                                                                [];
                                                          }
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          BiliDetailFavList? detailFavList;
                                          if (_isUsingMockData) {
                                            // detailFavList = snapshot.data == null
                                            //     ? null
                                            //     : snapshot.data
                                            //         as QQMusicDetailPlaylist;
                                            throw UnimplementedError(
                                                'Not yet implement mock data in bilibili');
                                          } else {
                                            detailFavList =
                                                snapshot.data == null
                                                    ? null
                                                    : snapshot.data
                                                        as BiliDetailFavList;
                                            List<BiliResource>? libraries =
                                                detailFavList!.resources;
                                            if (!_inSearchMode &&
                                                _currentPageNumberInOriginalResources ==
                                                    1 &&
                                                _originalResources.isEmpty) {
                                              _hasMoreOriginalResources =
                                                  detailFavList.hasMore;
                                              _originalResources
                                                  .addAll(libraries);
                                            }
                                            // TODO: handle search mode.
                                            if (_inSearchMode &&
                                                _currentPageNumberInSearchedResources ==
                                                    1 &&
                                                _searchedResources.isEmpty) {
                                              _hasMoreSearchedResources =
                                                  detailFavList.hasMore;
                                              _searchedResources
                                                  .addAll(libraries);
                                            }
                                          }
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            if (_changeRawQueue) {
                                              appState.rawResourcesInFavList =
                                                  _originalResources;
                                              appState.searchedResources =
                                                  _searchedResources;
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
                                                        const EdgeInsets.all(
                                                            15.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
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
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                print(appState);
                                                                print(
                                                                    detailFavList);
                                                                print(
                                                                    _searchedResources);
                                                                setState(() {});
                                                              },
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4.0),
                                                                child: _isUsingMockData
                                                                    ? Image.asset(
                                                                        detailFavList
                                                                            .cover,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      )
                                                                    : CachedNetworkImage(
                                                                        imageUrl: detailFavList.cover.isNotEmpty
                                                                            ? kIsWeb
                                                                                ? API.convertImageUrl(detailFavList.cover)
                                                                                : detailFavList.cover
                                                                            : MyAppState.defaultCoverImage,
                                                                        cacheManager:
                                                                            MyHttp.myImageCacheManager,
                                                                        progressIndicatorBuilder: (context,
                                                                                url,
                                                                                downloadProgress) =>
                                                                            CircularProgressIndicator(value: downloadProgress.progress),
                                                                        errorWidget: (context,
                                                                                url,
                                                                                error) =>
                                                                            Icon(MdiIcons.debian),
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
                                                              SelectableText(
                                                                detailFavList
                                                                    .name,
                                                                style: textTheme
                                                                    .labelMedium!
                                                                    .copyWith(
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                maxLines: 2,
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
                                                                    '${humanizeInt(detailFavList.viewCount)} views',
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
                                                              detailFavList
                                                                      .intro
                                                                      .isEmpty
                                                                  ? Container()
                                                                  : Text(
                                                                      'intro: ${detailFavList.intro}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      style: textTheme
                                                                          .titleSmall,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                              Text(
                                                                'UP: ${detailFavList.upperName}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: textTheme
                                                                    .titleSmall,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                              Text(
                                                                'Modified: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(detailFavList.modifiedTime * 1000))}',
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
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: detailFavList
                                                              .itemCount !=
                                                          0
                                                      ? (_inSearchMode &&
                                                                  _searchedResources
                                                                      .isNotEmpty) ||
                                                              (!_inSearchMode &&
                                                                  _originalResources
                                                                      .isNotEmpty)
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
                                                                          if (!(kIsWeb ||
                                                                              Platform.isAndroid ||
                                                                              Platform.isIOS)) {
                                                                            MyToast.showToast('Better player is not supported on ${Platform.operatingSystem}');
                                                                            MyLogger.logger.e('Better player is not supported on ${Platform.operatingSystem}');
                                                                            return;
                                                                          }
                                                                          appState.currentResourceIndexInFavList =
                                                                              0;
                                                                          appState.biliResourcePlayingMode =
                                                                              4;
                                                                          appState.subPageNo =
                                                                              1;
                                                                          onResourceTap(
                                                                              0,
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
                                                                              builder: (_) => MultiResourcesSelectPopup());
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
                                                                          showDialog(
                                                                            context:
                                                                                context,
                                                                            builder: (_) =>
                                                                                LibraryItemMenuPopup(
                                                                              library: detailFavList!,
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
                                                                            'Edit favlists',
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      RefreshIndicator(
                                                                    color: Color(
                                                                        0x00FB6A9D),
                                                                    strokeWidth:
                                                                        2.0,
                                                                    onRefresh:
                                                                        () async {
                                                                      setState(
                                                                          () {
                                                                        _firstFutureDetailFavList = appState.fetchDetailLibrary(
                                                                            _currentBiliFavList,
                                                                            _currentPlatform,
                                                                            pn: '1');
                                                                        if (_inSearchMode) {
                                                                          _currentPageNumberInSearchedResources =
                                                                              1;
                                                                          _searchedResources =
                                                                              [];
                                                                        } else {
                                                                          _currentPageNumberInOriginalResources =
                                                                              1;
                                                                          _originalResources =
                                                                              [];
                                                                        }
                                                                      });
                                                                    },
                                                                    child: ListView
                                                                        .builder(
                                                                      physics:
                                                                          const AlwaysScrollableScrollPhysics(),
                                                                      controller:
                                                                          _scrollController,
                                                                      itemCount: _isUsingMockData
                                                                          ? min(detailFavList.itemCount, 10)
                                                                          : _inSearchMode
                                                                              ? _searchedResources.length
                                                                              : _originalResources.length,
                                                                      itemBuilder:
                                                                          (context,
                                                                              index) {
                                                                        if (index <
                                                                            (_inSearchMode
                                                                                ? _searchedResources.length + 1
                                                                                : _originalResources.length + 1)) {
                                                                          return BiliResourceItem(
                                                                            biliSourceFavListId:
                                                                                (_currentBiliFavList as BiliFavList).id,
                                                                            resource: _inSearchMode
                                                                                ? _searchedResources[index]
                                                                                : _originalResources[index],
                                                                            isSelected:
                                                                                false,
                                                                            onTap:
                                                                                () {
                                                                              appState.biliResourcePlayingMode = 2;
                                                                              onResourceTap(index, appState);
                                                                            },
                                                                          );
                                                                        } else {
                                                                          return _buildLoadingIndicator(
                                                                              colorScheme);
                                                                        }
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
        ),
      );
    }
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
