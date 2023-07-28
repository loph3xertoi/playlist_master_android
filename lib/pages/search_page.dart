import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../entities/basic/basic_paged_songs.dart';
import '../entities/basic/basic_song.dart';
import '../entities/netease_cloud_music/ncm_paged_songs.dart';
import '../entities/qq_music/qqmusic_paged_songs.dart';
import '../states/app_state.dart';
import '../states/my_search_state.dart';
import '../utils/my_logger.dart';
import '../utils/my_toast.dart';
import '../utils/theme_manager.dart';
import '../widgets/bottom_player.dart';
import '../widgets/my_searchbar.dart';
import '../widgets/song_item.dart';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<BasicSong>? _searchedSongs;
  bool _isLoading = false;
  // First page is 1 not 0, and first page is loaded in search bar, so this is 2 page.
  late int _currentPage;
  late int _platform;
  late int _pageSize;
  late MyAppState state;
  String? _searchingName;
  ScrollController _scrollController = ScrollController();
  late Future<BasicPagedSongs?> Function(String, int, int, int)
      _fetchSearchedSongs;
  bool _changeRawQueue = true;

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
    this.state = state;
    _fetchSearchedSongs = state.fetchSearchedSongs;
    _searchingName = state.searchingString;
    _platform = state.currentPlatform;
    _pageSize = state.pageSize;
    _currentPage = state.currentPage;
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      searchingSong(_searchingName!);
    }
  }

  Future<void> searchingSong(String songName) async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      BasicPagedSongs? songs = await _fetchSearchedSongs(
          songName, _currentPage, _pageSize, _platform);

      if (songs != null) {
        setState(() {
          if (_platform == 0) {
            throw UnimplementedError('Not yet implement pms platform');
          } else if (_platform == 1) {
            _searchedSongs!.addAll((songs as QQMusicPagedSongs).songs);
          } else if (_platform == 2) {
            _searchedSongs!.addAll((songs as NCMPagedSongs).songs);
          } else if (_platform == 3) {
            throw UnimplementedError(
              'Not yet implement bilibili platform',
            );
          } else {
            throw UnsupportedError('Invalid platform');
          }
          _currentPage++;
          state.currentPage++;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Fetch songs failed');
      }
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
    // : Center(
    //     child: Text(
    //     'No searched result.',
    //     // style: textTheme.labelLarge,
    //   ));
  }

  @override
  Widget build(BuildContext context) {
    print('build searching song page');
    MyAppState appState = context.watch<MyAppState>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    var isUsingMockData = appState.isUsingMockData;
    var totalSearchedSongs = appState.totalSearchedSongs;
    var openedLibrary = appState.openedLibrary;
    var player = appState.player;
    var rawQueue = appState.rawQueue;
    _currentPage = appState.currentPage;
    _searchedSongs = appState.searchedSongs;
    _pageSize = appState.pageSize;
    _searchingName = appState.searchingString;
    if (openedLibrary == null || openedLibrary.itemCount >= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appState.openedLibrary = BasicLibrary(
          name: 'search song',
          cover: '',
          itemCount: -2,
        );
      });
    }
    if (_searchedSongs != null) {
      rawQueue = _searchedSongs;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (appState.rawQueue == null ||
            appState.rawQueue!.length != _searchedSongs!.length ||
            _changeRawQueue) {
          appState.rawQueue = _searchedSongs;
          _changeRawQueue = false;
        }
      });
    }
    return WillPopScope(
      onWillPop: () async {
        appState.searchedSongs.clear();
        appState.currentPage = 2;
        appState.totalSearchedSongs = 0;
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
                                child: totalSearchedSongs != 0
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
                                              'Searched songs: $totalSearchedSongs',
                                              textAlign: TextAlign.start,
                                              style: textTheme.titleSmall,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Expanded(
                                            child: ListView.builder(
                                              controller: _scrollController,
                                              itemCount:
                                                  _searchedSongs!.length + 1,
                                              itemBuilder: (context, index) {
                                                if (index <
                                                    _searchedSongs!.length) {
                                                  return Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      onTap: () async {
                                                        var isTakenDown =
                                                            rawQueue![index]
                                                                .isTakenDown;
                                                        var payPlayType =
                                                            rawQueue[index]
                                                                .payPlay;
                                                        var currentPlatform =
                                                            appState
                                                                .currentPlatform;
                                                        var player =
                                                            appState.player;

                                                        if (currentPlatform ==
                                                                1 &&
                                                            payPlayType == 1) {
                                                          MyToast.showToast(
                                                              'This song need vip to play');
                                                          MyLogger.logger.e(
                                                              'This song need vip to play');
                                                          return;
                                                        }

                                                        if (isTakenDown) {
                                                          MyToast.showToast(
                                                              'This song is taken down');
                                                          MyLogger.logger.e(
                                                              'This song is taken down');
                                                          return;
                                                        }

                                                        if (appState.player ==
                                                            null) {
                                                          if (currentPlatform ==
                                                              2) {
                                                            appState.queue =
                                                                _searchedSongs!
                                                                    .where((song) =>
                                                                        !song
                                                                            .isTakenDown)
                                                                    .toList();
                                                          } else {
                                                            appState.queue = _searchedSongs!
                                                                .where((song) =>
                                                                    !song
                                                                        .isTakenDown &&
                                                                    (song.payPlay ==
                                                                        0))
                                                                .toList();
                                                          }

                                                          // Real index in queue, not in raw queue as some songs may be taken down.
                                                          int realIndex = appState
                                                              .queue!
                                                              .indexOf(appState
                                                                      .rawQueue![
                                                                  index]);

                                                          try {
                                                            await appState
                                                                .initAudioPlayer();
                                                          } catch (e) {
                                                            MyToast.showToast(
                                                                'Exception: $e');
                                                            MyLogger.logger.e(
                                                                'Exception: $e');
                                                            appState.queue = [];
                                                            appState.currentDetailSong =
                                                                null;
                                                            appState
                                                                .currentPlayingSongInQueue = 0;
                                                            appState.currentSong =
                                                                null;
                                                            appState.prevSong =
                                                                null;
                                                            appState.isPlaying =
                                                                false;
                                                            appState.player!
                                                                .stop();
                                                            appState.player!
                                                                .dispose();
                                                            appState.player =
                                                                null;
                                                            appState.initQueue!
                                                                .clear();
                                                            appState.isPlayerPageOpened =
                                                                false;
                                                            appState.canSongPlayerPagePop =
                                                                false;
                                                            return;
                                                          }

                                                          appState.canSongPlayerPagePop =
                                                              true;

                                                          appState.currentPlayingSongInQueue =
                                                              realIndex;

                                                          appState.currentSong =
                                                              appState.queue![
                                                                  realIndex];

                                                          appState.prevSong =
                                                              appState
                                                                  .currentSong;

                                                          appState.currentDetailSong =
                                                              null;

                                                          appState.isFirstLoadSongPlayer =
                                                              true;

                                                          appState.player!
                                                              .play();
                                                        } else if (appState
                                                                .currentSong ==
                                                            appState.rawQueue![
                                                                index]) {
                                                          if (!player!
                                                              .playerState
                                                              .playing) {
                                                            player.play();
                                                          }
                                                        } else {
                                                          if (currentPlatform ==
                                                              2) {
                                                            appState.queue =
                                                                _searchedSongs!
                                                                    .where((song) =>
                                                                        !song
                                                                            .isTakenDown)
                                                                    .toList();
                                                          } else {
                                                            appState.queue = _searchedSongs!
                                                                .where((song) =>
                                                                    !song
                                                                        .isTakenDown &&
                                                                    (song.payPlay ==
                                                                        0))
                                                                .toList();
                                                          }

                                                          // Real index in queue, not in raw queue as some songs may be taken down.
                                                          int realIndex = appState
                                                              .queue!
                                                              .indexOf(appState
                                                                      .rawQueue![
                                                                  index]);

                                                          appState.canSongPlayerPagePop =
                                                              true;

                                                          appState.player!
                                                              .stop();

                                                          appState.player!
                                                              .dispose();

                                                          appState.player =
                                                              null;

                                                          appState.initQueue!
                                                              .clear();

                                                          try {
                                                            await appState
                                                                .initAudioPlayer();
                                                          } catch (e) {
                                                            MyToast.showToast(
                                                                'Exception: $e');
                                                            MyLogger.logger.e(
                                                                'Exception: $e');
                                                            appState.queue = [];
                                                            appState.currentDetailSong =
                                                                null;
                                                            appState
                                                                .currentPlayingSongInQueue = 0;
                                                            appState.currentSong =
                                                                null;
                                                            appState.prevSong =
                                                                null;
                                                            appState.isPlaying =
                                                                false;
                                                            appState.player!
                                                                .stop();
                                                            appState.player!
                                                                .dispose();
                                                            appState.player =
                                                                null;
                                                            appState.initQueue!
                                                                .clear();
                                                            appState.isPlayerPageOpened =
                                                                false;
                                                            appState.canSongPlayerPagePop =
                                                                false;
                                                            return;
                                                          }

                                                          appState.currentPlayingSongInQueue =
                                                              realIndex;

                                                          appState.currentSong =
                                                              appState.queue![
                                                                  realIndex];

                                                          appState.currentDetailSong =
                                                              null;

                                                          appState.prevSong =
                                                              appState
                                                                  .currentSong;

                                                          appState.isFirstLoadSongPlayer =
                                                              true;

                                                          appState.player!
                                                              .play();
                                                        }
                                                        appState.isPlayerPageOpened =
                                                            true;
                                                        if (context.mounted) {
                                                          Navigator.pushNamed(
                                                              context,
                                                              '/song_player_page');
                                                        }
                                                      },
                                                      child: SongItem(
                                                        index: index,
                                                        song: _searchedSongs![
                                                            index],
                                                      ),
                                                    ),
                                                  );
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
