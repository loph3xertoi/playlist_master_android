import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../entities/basic/basic_song.dart';
import '../entities/bilibili/bili_resource.dart';
import '../entities/dto/paged_data.dart';
import '../entities/netease_cloud_music/ncm_song.dart';
import '../entities/qq_music/qqmusic_song.dart';
import '../states/app_state.dart';
import '../states/my_search_state.dart';
import '../utils/my_logger.dart';
import '../utils/my_toast.dart';
import '../utils/theme_manager.dart';
import '../widgets/bili_resource_item.dart';
import '../widgets/bottom_player.dart';
import '../widgets/my_searchbar.dart';
import '../widgets/song_item.dart';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<BasicSong> _searchedSongs = [];

  List<BiliResource> _searchedResources = [];

  bool _isLoading = false;
  // First page is 1 not 0, and first page is loaded in search bar, so this is 2 page.
  int _pageNo = 1;
  int _pageSize = 20;
  late int _currentPlatform;
  late bool _isUsingMockData;
  MyAppState? _appState;
  late String? _keyword;
  ScrollController _scrollController = ScrollController();
  bool _changeRawQueue = true;
  late bool _hasMore;
  late int _count;
  AudioPlayer? _player;

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
    _keyword = state.keyword;
    _currentPlatform = state.currentPlatform;
    _isUsingMockData = state.isUsingMockData;
    _hasMore = state.hasMore!;
    _player = _currentPlatform == 3 ? state.resourcesPlayer : state.songsPlayer;
    _count = _currentPlatform == 3
        ? state.searchedResources.length
        : state.searchedSongs.length;
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasMore) {
        searchingSong(_appState!);
      } else {
        MyToast.showToast('No more results');
      }
    }
  }

  Future<void> searchingSong(MyAppState appState) async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      PagedDataDTO<dynamic>? pagedDataDTO = await appState.fetchSearchedSongs(
          _keyword!, ++_pageNo, _pageSize, _currentPlatform);

      if (pagedDataDTO != null) {
        setState(() {
          _count = pagedDataDTO.count;
          _hasMore = pagedDataDTO.hasMore;
          var list = pagedDataDTO.list;
          if (_currentPlatform == 0) {
            throw UnimplementedError('Not yet implement pms platform');
          } else if (_currentPlatform == 1) {
            _searchedSongs.addAll(list as List<QQMusicSong>);
          } else if (_currentPlatform == 2) {
            _searchedSongs.addAll(list as List<NCMSong>);
          } else if (_currentPlatform == 3) {
            _searchedResources.addAll(list as List<BiliResource>);
          } else {
            throw UnsupportedError('Invalid platform');
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Fetch searched results failed');
      }
    }
  }

  void _onSearchedItemTapped(int index, MyAppState appState) async {
    var isTakenDown =
        _currentPlatform == 3 ? false : _searchedSongs[index].isTakenDown;
    var payPlayType = _currentPlatform == 3 ? 0 : _searchedSongs[index].payPlay;

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

    if (_player == null) {
      if (_currentPlatform == 0) {
        throw UnimplementedError('Not yet implement pms platform');
      } else if (_currentPlatform == 1) {
        appState.songsQueue = _searchedSongs
            .where((song) => !song.isTakenDown && (song.payPlay == 0))
            .toList();
      } else if (_currentPlatform == 2) {
        appState.songsQueue =
            _searchedSongs.where((song) => !song.isTakenDown).toList();
      } else if (_currentPlatform == 3) {
        appState.resourcesQueue = _searchedResources;
      } else {
        throw UnsupportedError('Invalid platform');
      }

      // Real index in queue, not in raw queue as some songs may be taken down.
      int realIndex = _currentPlatform == 3
          ? index
          : appState.songsQueue!.indexOf(appState.rawSongsInLibrary![index]);

      if (_currentPlatform == 3) {
        appState.currentPlayingResourceInQueue = realIndex;
      } else {
        appState.currentPlayingSongInQueue = realIndex;
      }

      try {
        if (_currentPlatform == 3) {
          await appState.initResourcesPlayer();
        } else {
          await appState.initSongsPlayer();
        }
      } catch (e) {
        MyToast.showToast('Exception: $e');
        MyLogger.logger.e('Exception: $e');
        appState.songsQueue = [];
        appState.resourcesQueue = [];
        appState.currentPlayingSongInQueue = 0;
        appState.currentPlayingResourceInQueue = 0;
        appState.currentDetailSong = null;
        appState.currentDetailResource = null;
        appState.currentSong = null;
        appState.currentResource = null;
        appState.prevSong = null;
        appState.prevResource = null;
        appState.isSongPlaying = false;
        appState.isResourcePlaying = false;
        appState.songsPlayer!.stop();
        appState.songsPlayer!.dispose();
        appState.songsPlayer = null;
        appState.resourcesPlayer!.stop();
        appState.resourcesPlayer!.dispose();
        appState.resourcesPlayer = null;
        appState.songsAudioSource!.clear();
        appState.resourcesAudioSource!.clear();
        appState.isSongsPlayerPageOpened = false;
        appState.canSongsPlayerPagePop = false;
        appState.isResourcesPlayerPageOpened = false;
        appState.canResourcesPlayerPagePop = false;
        return;
      }
      if (_currentPlatform == 3) {
        appState.canResourcesPlayerPagePop = true;
        appState.currentResource = appState.resourcesQueue![realIndex];
        appState.prevResource = appState.currentResource;
        appState.currentDetailResource = null;
        appState.isFirstLoadResourcesPlayer = true;
        appState.resourcesPlayer!.play();
      } else {
        appState.canSongsPlayerPagePop = true;
        appState.currentSong = appState.songsQueue![realIndex];
        appState.prevSong = appState.currentSong;
        appState.currentDetailSong = null;
        appState.isFirstLoadSongsPlayer = true;
        appState.songsPlayer!.play();
      }
    } else if ((_currentPlatform != 3 &&
            appState.currentSong == appState.rawSongsInLibrary![index]) ||
        (_currentPlatform == 3 &&
            appState.currentResource ==
                appState.rawResourcesInFavList![index])) {
      if (!_player!.playerState.playing) {
        _player!.play();
      }
    } else {
      if (_currentPlatform == 0) {
        throw UnimplementedError('Not yet implement pms platform');
      } else if (_currentPlatform == 1) {
        appState.songsQueue = _searchedSongs
            .where((song) => !song.isTakenDown && (song.payPlay == 0))
            .toList();
      } else if (_currentPlatform == 2) {
        appState.songsQueue =
            _searchedSongs.where((song) => !song.isTakenDown).toList();
      } else if (_currentPlatform == 3) {
        appState.resourcesQueue = _searchedResources;
      } else {
        throw UnsupportedError('Invalid platform');
      }

      // Real index in queue, not in raw queue as some songs may be taken down.
      int realIndex = _currentPlatform == 3
          ? index
          : appState.songsQueue!.indexOf(appState.rawSongsInLibrary![index]);

      if (_currentPlatform == 3) {
        appState.canResourcesPlayerPagePop = true;
        appState.resourcesPlayer!.stop();
        appState.resourcesPlayer!.dispose();
        appState.resourcesPlayer = null;
        appState.resourcesAudioSource!.clear();
        appState.currentPlayingResourceInQueue = realIndex;
        try {
          await appState.initResourcesPlayer();
        } catch (e) {
          MyToast.showToast('Exception: $e');
          MyLogger.logger.e('Exception: $e');
          appState.resourcesQueue = [];
          appState.currentPlayingResourceInQueue = 0;
          appState.currentDetailResource = null;
          appState.currentResource = null;
          appState.prevResource = null;
          appState.isResourcePlaying = false;
          appState.resourcesPlayer!.stop();
          appState.resourcesPlayer!.dispose();
          appState.resourcesPlayer = null;
          appState.resourcesAudioSource!.clear();
          appState.isResourcesPlayerPageOpened = false;
          appState.canResourcesPlayerPagePop = false;
          return;
        }
        appState.currentResource = appState.resourcesQueue![realIndex];
        appState.currentDetailResource = null;
        appState.prevResource = appState.currentResource;
        appState.isFirstLoadResourcesPlayer = true;
        appState.resourcesPlayer!.play();
      } else {
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
          appState.songsQueue = [];
          appState.currentPlayingSongInQueue = 0;
          appState.currentDetailSong = null;
          appState.currentSong = null;
          appState.prevSong = null;
          appState.isSongPlaying = false;
          appState.songsPlayer!.stop();
          appState.songsPlayer!.dispose();
          appState.songsPlayer = null;
          appState.songsAudioSource!.clear();
          appState.isSongsPlayerPageOpened = false;
          appState.canSongsPlayerPagePop = false;
          return;
        }
        appState.currentSong = appState.songsQueue![realIndex];
        appState.currentDetailSong = null;
        appState.prevSong = appState.currentSong;
        appState.isFirstLoadSongsPlayer = true;
        appState.songsPlayer!.play();
      }
    }
    if (_currentPlatform == 3 && context.mounted) {
      // appState.isResourcesPlayerPageOpened = true;
      appState.currentResource = _searchedResources[index];
      Navigator.pushNamed(context, '/detail_resource_page');
    } else {
      appState.isSongsPlayerPageOpened = true;
      Navigator.pushNamed(context, '/songs_player_page');
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

  @override
  Widget build(BuildContext context) {
    print('build searching result page');
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    _appState = appState;
    _keyword = appState.keyword;
    _currentPlatform = appState.currentPlatform;
    _isUsingMockData = appState.isUsingMockData;
    _hasMore = appState.hasMore!;
    _player =
        _currentPlatform == 3 ? appState.resourcesPlayer : appState.songsPlayer;
    _count = _currentPlatform == 3
        ? appState.searchedResources.length
        : appState.searchedSongs.length;
    var openedLibrary = appState.openedLibrary;
    // _rawItem = _currentPlatform == 3
    //     ? appState.rawResourcesInFavList
    //     : appState.rawSongsInLibrary;
    // _searchedSongs = appState.searchedSongs;
    if (openedLibrary == null || openedLibrary.itemCount >= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appState.openedLibrary = BasicLibrary(
          name: 'searched results',
          cover: '',
          itemCount: -2,
        );
      });
    }
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (appState.rawSongsInLibrary == null ||
    //       appState.rawSongsInLibrary!.length != _searchedSongs.length ||
    //       _changeRawQueue) {
    //     appState.rawSongsInLibrary = _searchedSongs;
    //     _changeRawQueue = false;
    //   }
    // });

    return WillPopScope(
      onWillPop: () async {
        appState.searchedSongs.clear();
        appState.searchedResources.clear();
        return true; // Allow the navigation to proceed
      },
      child: Consumer<ThemeNotifier>(
        builder: (context, theme, _) => Scaffold(
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
                      inDetailLibraryPage: false,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
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
                            child: Padding(
                              padding:
                                  EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: _count != 0
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 20.0,
                                              top: 10.0,
                                              bottom: 10.0,
                                            ),
                                            child: Text(
                                              'Searched results: $_count',
                                              textAlign: TextAlign.start,
                                              style: textTheme.titleSmall,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Expanded(
                                            child: ListView.builder(
                                              controller: _scrollController,
                                              itemCount: _currentPlatform == 3
                                                  ? _searchedResources.length +
                                                      1
                                                  : _searchedSongs.length + 1,
                                              itemBuilder: (context, index) {
                                                if (index <
                                                    (_currentPlatform == 3
                                                        ? _searchedResources
                                                            .length
                                                        : _searchedSongs
                                                            .length)) {
                                                  if (_currentPlatform == 3) {
                                                    return BiliResourceItem(
                                                      biliSourceFavListId: 0,
                                                      resource:
                                                          _searchedResources[
                                                              index],
                                                      isSelected: false,
                                                      onTap: () {
                                                        _onSearchedItemTapped(
                                                            index, appState);
                                                      },
                                                    );
                                                  } else {
                                                    return Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        onTap: () {
                                                          _onSearchedItemTapped(
                                                              index, appState);
                                                        },
                                                        child: SongItem(
                                                          index: index,
                                                          song: _searchedSongs[
                                                              index],
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  return _buildLoadingIndicator(
                                                      colorScheme);
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(),
                              ),
                            ),
                          ),
                        ),
                        appState.currentSong == null
                            ? Container()
                            : BottomPlayer(),
                      ],
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
