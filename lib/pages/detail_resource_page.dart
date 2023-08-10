import 'package:cached_network_image/cached_network_image.dart';
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
import '../states/app_state.dart';
import '../widgets/bili_resource_item.dart';
import '../widgets/my_selectable_text.dart';

class DetailResourcePage extends StatefulWidget {
  @override
  State<DetailResourcePage> createState() => _ResourceSubPagesPageState();
}

class _ResourceSubPagesPageState extends State<DetailResourcePage>
    with TickerProviderStateMixin {
  late BiliResource _currentResource;
  late BiliDetailResource _currentDetailResource;
  late Future<BiliDetailResource?> _futureCurrentDetailResource;
  late int _currentPlatform;
  late MyAppState _noListenedState;
  late TextTheme _textTheme = Theme.of(context).textTheme;
  late ColorScheme _colorScheme = Theme.of(context).colorScheme;
  late Size screenSize = MediaQuery.of(context).size;
  late final AnimationController _animationController = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(0.0, 1.0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeIn,
  ));
  late TabController _tabController;
  int _subPageNo = 1;
  // Controller for reset episodes list.
  late ScrollController _episodesScrollController;
  late ScrollController _collapseSubpagesScrollController;
  late ScrollController _expandSubpagesScrollController;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    _noListenedState = state;
    _currentResource = state.currentResource!;
    _currentPlatform = state.currentPlatform;
    _futureCurrentDetailResource = state.fetchDetailSong<BiliDetailResource>(
        _currentResource, _currentPlatform)!;
    _episodesScrollController = ScrollController();
    _expandSubpagesScrollController = ScrollController();
    _collapseSubpagesScrollController = ScrollController();
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
    _animationController.dispose();
    _episodesScrollController.dispose();
    _collapseSubpagesScrollController.dispose();
    _expandSubpagesScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _slideOutResourceSubPagesPage() {
    _animationController.reverse().then((_) {
      setState(() {});
    });
  }

  void _slideInResourceSubPagesPage() {
    _animationController.forward().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    _currentPlatform = appState.currentPlatform;
    return SafeArea(
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
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MySelectableText(
                    snapshot.hasError ? '${snapshot.error}' : appState.errorMsg,
                    style: _textTheme.labelMedium!.copyWith(
                      color: _colorScheme.onPrimary,
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
                      color: _colorScheme.onPrimary,
                    ),
                    label: Text(
                      'Retry',
                      style: _textTheme.labelMedium!.copyWith(
                        color: _colorScheme.onPrimary,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _futureCurrentDetailResource = _noListenedState
                            .fetchDetailSong<BiliDetailResource>(
                                _currentResource, _currentPlatform)!;
                      });
                    },
                  ),
                ],
              ),
            );
          } else {
            _currentDetailResource = snapshot.data!;
            return _buildDetailResourcePage();
          }
        },
      ),
    );
  }

  Widget _buildDetailResourcePage() {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            color: _colorScheme.onPrimary,
          ),
        ),
        Expanded(
          flex: 8,
          child: Stack(
            children: [
              _buildResourceIntroPage(),
              SlideTransition(
                position: _offsetAnimation,
                child: _currentDetailResource.isSeasonResource
                    ? _buildEpisodesList()
                    : _buildSubPagesList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResourceIntroPage() {
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
                          'Comments ${humanizeInt(_currentDetailResource.commentCount)}',
                      height: 40.0),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Center(
                      child: _detailResourceWidget(),
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
        leadingWidth: 100.0,
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
                      _subPageNo = index + 1;
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
                        _subPageNo = index + 1;
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

  Widget _detailResourceWidget() {
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
    return Column(
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
                      imageUrl: _currentDetailResource.upperHeadPic.isNotEmpty
                          ? _currentDetailResource.upperHeadPic
                          : MyAppState.defaultCoverImage,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress),
                      errorWidget: (context, url, error) =>
                          Icon(MdiIcons.debian),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    _currentDetailResource.upperName,
                    style: _textTheme.labelSmall!.copyWith(
                      color: Color(0xFFFB6A9D),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 2.0),
          child: Text(
            _currentDetailResource.title,
            style: _textTheme.labelMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 10.0),
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
                  humanizeInt(_currentDetailResource.playCount),
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
                  humanizeInt(_currentDetailResource.danmakuCount),
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
                    _currentDetailResource.publishedTime * 1000),
              ),
              style: _textTheme.labelSmall!.copyWith(
                fontSize: 11.0,
                color: _colorScheme.onPrimary.withOpacity(0.5),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 10.0),
          child: Text(
            _currentDetailResource.bvid,
            style: _textTheme.labelSmall!.copyWith(
              fontSize: 11.0,
              color: _colorScheme.onPrimary.withOpacity(0.5),
            ),
          ),
        ),
        _currentDetailResource.dynamicLabels.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(left: 20.0, bottom: 10.0),
                child: Text(
                  _currentDetailResource.dynamicLabels,
                  style: _textTheme.labelSmall!.copyWith(
                    fontSize: 11.0,
                    color: _colorScheme.onPrimary.withOpacity(0.5),
                  ),
                ),
              )
            : Container(),
        _currentDetailResource.intro.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(left: 20.0, bottom: 10.0),
                child: Text(
                  _currentDetailResource.intro,
                  style: _textTheme.labelSmall!.copyWith(
                    fontSize: 11.0,
                    color: _colorScheme.onPrimary.withOpacity(0.5),
                  ),
                ),
              )
            : Container(),
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
                      'assets/images/bili_coin.png',
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
                      'assets/images/bili_favorite.png',
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
                      'assets/images/bili_share.png',
                      color: _colorScheme.onPrimary.withOpacity(1),
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
                                padding: const EdgeInsets.only(left: 12.0),
                                child: Text(
                                  _currentDetailResource.title,
                                  textAlign: TextAlign.start,
                                  style: _textTheme.labelMedium!,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Lottie.asset(
                                'assets/images/lottie_wave.json',
                                height: 12.0,
                              ),
                            ),
                            Text(
                              '$_subPageNo/${_currentDetailResource.page}',
                              style: _textTheme.labelSmall!.copyWith(
                                fontSize: 11.0,
                                color: _colorScheme.onPrimary.withOpacity(0.5),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
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
                                            _subPageNo = index + 1;
                                          });
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            _collapseSubpagesScrollController
                                                .animateTo(
                                              index * 128.0,
                                              curve: Curves.easeInOut,
                                              duration:
                                                  Duration(milliseconds: 300),
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
                                                BorderRadius.circular(4.0),
                                          ),
                                          child: Center(
                                            child: Container(
                                              margin: EdgeInsets.all(10.0),
                                              child: RichText(
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                text: TextSpan(
                                                  style: _subPageNo == index + 1
                                                      ? _textTheme.labelSmall!
                                                          .copyWith(
                                                          height: 1.0,
                                                          color:
                                                              Color(0xFFFB6A9D),
                                                        )
                                                      : _textTheme.labelSmall!
                                                          .copyWith(
                                                          height: 1.0,
                                                          color: _colorScheme
                                                              .onPrimary
                                                              .withOpacity(0.5),
                                                        ),
                                                  children: [
                                                    _subPageNo == index + 1
                                                        ? WidgetSpan(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          4.0,
                                                                      right:
                                                                          4.0),
                                                              child:
                                                                  Lottie.asset(
                                                                'assets/images/lottie_wave.json',
                                                                height: 10.0,
                                                                width: 10.0,
                                                              ),
                                                            ),
                                                          )
                                                        : TextSpan(),
                                                    TextSpan(
                                                      text:
                                                          _currentDetailResource
                                                              .subpages![index]
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
                                  color:
                                      _colorScheme.onPrimary.withOpacity(0.3),
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
    );
  }
}
