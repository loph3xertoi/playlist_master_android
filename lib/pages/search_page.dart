import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../entities/basic/basic_song.dart';
import '../entities/bilibili/bili_resource.dart';
import '../entities/netease_cloud_music/ncm_song.dart';
import '../entities/qq_music/qqmusic_song.dart';
import '../states/app_state.dart';
import '../states/my_search_state.dart';
import '../utils/my_logger.dart';
import '../utils/my_toast.dart';
import '../utils/string_utils.dart';
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
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> _suggestions = [];

  late List<BasicSong> _searchedSongs;

  late List<BiliResource> _searchedResources;

  bool _isLoading = false;
  // First page is 1 not 0, and first page is loaded in search bar, so this is 2 page.
  int _pageNo = 1;
  int _pageSize = 20;
  late int _currentPlatform;
  MyAppState? _appState;
  late String? _keyword;
  ScrollController _scrollController = ScrollController();
  late bool _hasMore;
  late int _count;
  AudioPlayer? _player;
  // Whether is waiting searched result.
  bool _isSearching = false;

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
    _searchedSongs = state.searchedSongs;
    _searchedResources = state.searchedResources;
    _keyword = state.keyword;
    _currentPlatform = state.currentPlatform;
    _hasMore = state.hasMore;
    _player = state.songsPlayer;
    _count = state.searchedCount;
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasMore) {
        _searchingSong(_appState!);
      } else {
        MyToast.showToast('No more results');
      }
    }
  }

  Future<void> _searchingSong(MyAppState appState) async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      dynamic pagedDataDTO;
      if (_currentPlatform == 0) {
        throw UnimplementedError('Not yet implement pms platform');
      } else if (_currentPlatform == 1) {
        pagedDataDTO = await appState.fetchSearchedSongs<QQMusicSong>(
            _keyword!, ++_pageNo, _pageSize, _currentPlatform);
      } else if (_currentPlatform == 2) {
        pagedDataDTO = await appState.fetchSearchedSongs<NCMSong>(
            _keyword!, ++_pageNo, _pageSize, _currentPlatform);
      } else if (_currentPlatform == 3) {
        pagedDataDTO = await appState.fetchSearchedSongs<BiliResource>(
            _keyword!, ++_pageNo, _pageSize, _currentPlatform);
      } else {
        throw UnsupportedError('Invalid platform');
      }

      if (pagedDataDTO != null) {
        setState(() {
          var list = pagedDataDTO.list;
          appState.searchedCount = pagedDataDTO.count;
          _hasMore = pagedDataDTO.hasMore;
          if (_currentPlatform == 3) {
            _searchedResources.addAll(list!);
          } else {
            _searchedSongs.addAll(list!);
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

  void _onSearchedResourceTapped(int index, MyAppState appState) async {
    if (context.mounted) {
      appState.currentResource = _searchedResources[index];
      Navigator.pushNamed(context, '/detail_resource_page');
    }
  }

  void _onSearchedItemTapped(int index, MyAppState appState) async {
    // if (!kIsWeb &&
    //     Platform.isLinux &&
    //     Process.runSync("which", ["mpv"]).exitCode != 0) {
    //   MyToast.showToast('mpv not found in linux, please install it first');
    //   MyLogger.logger.e('mpv not found in linux, please install it first');
    //   return;
    // }
    if (!(kIsWeb || Platform.isAndroid || Platform.isIOS)) {
      MyToast.showToast(
          'just_audio not supported on ${Platform.operatingSystem}');
      MyLogger.logger
          .e('just_audio not supported on ${Platform.operatingSystem}');
      return;
    }
    var isTakenDown = _searchedSongs[index].isTakenDown;
    var payPlayType = _searchedSongs[index].payPlay;

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
            .where((song) =>
                !song.isTakenDown && (song.payPlay == 0 || song.payPlay == 8))
            .toList();
      } else if (_currentPlatform == 2) {
        appState.songsQueue =
            _searchedSongs.where((song) => !song.isTakenDown).toList();
      } else {
        throw UnsupportedError('Invalid platform');
      }

      // Real index in queue, not in raw queue as some songs may be taken down.
      int realIndex = appState.songsQueue!.indexOf(_searchedSongs[index]);

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
        appState.songsAudioSource!.clear();
        appState.songsPlayer!.dispose();
        appState.songsPlayer = null;
        appState.isSongsPlayerPageOpened = false;
        appState.canSongsPlayerPagePop = false;
        return;
      }

      appState.canSongsPlayerPagePop = true;
      appState.currentSong = appState.songsQueue![realIndex];
      appState.prevSong = appState.currentSong;
      appState.currentDetailSong = null;
      appState.isFirstLoadSongsPlayer = true;
      appState.songsPlayer!.play();
    } else if (appState.currentSong == _searchedSongs[index]) {
      if (!_player!.playerState.playing) {
        _player!.play();
      }
    } else {
      if (_currentPlatform == 0) {
        throw UnimplementedError('Not yet implement pms platform');
      } else if (_currentPlatform == 1) {
        appState.songsQueue = _searchedSongs
            .where((song) =>
                !song.isTakenDown && (song.payPlay == 0 || song.payPlay == 8))
            .toList();
      } else if (_currentPlatform == 2) {
        appState.songsQueue =
            _searchedSongs.where((song) => !song.isTakenDown).toList();
      } else {
        throw UnsupportedError('Invalid platform');
      }

      // Real index in queue, not in raw queue as some songs may be taken down.
      int realIndex = appState.songsQueue!.indexOf(_searchedSongs[index]);
      appState.canSongsPlayerPagePop = true;
      appState.songsPlayer!.stop();
      appState.songsAudioSource!.clear();
      appState.songsPlayer!.dispose();
      appState.songsPlayer = null;
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
        appState.songsAudioSource!.clear();
        appState.songsPlayer!.dispose();
        appState.songsPlayer = null;
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
    if (mounted) {
      appState.isSongsPlayerPageOpened = true;
      Navigator.pushNamed(context, '/songs_player_page');
    }
  }

  Widget _buildLoadingIndicator(ColorScheme colorScheme, bool isLoading) {
    return isLoading
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: SizedBox(
                  height: 10.0,
                  width: 10.0,
                  child: CircularProgressIndicator(
                    color: _currentPlatform != 3
                        ? colorScheme.onPrimary
                        : Color(0xFFFB6A9D),
                    strokeWidth: 2.0,
                  )),
            ),
          )
        : Container();
  }

  Widget _buildFetchingSearchResultLoadingIndicator(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: SizedBox(
            height: 20.0,
            width: 20.0,
            child: CircularProgressIndicator(
              color: _currentPlatform != 3
                  ? colorScheme.onPrimary
                  : Color(0xFFFB6A9D),
              strokeWidth: 2.0,
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('build searching result page');
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    _isSearching = appState.isSearching;
    _suggestions = appState.searchSuggestions;
    _searchedSongs = appState.searchedSongs;
    _searchedResources = appState.searchedResources;
    _appState = appState;
    _keyword = appState.keyword;
    _currentPlatform = appState.currentPlatform;
    _hasMore = appState.hasMore;
    _player = appState.songsPlayer;
    _count = appState.searchedCount;
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

    return PopScope(
      onPopInvoked: (bool didPop) {
        appState.searchedSongs = [];
        appState.searchedResources = [];
        appState.searchedCount = 0;
        appState.searchSuggestions = [];
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
                                          InkWell(
                                            onTap: () {
                                              print(appState);
                                            },
                                            child: Padding(
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
                                                        _onSearchedResourceTapped(
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
                                                      colorScheme, _isLoading);
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      )
                                    : _isSearching
                                        ? _buildFetchingSearchResultLoadingIndicator(
                                            colorScheme)
                                        : _searchSuggestion(colorScheme),
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

  Widget _searchSuggestion(ColorScheme colorScheme) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: (_appState!.searchTextEditingController == null ||
              _appState!.searchTextEditingController!.text.isEmpty)
          ? 0
          : _suggestions.length,
      itemBuilder: (BuildContext context, int index) {
        var suggestion = Html(
          data: '<header>${_suggestions[index]}</header>',
          style: {
            'em': Style(
              color: Color(0xFFFB6A9D),
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold,
            ),
            'header': Style(
              fontStyle: FontStyle.normal,
              maxLines: 1,
              textOverflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary.withOpacity(0.6),
            ),
          },
        );
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              print(_suggestions[index]);
              var finalKeyword =
                  StringUtils.extractWholeName(_suggestions[index]);
              _suggestions.clear;
              _appState!.searchSuggestions = [];
              print(finalKeyword);
              _keyword = finalKeyword;
              _appState!.searchTextEditingController!.text = finalKeyword;
              _appState!.onSearchBarSubmit!(finalKeyword);
            },
            borderRadius: index == 0
                ? BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  )
                : null,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: SizedBox(
                height: 44.0,
                child: Center(
                  child: suggestion,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
