import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_song.dart';
import '../mock_data.dart';
import '../states/app_state.dart';
import '../utils/my_logger.dart';
import '../utils/my_toast.dart';
import '../utils/theme_manager.dart';
import '../widgets/bottom_player.dart';
import '../widgets/multi_songs_select_popup.dart';
import '../widgets/my_selectable_text.dart';
import '../widgets/song_item.dart';

class SimilarSongsPage extends StatefulWidget {
  const SimilarSongsPage({super.key, required this.song});

  final BasicSong song;

  @override
  State<SimilarSongsPage> createState() => _SimilarSongsPageState();
}

class _SimilarSongsPageState extends State<SimilarSongsPage> {
  late Future<List<BasicSong>?> _similarSongs;
  bool _changeRawQueue = true;
  late int _currentPlatform;
  late bool _isUsingMockData;
  late AudioPlayer? _player;
  late List<BasicSong>? _rawSongsInLibrary;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    _isUsingMockData = state.isUsingMockData;
    if (_isUsingMockData) {
      _similarSongs = Future.value(MockData.similarSongs);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        state.rawSongsInLibrary = MockData.songs;
        state.songsQueue = MockData.songs;
      });
    } else {
      _similarSongs = state.fetchSimilarSongs(widget.song, _currentPlatform);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build similar songs page');
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    _currentPlatform = appState.currentPlatform;
    _isUsingMockData = appState.isUsingMockData;
    _player = appState.songsPlayer;
    _rawSongsInLibrary = appState.rawSongsInLibrary;
    return Consumer<ThemeNotifier>(
      builder: (context, theme, _) => Material(
        child: Scaffold(
          // key: _scaffoldKey,
          body: SafeArea(
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
                      margin: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
                      child: FutureBuilder(
                          future: _similarSongs,
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    MySelectableText(
                                      snapshot.hasError
                                          ? '${snapshot.error}'
                                          : appState.errorMsg,
                                      style: textTheme.labelMedium!.copyWith(
                                        color: colorScheme.onPrimary,
                                      ),
                                    ),
                                    TextButton.icon(
                                      style: ButtonStyle(
                                        shadowColor: MaterialStateProperty.all(
                                          colorScheme.primary,
                                        ),
                                        overlayColor: MaterialStateProperty.all(
                                          Colors.grey,
                                        ),
                                      ),
                                      icon: Icon(
                                        MdiIcons.webRefresh,
                                        color: colorScheme.onPrimary,
                                      ),
                                      label: Text(
                                        'Retry',
                                        style: textTheme.labelMedium!.copyWith(
                                          color: colorScheme.onPrimary,
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _changeRawQueue = true;
                                          _similarSongs =
                                              appState.fetchSimilarSongs(
                                                  widget.song,
                                                  _currentPlatform);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              List<BasicSong> similarSongs =
                                  snapshot.data!.cast<BasicSong>().toList();
                              _rawSongsInLibrary = similarSongs;
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (_rawSongsInLibrary == null ||
                                    _rawSongsInLibrary!.isEmpty ||
                                    _changeRawQueue) {
                                  appState.rawSongsInLibrary = similarSongs;
                                  _changeRawQueue = false;
                                }
                              });
                              return Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: similarSongs.isNotEmpty
                                    ? Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  icon: Icon(
                                                    Icons.arrow_back_rounded,
                                                  ),
                                                  color: colorScheme.tertiary,
                                                ),
                                                Expanded(
                                                  child: RichText(
                                                    textAlign: TextAlign.center,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    text: TextSpan(
                                                      text:
                                                          'Similar songs for: ',
                                                      style:
                                                          textTheme.labelSmall,
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                          text:
                                                              widget.song.name,
                                                          style: textTheme
                                                              .labelMedium,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 40.0,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  onPressed: () async {
                                                    if (_player == null) {
                                                      appState.songsQueue =
                                                          similarSongs
                                                              .where((song) =>
                                                                  !song
                                                                      .isTakenDown &&
                                                                  (song.payPlay ==
                                                                      0))
                                                              .toList();

                                                      // Real index in songsQueue, not in raw songsQueue as some songs may be taken down.
                                                      int realIndex = appState
                                                          .songsQueue!
                                                          .indexOf(
                                                              similarSongs[0]);
                                                      appState.currentPlayingSongInQueue =
                                                          realIndex;
                                                      try {
                                                        await appState
                                                            .initSongsPlayer();
                                                      } catch (e) {
                                                        MyToast.showToast(
                                                            'Exception: $e');
                                                        MyLogger.logger
                                                            .e('Exception: $e');
                                                        appState.songsQueue =
                                                            [];
                                                        appState.currentDetailSong =
                                                            null;
                                                        appState
                                                            .currentPlayingSongInQueue = 0;
                                                        appState.currentSong =
                                                            null;
                                                        appState.prevSong =
                                                            null;
                                                        appState.isSongPlaying =
                                                            false;
                                                        _player!.stop();
                                                        _player!.dispose();
                                                        appState.songsPlayer =
                                                            null;
                                                        appState
                                                            .songsAudioSource!
                                                            .clear();
                                                        appState.isSongsPlayerPageOpened =
                                                            false;
                                                        appState.canSongsPlayerPagePop =
                                                            false;
                                                        return;
                                                      }

                                                      appState.currentSong =
                                                          appState.songsQueue![
                                                              realIndex];

                                                      appState.prevSong =
                                                          appState.currentSong;

                                                      appState.currentDetailSong =
                                                          null;

                                                      _player!.play();
                                                    } else {
                                                      appState.songsQueue =
                                                          similarSongs
                                                              .where((song) =>
                                                                  !song
                                                                      .isTakenDown &&
                                                                  (song.payPlay ==
                                                                      0))
                                                              .toList();

                                                      // Real index in songsQueue, not in raw songsQueue as some songs may be taken down.
                                                      int realIndex = appState
                                                          .songsQueue!
                                                          .indexOf(
                                                              similarSongs[0]);

                                                      _player!.stop();

                                                      _player!.dispose();

                                                      appState.songsPlayer =
                                                          null;

                                                      appState.songsAudioSource!
                                                          .clear();

                                                      appState.currentPlayingSongInQueue =
                                                          realIndex;
                                                      try {
                                                        await appState
                                                            .initSongsPlayer();
                                                      } catch (e) {
                                                        MyToast.showToast(
                                                            'Exception: $e');
                                                        MyLogger.logger
                                                            .e('Exception: $e');
                                                        appState.songsQueue =
                                                            [];
                                                        appState.currentDetailSong =
                                                            null;
                                                        appState
                                                            .currentPlayingSongInQueue = 0;
                                                        appState.currentSong =
                                                            null;
                                                        appState.prevSong =
                                                            null;
                                                        appState.isSongPlaying =
                                                            false;
                                                        _player!.stop();
                                                        _player!.dispose();
                                                        appState.songsPlayer =
                                                            null;
                                                        appState
                                                            .songsAudioSource!
                                                            .clear();
                                                        appState.isSongsPlayerPageOpened =
                                                            false;
                                                        appState.canSongsPlayerPagePop =
                                                            false;
                                                        return;
                                                      }

                                                      appState.currentSong =
                                                          appState.songsQueue![
                                                              realIndex];

                                                      appState.currentDetailSong =
                                                          null;

                                                      appState.prevSong =
                                                          appState.currentSong;

                                                      _player!.play();
                                                    }
                                                  },
                                                  icon: Icon(
                                                    Icons.playlist_play_rounded,
                                                  ),
                                                  color: colorScheme.tertiary,
                                                  tooltip: 'Play all',
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (_) =>
                                                            MultiSongsSelectPopup(
                                                              inSimilarSongsPage:
                                                                  true,
                                                              similarSongs:
                                                                  similarSongs,
                                                            ));
                                                  },
                                                  icon: Icon(
                                                    Icons.checklist_rounded,
                                                  ),
                                                  color: colorScheme.tertiary,
                                                  tooltip: 'Multi select',
                                                ),
                                                IconButton(
                                                  onPressed: () {},
                                                  icon: Icon(
                                                    Icons.more_vert_rounded,
                                                  ),
                                                  color: colorScheme.tertiary,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: RefreshIndicator(
                                              color: colorScheme.onPrimary,
                                              strokeWidth: 2.0,
                                              onRefresh: () async {
                                                setState(() {
                                                  _changeRawQueue = true;
                                                  _similarSongs = appState
                                                      .fetchSimilarSongs(
                                                          widget.song,
                                                          _currentPlatform);
                                                });
                                              },
                                              child: ListView.builder(
                                                physics:
                                                    const AlwaysScrollableScrollPhysics(),
                                                itemCount: _isUsingMockData
                                                    ? min(
                                                        similarSongs.length, 10)
                                                    : similarSongs.length,
                                                itemBuilder: (context, index) {
                                                  return Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      // TODO: fix bug: the init cover will be wrong sometimes when first loading
                                                      // song player in shuffle mode.
                                                      onTap: () async {
                                                        var isTakenDown =
                                                            _rawSongsInLibrary![
                                                                    index]
                                                                .isTakenDown;
                                                        var payPlayType =
                                                            _rawSongsInLibrary![
                                                                    index]
                                                                .payPlay;

                                                        if (_currentPlatform ==
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

                                                        if (_player == null) {
                                                          if (_currentPlatform ==
                                                              2) {
                                                            appState.songsQueue =
                                                                similarSongs
                                                                    .where((song) =>
                                                                        !song
                                                                            .isTakenDown)
                                                                    .toList();
                                                          } else {
                                                            appState.songsQueue =
                                                                similarSongs
                                                                    .where((song) =>
                                                                        !song
                                                                            .isTakenDown &&
                                                                        (song.payPlay ==
                                                                            0))
                                                                    .toList();
                                                          }

                                                          // Real index in songsQueue, not in raw songsQueue as some songs may be taken down.
                                                          int realIndex = appState
                                                              .songsQueue!
                                                              .indexOf(
                                                                  _rawSongsInLibrary![
                                                                      index]);
                                                          appState.currentPlayingSongInQueue =
                                                              realIndex;
                                                          try {
                                                            await appState
                                                                .initSongsPlayer();
                                                          } catch (e) {
                                                            MyToast.showToast(
                                                                'Exception: $e');
                                                            MyLogger.logger.e(
                                                                'Exception: $e');
                                                            appState.songsQueue =
                                                                [];
                                                            appState.currentDetailSong =
                                                                null;
                                                            appState
                                                                .currentPlayingSongInQueue = 0;
                                                            appState.currentSong =
                                                                null;
                                                            appState.prevSong =
                                                                null;
                                                            appState.isSongPlaying =
                                                                false;
                                                            _player!.stop();
                                                            _player!.dispose();
                                                            appState.songsPlayer =
                                                                null;
                                                            appState
                                                                .songsAudioSource!
                                                                .clear();
                                                            appState.isSongsPlayerPageOpened =
                                                                false;
                                                            appState.canSongsPlayerPagePop =
                                                                false;
                                                            return;
                                                          }

                                                          appState.canSongsPlayerPagePop =
                                                              true;

                                                          appState.currentSong =
                                                              appState.songsQueue![
                                                                  realIndex];

                                                          appState.prevSong =
                                                              appState
                                                                  .currentSong;

                                                          appState.currentDetailSong =
                                                              null;

                                                          appState.isFirstLoadSongsPlayer =
                                                              true;

                                                          _player!.play();
                                                        } else if (appState
                                                                .currentSong ==
                                                            _rawSongsInLibrary![
                                                                index]) {
                                                          if (!_player!
                                                              .playerState
                                                              .playing) {
                                                            _player!.play();
                                                          }
                                                        } else {
                                                          if (_currentPlatform ==
                                                              2) {
                                                            appState.songsQueue =
                                                                similarSongs
                                                                    .where((song) =>
                                                                        !song
                                                                            .isTakenDown)
                                                                    .toList();
                                                          } else {
                                                            appState.songsQueue =
                                                                similarSongs
                                                                    .where((song) =>
                                                                        !song
                                                                            .isTakenDown &&
                                                                        (song.payPlay ==
                                                                            0))
                                                                    .toList();
                                                          }

                                                          // Real index in songsQueue, not in raw songsQueue as some songs may be taken down.
                                                          int realIndex = appState
                                                              .songsQueue!
                                                              .indexOf(
                                                                  _rawSongsInLibrary![
                                                                      index]);

                                                          appState.canSongsPlayerPagePop =
                                                              true;

                                                          _player!.stop();

                                                          _player!.dispose();

                                                          appState.songsPlayer =
                                                              null;

                                                          appState
                                                              .songsAudioSource!
                                                              .clear();
                                                          appState.currentPlayingSongInQueue =
                                                              realIndex;
                                                          try {
                                                            await appState
                                                                .initSongsPlayer();
                                                          } catch (e) {
                                                            MyToast.showToast(
                                                                'Exception: $e');
                                                            MyLogger.logger.e(
                                                                'Exception: $e');
                                                            appState.songsQueue =
                                                                [];
                                                            appState.currentDetailSong =
                                                                null;
                                                            appState
                                                                .currentPlayingSongInQueue = 0;
                                                            appState.currentSong =
                                                                null;
                                                            appState.prevSong =
                                                                null;
                                                            appState.isSongPlaying =
                                                                false;
                                                            _player!.stop();
                                                            _player!.dispose();
                                                            appState.songsPlayer =
                                                                null;
                                                            appState
                                                                .songsAudioSource!
                                                                .clear();
                                                            appState.isSongsPlayerPageOpened =
                                                                false;
                                                            appState.canSongsPlayerPagePop =
                                                                false;
                                                            return;
                                                          }

                                                          appState.currentSong =
                                                              appState.songsQueue![
                                                                  realIndex];

                                                          appState.currentDetailSong =
                                                              null;

                                                          appState.prevSong =
                                                              appState
                                                                  .currentSong;

                                                          appState.isFirstLoadSongsPlayer =
                                                              true;

                                                          _player!.play();
                                                        }
                                                        appState.isSongsPlayerPageOpened =
                                                            true;
                                                        if (context.mounted) {
                                                          Navigator.pushNamed(
                                                              context,
                                                              '/songs_player_page');
                                                        }
                                                      },
                                                      child: SongItem(
                                                        index: index,
                                                        song:
                                                            _rawSongsInLibrary![
                                                                index],
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
                                        child: TextButton(
                                          onPressed: () {
                                            MyToast.showToast(
                                                'To be implement');
                                          },
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
                                          child: Text(
                                            'Add songs',
                                            style: textTheme.labelMedium,
                                          ),
                                        ),
                                      ),
                              );
                            }
                          }),
                    ),
                  ),
                  appState.currentSong == null ? Container() : BottomPlayer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
