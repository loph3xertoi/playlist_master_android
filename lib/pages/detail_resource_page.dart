import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:humanize_big_int/humanize_big_int.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../entities/bilibili/bili_detail_resource.dart';
import '../entities/bilibili/bili_fav_list.dart';
import '../entities/bilibili/bili_resource.dart';
import '../entities/bilibili/bili_subpage_of_resource.dart';
import '../http/api.dart';
import '../http/my_http.dart';
import '../states/app_state.dart';
import '../utils/my_logger.dart';
import '../widgets/bili_resource_item.dart';
import '../widgets/foldable_resource_intro_widget.dart';
import '../widgets/my_selectable_text.dart';
import '../widgets/resource_player.dart';

class DetailResourcePage extends StatefulWidget {
  @override
  State<DetailResourcePage> createState() => _ResourceSubPagesPageState();
}

class _ResourceSubPagesPageState extends State<DetailResourcePage>
    with TickerProviderStateMixin {
  late MyAppState state;
  late BiliResource _currentResource;
  late BiliDetailResource _currentDetailResource;
  // Resource type, 0 for single resource, 1 for resource has multiple sub resources, 2 for episodes.
  late int _resourceType;
  dynamic _currentPlayingSubResource;
  late Future<BiliDetailResource?> _futureCurrentDetailResource;
  late int _currentPlatform;
  late MyAppState _noListenedState;
  late TextTheme _textTheme = Theme.of(context).textTheme;
  late ColorScheme _colorScheme = Theme.of(context).colorScheme;
  late Size screenSize = MediaQuery.of(context).size;
  late final AnimationController _toggleSubResourcesAnimationController =
      AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );
  late final AnimationController _togglePlayingResourcesAnimationController =
      AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );
  late final Animation<Offset> _toggleSubResourcesOffsetAnimation =
      Tween<Offset>(
    begin: const Offset(0.0, 1.0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _toggleSubResourcesAnimationController,
    curve: Curves.easeIn,
  ));
  late final Animation<Offset> _togglePlayingResourcesOffsetAnimation =
      Tween<Offset>(
    begin: const Offset(0.0, 1.0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _togglePlayingResourcesAnimationController,
    curve: Curves.easeIn,
  ));
  late TabController _tabController;
  late int _subPageNo;
  late int _playingMode;
  late int? _currentResourceIndexInFavList;
  late List<BiliResource>? _allResourcesInCurrentFavList;
  // Controller for reset episodes list.
  late ScrollController _episodesScrollController;
  late ScrollController _collapseSubpagesScrollController;
  late ScrollController _expandSubpagesScrollController;
  late ScrollController _resourcesListScrollController;

  Map<String, String> _header = {
    'Referer': 'https://www.bilibili.com',
    'User-Agent':
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
  };

  // Change the pageNo for episodes resources when first loading the detail resource page.
  bool _isFirstLoading = true;

  @override
  void initState() {
    super.initState();
    state = Provider.of<MyAppState>(context, listen: false);
    _subPageNo = state.subPageNo;
    _playingMode = state.biliResourcePlayingMode;
    _noListenedState = state;
    _currentResource = state.currentResource!;
    _currentPlatform = state.currentPlatform;
    _currentResourceIndexInFavList = state.currentResourceIndexInFavList;
    if (_currentPlatform == 0) {
      _allResourcesInCurrentFavList = null;
    } else {
      _allResourcesInCurrentFavList = state.rawResourcesInFavList;
    }
    if (_currentPlatform != 0) {
      _futureCurrentDetailResource = state.fetchDetailSong<BiliDetailResource>(
          _currentResource, _currentPlatform)!;
    } else {
      _futureCurrentDetailResource =
          state.fetchDetailSong<BiliDetailResource>(_currentResource, 3)!;
    }
    _episodesScrollController = ScrollController();
    _expandSubpagesScrollController = ScrollController();
    _collapseSubpagesScrollController = ScrollController();
    _resourcesListScrollController = ScrollController();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0 &&
          !_currentDetailResource.isSeasonResource &&
          _currentDetailResource.page > 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_collapseSubpagesScrollController.hasClients) {
            _collapseSubpagesScrollController.animateTo(
              (_subPageNo - 1) * 128.0,
              curve: Curves.easeInOut,
              duration: Duration(milliseconds: 300),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _toggleSubResourcesAnimationController.dispose();
    _togglePlayingResourcesAnimationController.dispose();
    _episodesScrollController.dispose();
    _collapseSubpagesScrollController.dispose();
    _expandSubpagesScrollController.dispose();
    _resourcesListScrollController.dispose();
    _tabController.dispose();
    state.resetSubPageNo();
    super.dispose();
  }

  void _slideOutResourceSubPagesPage() {
    _toggleSubResourcesAnimationController.reverse().then((_) {
      setState(() {});
    });
  }

  void _slideInResourceSubPagesPage() {
    _toggleSubResourcesAnimationController.forward().then((_) {
      setState(() {});
    });
  }

  void _slideOutPlayingResourcesPage() {
    _togglePlayingResourcesAnimationController.reverse().then((_) {
      setState(() {});
    });
  }

  void _slideInPlayingResourcesPage() {
    _togglePlayingResourcesAnimationController.forward().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    _subPageNo = appState.subPageNo;
    _currentResourceIndexInFavList = appState.currentResourceIndexInFavList;
    _allResourcesInCurrentFavList = appState.rawResourcesInFavList;
    _currentPlatform = appState.currentPlatform;
    _playingMode = appState.biliResourcePlayingMode;
    if ((_playingMode == 4 ||
            _playingMode == 5 ||
            _playingMode == 6 ||
            _playingMode == 7) &&
        appState.currentResourceIndexInFavList != 0) {
      _currentDetailResource = appState.currentDetailResource!;
      if (_currentDetailResource.isSeasonResource) {
        _currentPlayingSubResource =
            _currentDetailResource.episodes![_subPageNo - 1];
        _resourceType = 2;
      } else if (_currentDetailResource.page > 1) {
        _currentPlayingSubResource =
            _currentDetailResource.subpages![_subPageNo - 1];
        _resourceType = 1;
      } else if (_currentDetailResource.page == 1) {
        _currentPlayingSubResource = _currentDetailResource;
        _resourceType = 0;
      } else {
        throw Exception('Invalid resource type');
      }
      return WillPopScope(
        onWillPop: () async {
          appState.inDetailFavlistPage = false;
          appState.refreshLibraries!(appState, false);
          if (appState.songsPlayer != null) {
            appState.songsPlayer!.play();
          }
          return true;
        },
        child: SafeArea(
          child: _buildDetailResourcePage(appState),
        ),
      );
    }
    return WillPopScope(
      onWillPop: () async {
        appState.inDetailFavlistPage = false;
        appState.refreshLibraries!(appState, false);
        if (appState.songsPlayer != null) {
          appState.songsPlayer!.play();
        }
        return true;
      },
      child: SafeArea(
        child: FutureBuilder(
          future: _futureCurrentDetailResource,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                  child: Image.asset(
                    'assets/images/bili_loading.webp',
                    fit: BoxFit.cover,
                  ),
                ),
              );
            } else if (snapshot.hasError || snapshot.data == null) {
              MyLogger.logger.e(
                  snapshot.hasError ? '${snapshot.error}' : appState.errorMsg);
              return Material(
                child: Scaffold(
                  appBar: AppBar(
                    title: Text(
                      'Got some error',
                      style: textTheme.labelLarge,
                    ),
                    backgroundColor: colorScheme.primary,
                    iconTheme: IconThemeData(color: colorScheme.onSecondary),
                  ),
                  body: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MySelectableText(
                          snapshot.hasError
                              ? '${snapshot.error}'
                              : appState.errorMsg,
                          style: _textTheme.labelMedium!.copyWith(
                            color: colorScheme.onSecondary,
                          ),
                        ),
                        TextButton.icon(
                          style: ButtonStyle(
                            shadowColor: MaterialStateProperty.all(
                              _colorScheme.primary,
                            ),
                            overlayColor: MaterialStateProperty.all(
                              Colors.grey,
                            ),
                          ),
                          icon: Icon(
                            MdiIcons.webRefresh,
                            color: colorScheme.onSecondary, // grey
                          ),
                          label: Text(
                            'Retry',
                            style: _textTheme.labelMedium!.copyWith(
                              color: colorScheme.onSecondary,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              if (_currentPlatform != 0) {
                                _futureCurrentDetailResource =
                                    state.fetchDetailSong<BiliDetailResource>(
                                        _currentResource, _currentPlatform)!;
                              } else {
                                _futureCurrentDetailResource =
                                    state.fetchDetailSong<BiliDetailResource>(
                                        _currentResource, 3)!;
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
              _currentDetailResource = snapshot.data!;
              if (_currentDetailResource.isSeasonResource) {
                if (_isFirstLoading) {
                  var currentBvid = _currentDetailResource.bvid;
                  var episodesBvids = _currentDetailResource.episodes!
                      .map((e) => e.bvid)
                      .toList();
                  var episodeIndex = episodesBvids.indexOf(currentBvid);
                  // Some episode resources's bvid may not in episodes.
                  // TODO: handle other subpages of this special resource.
                  if (episodeIndex == -1) {
                    // See this resource as one common video with resource type: 0.
                    _subPageNo = 1;
                    _resourceType = 0;
                    _currentDetailResource.isSeasonResource = false;
                    _currentDetailResource.page = 1;
                    BiliSubpageOfResource subpageOfResource =
                        BiliSubpageOfResource(
                      currentBvid,
                      _currentDetailResource.cid,
                      1,
                      _currentDetailResource.title,
                      _currentDetailResource.duration,
                      0,
                      0,
                    );
                    _currentDetailResource.subpages = [subpageOfResource];
                  } else {
                    _subPageNo = episodeIndex + 1;
                    _resourceType = 2;
                  }
                  appState.setSubPageNoWithoutNotify(_subPageNo);
                  _isFirstLoading = false;
                }
                _currentPlayingSubResource =
                    _currentDetailResource.episodes![_subPageNo - 1];
              } else if (_currentDetailResource.page > 1) {
                _currentPlayingSubResource =
                    _currentDetailResource.subpages![_subPageNo - 1];
                _resourceType = 1;
              } else if (_currentDetailResource.page == 1) {
                _currentPlayingSubResource = _currentDetailResource;
                _resourceType = 0;
              } else {
                throw Exception('Invalid resource type');
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (appState.currentDetailResource != _currentDetailResource) {
                  appState.currentDetailResource = _currentDetailResource;
                }
                if (appState.currentPlayingSubResource !=
                    _currentPlayingSubResource) {
                  appState.currentPlayingSubResource =
                      _currentPlayingSubResource;
                }
                // if (appState.subPageNo != _subPageNo) {
                //   appState.subPageNo = _subPageNo;
                // }
              });
              return _buildDetailResourcePage(appState);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDetailResourcePage(MyAppState appState) {
    var isFullScreen = appState.isFullScreen;
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            color: Colors.black,
            child: ResourcePlayer(detailResource: _currentDetailResource),
          ),
        ),
        isFullScreen
            ? Container()
            : Expanded(
                flex: 8,
                child: Stack(
                  children: [
                    _buildResourceIntroPage(appState),
                    SlideTransition(
                      position: _toggleSubResourcesOffsetAnimation,
                      child: _currentDetailResource.isSeasonResource
                          ? _buildEpisodesList()
                          : _buildSubPagesList(),
                    ),
                    appState.inDetailFavlistPage
                        ? SlideTransition(
                            position: _togglePlayingResourcesOffsetAnimation,
                            child: _buildPlayingResourcesList(),
                          )
                        : Container(),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildResourceIntroPage(MyAppState appState) {
    return Container(
      color: _colorScheme.primary,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          body: Column(
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Color(0xFFFB6A9D),
                dividerColor: _colorScheme.onPrimary.withOpacity(0.3),
                labelColor: Color(0xFFFB6A9D),
                labelStyle: _textTheme.labelSmall,
                overlayColor: MaterialStateProperty.all(Colors.grey),
                unselectedLabelColor: _colorScheme.onPrimary.withOpacity(0.3),
                unselectedLabelStyle: _textTheme.labelSmall,
                tabs: [
                  Tab(text: 'Introduction', height: 40.0),
                  Tab(
                      text:
                          'Comments ${humanizeInt(_currentDetailResource.isSeasonResource ? _currentPlayingSubResource.commentCount : _currentDetailResource.commentCount)}',
                      height: 40.0),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Center(
                      child: _detailResourceWidget(appState),
                    ),
                    Center(
                      child: Text('Todo', style: _textTheme.labelLarge),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEpisodesList() {
    MyAppState appState = context.watch<MyAppState>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_subPageNo <= _currentDetailResource.page - 4) {
        _episodesScrollController.animateTo(
          (_subPageNo - 1) * 104.0,
          curve: Curves.easeInOut,
          duration: Duration(milliseconds: 300),
        );
      }
    });
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: _colorScheme.primary,
        surfaceTintColor: _colorScheme.primary,
        leadingWidth: 120.0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              'Episodes(${_currentDetailResource.page})',
              style: _textTheme.labelSmall!,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _slideOutResourceSubPagesPage();
            },
            icon: Icon(
              Icons.close_rounded,
              color: _colorScheme.onSecondary,
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _episodesScrollController,
        slivers: [
          SliverAppBar(
            pinned: false, // Makes the app bar stick to the top
            floating: true, // Hides the app bar when scrolling up
            snap: true, // Snaps the app bar into view when scrolling down
            automaticallyImplyLeading: false,
            // expandedHeight: 200.0,
            backgroundColor: _colorScheme.primary,
            surfaceTintColor: _colorScheme.primary,
            toolbarHeight: 120.0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 4.0, right: 4.0, bottom: 20.0),
                  child: Text(
                    _currentDetailResource.title,
                    style: _textTheme.labelMedium!.copyWith(
                      color: _colorScheme.onSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: 22.0,
                            width: 22.0,
                            child: Image.asset(
                              'assets/images/bili_play_count.png',
                              color: _colorScheme.onPrimary.withOpacity(0.5),
                            ),
                          ),
                          Text(
                            humanizeInt(_currentDetailResource.playCount),
                            style: _textTheme.labelSmall!.copyWith(
                              fontSize: 11.0,
                              color: _colorScheme.onPrimary.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 22.0,
                            width: 22.0,
                            child: Image.asset(
                              'assets/images/bili_danmaku.png',
                              color: _colorScheme.onPrimary.withOpacity(0.5),
                            ),
                          ),
                          Text(
                            humanizeInt(_currentDetailResource.danmakuCount),
                            style: _textTheme.labelSmall!.copyWith(
                              fontSize: 11.0,
                              color: _colorScheme.onPrimary.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 22.0,
                            width: 22.0,
                            child: Image.asset(
                              'assets/images/bili_thumbup_outline.png',
                              color: _colorScheme.onPrimary.withOpacity(0.5),
                            ),
                          ),
                          Text(
                            humanizeInt(_currentDetailResource.likedCount),
                            style: _textTheme.labelSmall!.copyWith(
                              fontSize: 11.0,
                              color: _colorScheme.onPrimary.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 22.0,
                            width: 22.0,
                            child: Image.asset(
                              'assets/images/bili_coin_outline.png',
                              color: _colorScheme.onPrimary.withOpacity(0.5),
                            ),
                          ),
                          Text(
                            humanizeInt(_currentDetailResource.coinsCount),
                            style: _textTheme.labelSmall!.copyWith(
                              fontSize: 11.0,
                              color: _colorScheme.onPrimary.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 22.0,
                            width: 22.0,
                            child: Image.asset(
                              'assets/images/bili_favorite_outline.png',
                              color: _colorScheme.onPrimary.withOpacity(0.5),
                            ),
                          ),
                          Text(
                            humanizeInt(_currentDetailResource.collectedCount),
                            style: _textTheme.labelSmall!.copyWith(
                              fontSize: 11.0,
                              color: _colorScheme.onPrimary.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 22.0,
                            width: 22.0,
                            child: Image.asset(
                              'assets/images/bili_share_outline.png',
                              color: _colorScheme.onPrimary.withOpacity(0.5),
                            ),
                          ),
                          Text(
                            humanizeInt(_currentDetailResource.sharedCount),
                            style: _textTheme.labelSmall!.copyWith(
                              fontSize: 11.0,
                              color: _colorScheme.onPrimary.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    _currentDetailResource.intro,
                    style: _textTheme.labelSmall!.copyWith(
                      color: _colorScheme.onPrimary.withOpacity(0.5),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                BiliResource resource = _currentDetailResource.episodes![index];
                return BiliResourceItem(
                  biliSourceFavListId:
                      (appState.rawOpenedLibrary as BiliFavList).id,
                  resource: resource,
                  isSelected: _subPageNo == index + 1,
                  onTap: () {
                    setState(() {
                      int newPageNo = index + 1;
                      if (newPageNo != _subPageNo) {
                        _subPageNo = newPageNo;
                        appState.subPageNo = newPageNo;
                        _skipToSpecificSubResource();
                      }
                    });
                  },
                );
              },
              childCount: _currentDetailResource.page,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubPagesList() {
    MyAppState appState = context.watch<MyAppState>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      int rowIndex = (_subPageNo - 1) ~/ 2;
      int maxRowIndex = _currentDetailResource.page ~/ 2;
      if (rowIndex <= maxRowIndex - 9) {
        _expandSubpagesScrollController.animateTo(
          rowIndex * 60.0,
          curve: Curves.easeInOut,
          duration: Duration(milliseconds: 300),
        );
      }
    });
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: _colorScheme.primary,
        surfaceTintColor: _colorScheme.primary,
        leadingWidth: 100.0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              'Videos(${_currentDetailResource.page})',
              style: _textTheme.labelSmall!.copyWith(
                color: _colorScheme.onPrimary.withOpacity(0.5),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _slideOutResourceSubPagesPage();
            },
            icon: Icon(
              Icons.close_rounded,
              color: _colorScheme.onSecondary,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: CustomScrollView(
          controller: _expandSubpagesScrollController,
          slivers: [
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 50,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  BiliSubpageOfResource subpage =
                      _currentDetailResource.subpages![index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(4.0),
                    onTap: () {
                      setState(() {
                        int newPageNo = index + 1;
                        if (newPageNo != _subPageNo) {
                          _subPageNo = newPageNo;
                          appState.subPageNo = newPageNo;
                          _skipToSpecificSubResource();
                        }
                      });
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        color: _colorScheme.secondary,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Center(
                        child: Container(
                          margin: EdgeInsets.all(10.0),
                          child: RichText(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: _subPageNo == index + 1
                                  ? _textTheme.labelSmall!.copyWith(
                                      height: 1.0,
                                      color: Color(0xFFFB6A9D),
                                    )
                                  : _textTheme.labelSmall!.copyWith(
                                      height: 1.0,
                                      color: _colorScheme.onPrimary
                                          .withOpacity(0.5),
                                    ),
                              children: [
                                _subPageNo == index + 1
                                    ? WidgetSpan(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 4.0, right: 4.0),
                                          child: Lottie.asset(
                                            'assets/images/lottie_wave.json',
                                            height: 10.0,
                                            width: 10.0,
                                          ),
                                        ),
                                      )
                                    : TextSpan(),
                                TextSpan(text: subpage.partName),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: _currentDetailResource.page,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayingResourcesList() {
    MyAppState appState = context.watch<MyAppState>();
    var pageNo = _currentResourceIndexInFavList! + 1;
    var resourcesCount = _allResourcesInCurrentFavList!.length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageNo <= resourcesCount - 4) {
        _resourcesListScrollController.animateTo(
          (pageNo - 1) * 104.0,
          curve: Curves.easeInOut,
          duration: Duration(milliseconds: 300),
        );
      }
    });
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: _colorScheme.primary,
        surfaceTintColor: _colorScheme.primary,
        leadingWidth: 100.0,
        leading: GestureDetector(
          onTap: () {
            // TODO: when switching playing mode to 0 when playing resources page opened(or not?),
            // the appState won't be consistent about current playing resource.
            print(appState);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                '${appState.openedLibrary!.name}($resourcesCount)',
                style: _textTheme.labelSmall!,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _slideOutPlayingResourcesPage();
            },
            icon: Icon(
              Icons.close_rounded,
              color: _colorScheme.onSecondary,
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _resourcesListScrollController,
        slivers: [
          SliverAppBar(
            pinned: false, // Makes the app bar stick to the top
            floating: true, // Hides the app bar when scrolling up
            snap: true, // Snaps the app bar into view when scrolling down
            automaticallyImplyLeading: false,
            // expandedHeight: 200.0,
            backgroundColor: _colorScheme.primary,
            surfaceTintColor: _colorScheme.primary,
            toolbarHeight: 120.0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 4.0, right: 4.0, bottom: 20.0),
                  child: Text(
                    _currentDetailResource.title,
                    style: _textTheme.labelMedium!.copyWith(
                      color: _colorScheme.onSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: 22.0,
                            width: 22.0,
                            child: Image.asset(
                              'assets/images/bili_play_count.png',
                              color: _colorScheme.onPrimary.withOpacity(0.5),
                            ),
                          ),
                          Text(
                            humanizeInt(_currentDetailResource.playCount),
                            style: _textTheme.labelSmall!.copyWith(
                              fontSize: 11.0,
                              color: _colorScheme.onPrimary.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 22.0,
                            width: 22.0,
                            child: Image.asset(
                              'assets/images/bili_danmaku.png',
                              color: _colorScheme.onPrimary.withOpacity(0.5),
                            ),
                          ),
                          Text(
                            humanizeInt(_currentDetailResource.danmakuCount),
                            style: _textTheme.labelSmall!.copyWith(
                              fontSize: 11.0,
                              color: _colorScheme.onPrimary.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 22.0,
                            width: 22.0,
                            child: Image.asset(
                              'assets/images/bili_thumbup_outline.png',
                              color: _colorScheme.onPrimary.withOpacity(0.5),
                            ),
                          ),
                          Text(
                            humanizeInt(_currentDetailResource.likedCount),
                            style: _textTheme.labelSmall!.copyWith(
                              fontSize: 11.0,
                              color: _colorScheme.onPrimary.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      // Column(
                      //   children: [
                      //     SizedBox(
                      //       height: 22.0,
                      //       width: 22.0,
                      //       child: Image.asset(
                      //         'assets/images/bili_coin_outline.png',
                      //         color: _colorScheme.onPrimary.withOpacity(0.5),
                      //       ),
                      //     ),
                      //     Text(
                      //       humanizeInt(_currentDetailResource.coinsCount),
                      //       style: _textTheme.labelSmall!.copyWith(
                      //         fontSize: 11.0,
                      //         color: _colorScheme.onPrimary.withOpacity(0.5),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      Column(
                        children: [
                          SizedBox(
                            height: 22.0,
                            width: 22.0,
                            child: Image.asset(
                              'assets/images/bili_favorite_outline.png',
                              color: _colorScheme.onPrimary.withOpacity(0.5),
                            ),
                          ),
                          Text(
                            humanizeInt(_currentDetailResource.collectedCount),
                            style: _textTheme.labelSmall!.copyWith(
                              fontSize: 11.0,
                              color: _colorScheme.onPrimary.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 22.0,
                            width: 22.0,
                            child: Image.asset(
                              'assets/images/bili_share_outline.png',
                              color: _colorScheme.onPrimary.withOpacity(0.5),
                            ),
                          ),
                          Text(
                            humanizeInt(_currentDetailResource.sharedCount),
                            style: _textTheme.labelSmall!.copyWith(
                              fontSize: 11.0,
                              color: _colorScheme.onPrimary.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(left: 8.0),
                //   child: Text(
                //     _currentDetailResource.intro,
                //     style: _textTheme.labelSmall!.copyWith(
                //       color: _colorScheme.onPrimary.withOpacity(0.5),
                //     ),
                //     overflow: TextOverflow.ellipsis,
                //   ),
                // ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                BiliResource resource = _allResourcesInCurrentFavList![index];
                return BiliResourceItem(
                  biliSourceFavListId:
                      (appState.rawOpenedLibrary as BiliFavList).id,
                  resource: resource,
                  isSelected: pageNo == index + 1,
                  disableOverFlowIcon: true,
                  onTap: () {
                    setState(() {
                      int newPageNo = index + 1;
                      if (newPageNo != pageNo) {
                        pageNo = newPageNo;
                        appState.currentResourceIndexInFavList = newPageNo - 1;
                        _skipToSpecificResource(pageNo);
                      }
                    });
                  },
                );
              },
              childCount: resourcesCount,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailResourceWidget(MyAppState appState) {
    if (_currentDetailResource.page > 1 &&
        !_currentDetailResource.isSeasonResource) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _collapseSubpagesScrollController.animateTo(
          (_subPageNo - 1) * 128.0,
          curve: Curves.easeInOut,
          duration: Duration(milliseconds: 300),
        );
      });
    }
    return ListView(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, top: 15.0, right: 20.0, bottom: 10.0),
              child: SizedBox(
                height: 36.0,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18.0,
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl:
                              _currentDetailResource.upperHeadPic.isNotEmpty
                                  ? kIsWeb
                                      ? API.convertImageUrl(
                                          _currentDetailResource.upperHeadPic)
                                      : _currentDetailResource.upperHeadPic
                                  : MyAppState.defaultCoverImage,
                          cacheManager: MyHttp.myImageCacheManager,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                      value: downloadProgress.progress),
                          errorWidget: (context, url, error) =>
                              Icon(MdiIcons.debian),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          _currentDetailResource.upperName,
                          style: _textTheme.labelSmall!.copyWith(
                            color: Color(0xFFFB6A9D),
                          ),
                        ),
                      ),
                    ),
                    appState.inDetailFavlistPage &&
                            (_playingMode == 4 ||
                                _playingMode == 5 ||
                                _playingMode == 6 ||
                                _playingMode == 7)
                        ? Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20.0),
                              onTap: () {
                                _slideInPlayingResourcesPage();
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 4.0,
                                    top: 4.0,
                                    right: 8.0,
                                    bottom: 4.0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: Lottie.asset(
                                        'assets/images/lottie_wave.json',
                                        height: 12.0,
                                      ),
                                    ),
                                    Text(
                                      '${_currentResourceIndexInFavList! + 1}/${_allResourcesInCurrentFavList!.length}',
                                      style: _textTheme.labelSmall!.copyWith(
                                        fontSize: 11.0,
                                        color: _colorScheme.onPrimary
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
            FoldableResourceIntroWidget(
              title: _currentDetailResource.isSeasonResource
                  ? _currentPlayingSubResource.title
                  : _currentDetailResource.title,
              subTitle: _bulidSubTitleWidget(),
              content: _buildContentWidget(),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 22.0,
                        width: 22.0,
                        child: Image.asset(
                          'assets/images/bili_thumbup.png',
                          color: _colorScheme.onPrimary.withOpacity(0.5),
                        ),
                      ),
                      Text(
                        humanizeInt(_currentDetailResource.isSeasonResource
                            ? _currentPlayingSubResource.likedCount
                            : _currentDetailResource.likedCount),
                        style: _textTheme.labelSmall!.copyWith(
                          fontSize: 11.0,
                          color: _colorScheme.onPrimary.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: 22.0,
                        width: 22.0,
                        child: Image.asset(
                          'assets/images/bili_coin.png',
                          color: _colorScheme.onPrimary.withOpacity(0.5),
                        ),
                      ),
                      Text(
                        humanizeInt(_currentDetailResource.isSeasonResource
                            ? _currentPlayingSubResource.coinsCount
                            : _currentDetailResource.coinsCount),
                        style: _textTheme.labelSmall!.copyWith(
                          fontSize: 11.0,
                          color: _colorScheme.onPrimary.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: 22.0,
                        width: 22.0,
                        child: Image.asset(
                          'assets/images/bili_favorite.png',
                          color: _colorScheme.onPrimary.withOpacity(0.5),
                        ),
                      ),
                      Text(
                        humanizeInt(_currentDetailResource.isSeasonResource
                            ? _currentPlayingSubResource.collectedCount
                            : _currentDetailResource.collectedCount),
                        style: _textTheme.labelSmall!.copyWith(
                          fontSize: 11.0,
                          color: _colorScheme.onPrimary.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: 22.0,
                        width: 22.0,
                        child: Image.asset(
                          'assets/images/bili_share.png',
                          color: _colorScheme.onPrimary.withOpacity(1),
                        ),
                      ),
                      Text(
                        humanizeInt(_currentDetailResource.isSeasonResource
                            ? _currentPlayingSubResource.sharedCount
                            : _currentDetailResource.sharedCount),
                        style: _textTheme.labelSmall!.copyWith(
                          fontSize: 11.0,
                          color: _colorScheme.onPrimary.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_currentPlatform == 3)
              // This resource has multiple sub resources.
              _currentDetailResource.page > 1
                  ? _currentDetailResource
                          .isSeasonResource // Whether this resource is episodes or videos.
                      ? Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0, bottom: 10.0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6.0),
                            onTap: () {
                              _slideInResourceSubPagesPage();
                            },
                            child: Ink(
                              height: 40.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6.0),
                                color: _colorScheme.onPrimaryContainer,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 12.0),
                                      child: Text(
                                        _currentDetailResource.title,
                                        textAlign: TextAlign.start,
                                        style: _textTheme.labelMedium!,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: Lottie.asset(
                                      'assets/images/lottie_wave.json',
                                      height: 12.0,
                                    ),
                                  ),
                                  Text(
                                    '$_subPageNo/${_currentDetailResource.page}',
                                    style: _textTheme.labelSmall!.copyWith(
                                      fontSize: 11.0,
                                      color: _colorScheme.onPrimary
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14.0,
                                      color: _colorScheme.onPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: SizedBox(
                            height: 50.0,
                            child: Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                CustomScrollView(
                                  controller: _collapseSubpagesScrollController,
                                  scrollDirection: Axis.horizontal,
                                  slivers: [
                                    SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  int newPageNo = index + 1;
                                                  if (newPageNo != _subPageNo) {
                                                    _subPageNo = newPageNo;
                                                    appState.subPageNo =
                                                        newPageNo;
                                                    _skipToSpecificSubResource();
                                                  }
                                                });
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                  _collapseSubpagesScrollController
                                                      .animateTo(
                                                    index * 128.0,
                                                    curve: Curves.easeInOut,
                                                    duration: Duration(
                                                        milliseconds: 300),
                                                  );
                                                });
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              child: Ink(
                                                width: 120.0,
                                                decoration: BoxDecoration(
                                                  color: _colorScheme.secondary,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4.0),
                                                ),
                                                child: Center(
                                                  child: Container(
                                                    margin:
                                                        EdgeInsets.all(10.0),
                                                    child: RichText(
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      text: TextSpan(
                                                        style: _subPageNo ==
                                                                index + 1
                                                            ? _textTheme
                                                                .labelSmall!
                                                                .copyWith(
                                                                height: 1.0,
                                                                color: Color(
                                                                    0xFFFB6A9D),
                                                              )
                                                            : _textTheme
                                                                .labelSmall!
                                                                .copyWith(
                                                                height: 1.0,
                                                                color: _colorScheme
                                                                    .onPrimary
                                                                    .withOpacity(
                                                                        0.5),
                                                              ),
                                                        children: [
                                                          _subPageNo ==
                                                                  index + 1
                                                              ? WidgetSpan(
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            4.0,
                                                                        right:
                                                                            4.0),
                                                                    child: Lottie
                                                                        .asset(
                                                                      'assets/images/lottie_wave.json',
                                                                      height:
                                                                          10.0,
                                                                      width:
                                                                          10.0,
                                                                    ),
                                                                  ),
                                                                )
                                                              : TextSpan(),
                                                          TextSpan(
                                                            text:
                                                                _currentDetailResource
                                                                    .subpages![
                                                                        index]
                                                                    .partName,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        childCount: _currentDetailResource.page,
                                      ),
                                    ),
                                  ],
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      _slideInResourceSubPagesPage();
                                    },
                                    child: Ink(
                                      width: 40.0,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                        // color: _colorScheme.onPrimaryContainer,
                                        gradient: LinearGradient(
                                          colors: [
                                            _colorScheme.onPrimaryContainer
                                                .withOpacity(0.0),
                                            _colorScheme.onPrimaryContainer
                                                .withOpacity(1.0),
                                          ],
                                          stops: [0.0, 1.0],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 20.0,
                                        color: _colorScheme.onPrimary
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                  : Container(),
          ],
        ),
      ],
    );
  }

  void _skipToSpecificSubResource() async {
    dynamic nextSubResource;
    if (_resourceType == 1) {
      nextSubResource = _currentDetailResource.subpages![_subPageNo - 1];
    } else {
      nextSubResource = _currentDetailResource.episodes![_subPageNo - 1];
    }

    print(_noListenedState);
    final String? title;
    final String? author;
    final String? imageUrl;
    final String? cacheKey;
    final String? resourceId;
    cacheKey = resourceId = '${nextSubResource.bvid}:${nextSubResource.cid}';

    if (_resourceType == 1) {
      title = nextSubResource.partName;
      author = _currentDetailResource.upperName;
      imageUrl = _currentDetailResource.cover;
    } else {
      title = nextSubResource.title;
      author = nextSubResource.upperName;
      imageUrl = nextSubResource.cover;
    }
    var links =
        await _noListenedState.fetchSongsLink([resourceId], _currentPlatform);
    final url = 'https://${API.host}${links.mpd}';
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      useAsmsSubtitles: true,
      useAsmsTracks: true,
      useAsmsAudioTracks: false,
      headers: _header,
      videoFormat: BetterPlayerVideoFormat.dash,
      cacheConfiguration: BetterPlayerCacheConfiguration(
        useCache: true,
        key: cacheKey,
      ),
      notificationConfiguration: BetterPlayerNotificationConfiguration(
        showNotification: true,
        title: title,
        author: author,
        imageUrl: imageUrl,
        activityName: 'com.ryanheise.audioservice.AudioServiceActivity',
      ),
    );
    _noListenedState.betterPlayerController!.setupDataSource(dataSource);
  }

  void _skipToSpecificResource(int pageNo) async {
    // var nextResource = _allResourcesInCurrentFavList![pageNo];
    final String? title;
    final String? author;
    final String? imageUrl;
    final String? cacheKey;
    final String? resourceId;
    var nextResource =
        await _noListenedState.fetchDetailSong<BiliDetailResource>(
            _allResourcesInCurrentFavList![pageNo - 1],
            _noListenedState.currentPlatform);
    if (nextResource == null) {
      throw Exception(
          'Failed to fetch detail resource $pageNo: ${_noListenedState.errorMsg}');
    }
    _currentDetailResource =
        _noListenedState.currentDetailResource = nextResource;
    _currentResource = _noListenedState.currentResource =
        _allResourcesInCurrentFavList![pageNo - 1];
    _currentResourceIndexInFavList =
        _noListenedState.currentResourceIndexInFavList = pageNo - 1;
    _noListenedState.subPageNo = 1;
    cacheKey = resourceId = '${nextResource.bvid}:${nextResource.cid}';

    if (nextResource.isSeasonResource) {
      _resourceType = 2;
    } else if (nextResource.page > 1) {
      _resourceType = 1;
    } else if (nextResource.page == 1) {
      _resourceType = 0;
    } else {
      throw Exception('Invalid resource type');
    }

    title = nextResource.title;
    author = nextResource.upperName;
    imageUrl = nextResource.cover;

    var links =
        await _noListenedState.fetchSongsLink([resourceId], _currentPlatform);
    final url = 'https://${API.host}${links.mpd}';
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      useAsmsSubtitles: true,
      useAsmsTracks: true,
      useAsmsAudioTracks: false,
      headers: _header,
      videoFormat: BetterPlayerVideoFormat.dash,
      cacheConfiguration:
          BetterPlayerCacheConfiguration(useCache: true, key: cacheKey),
      notificationConfiguration: BetterPlayerNotificationConfiguration(
        showNotification: true,
        title: title,
        author: author,
        imageUrl: imageUrl,
        activityName: 'com.ryanheise.audioservice.AudioServiceActivity',
      ),
    );
    _noListenedState.betterPlayerController!.setupDataSource(dataSource);
    setState(() {});
  }

  Widget _buildContentWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
          child: Text(
            _currentDetailResource.isSeasonResource
                ? _currentPlayingSubResource.bvid
                : _currentDetailResource.bvid,
            style: _textTheme.labelSmall!.copyWith(
              fontSize: 11.0,
              color: _colorScheme.onPrimary.withOpacity(0.5),
            ),
          ),
        ),
        _currentDetailResource.isSeasonResource
            ? _currentPlayingSubResource.dynamicLabels.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 10.0),
                    child: Text(
                      _currentPlayingSubResource.dynamicLabels,
                      style: _textTheme.labelSmall!.copyWith(
                        fontSize: 11.0,
                        color: _colorScheme.onPrimary.withOpacity(0.5),
                      ),
                    ),
                  )
                : Container()
            : _currentDetailResource.dynamicLabels.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 10.0),
                    child: Text(
                      _currentDetailResource.dynamicLabels,
                      style: _textTheme.labelSmall!.copyWith(
                        fontSize: 11.0,
                        color: _colorScheme.onPrimary.withOpacity(0.5),
                      ),
                    ),
                  )
                : Container(),
        _currentDetailResource.isSeasonResource
            ? _currentPlayingSubResource.intro.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 10.0),
                    child: Text(
                      _currentPlayingSubResource.intro,
                      style: _textTheme.labelSmall!.copyWith(
                        fontSize: 11.0,
                        color: _colorScheme.onPrimary.withOpacity(0.5),
                      ),
                    ),
                  )
                : Container()
            : _currentDetailResource.intro.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 10.0),
                    child: Text(
                      _currentDetailResource.intro,
                      style: _textTheme.labelSmall!.copyWith(
                        fontSize: 11.0,
                        color: _colorScheme.onPrimary.withOpacity(0.5),
                      ),
                    ),
                  )
                : Container(),
      ],
    );
  }

  Widget _bulidSubTitleWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
      child: Row(children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Image.asset(
                'assets/images/bili_play_count.png',
                color: _colorScheme.onPrimary.withOpacity(0.5),
                height: 16.0,
              ),
            ),
            Text(
              humanizeInt(_currentDetailResource.isSeasonResource
                  ? _currentPlayingSubResource.playCount
                  : _currentDetailResource.playCount),
              style: _textTheme.labelSmall!.copyWith(
                fontSize: 11.0,
                color: _colorScheme.onPrimary.withOpacity(0.5),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        SizedBox(width: 15.0),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Image.asset(
                'assets/images/bili_danmaku.png',
                color: _colorScheme.onPrimary.withOpacity(0.5),
                height: 14.0,
              ),
            ),
            Text(
              humanizeInt(_currentDetailResource.isSeasonResource
                  ? _currentPlayingSubResource.danmakuCount
                  : _currentDetailResource.danmakuCount),
              style: _textTheme.labelSmall!.copyWith(
                fontSize: 11.0,
                color: _colorScheme.onPrimary.withOpacity(0.5),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        SizedBox(width: 15.0),
        Text(
          DateFormat('yyyy-MM-dd HH:mm:ss').format(
            DateTime.fromMillisecondsSinceEpoch(
                _currentDetailResource.isSeasonResource
                    ? _currentPlayingSubResource.publishedTime * 1000
                    : _currentDetailResource.publishedTime * 1000),
          ),
          style: _textTheme.labelSmall!.copyWith(
            fontSize: 11.0,
            color: _colorScheme.onPrimary.withOpacity(0.5),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ]),
    );
  }
}
