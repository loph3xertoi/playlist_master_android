import 'dart:math';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_song.dart';
import '../mock_data.dart';
import '../states/app_state.dart';
import '../utils/my_logger.dart';
import '../utils/my_toast.dart';
import '../utils/theme_manager.dart';
import '../widgets/bottom_player.dart';
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

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    var isUsingMockData = state.isUsingMockData;
    var openedLibrary = state.openedLibrary;
    if (isUsingMockData) {
      _similarSongs = Future.value(MockData.similarSongs);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        state.rawQueue = MockData.songs;
        state.queue = MockData.songs;
      });
    } else {
      _similarSongs =
          state.fetchSimilarSongs(widget.song, state.currentPlatform);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build similar songs page');
    MyAppState appState = context.watch<MyAppState>();
    var isUsingMockData = appState.isUsingMockData;
    var rawQueue = appState.rawQueue;
    var currentPlayingSongInQueue = appState.currentPlayingSongInQueue;
    var player = appState.player;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SelectableText(
                                      'Exception: ${snapshot.error}',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontFamily: 'Roboto',
                                        fontSize: 16.0,
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
                                      icon: Icon(MdiIcons.webRefresh),
                                      label: Text(
                                        'Retry',
                                        style: textTheme.labelMedium!.copyWith(
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _similarSongs =
                                              appState.fetchSimilarSongs(
                                                  widget.song,
                                                  appState.currentPlatform);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              List<BasicSong> similarSongs =
                                  snapshot.data as List<BasicSong>;
                              rawQueue = similarSongs;
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (appState.rawQueue == null ||
                                    appState.rawQueue!.isEmpty ||
                                    _changeRawQueue) {
                                  appState.rawQueue = similarSongs;
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
                                          SizedBox(
                                            height: 40.0,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  onPressed: () {},
                                                  icon: Icon(
                                                    Icons.playlist_play_rounded,
                                                  ),
                                                  color: colorScheme.tertiary,
                                                ),
                                                IconButton(
                                                  onPressed: () {},
                                                  icon: Icon(
                                                    Icons
                                                        .playlist_add_check_rounded,
                                                  ),
                                                  color: colorScheme.tertiary,
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
                                            child: ListView.builder(
                                              itemCount: isUsingMockData
                                                  ? min(similarSongs.length, 10)
                                                  : similarSongs.length,
                                              itemBuilder: (context, index) {
                                                return Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    // TODO: fix bug: the init cover will be wrong sometimes when first loading
                                                    // song player in shuffle mode.
                                                    onTap: () async {
                                                      if (rawQueue![index]
                                                              .payPlay ==
                                                          1) {
                                                        MyToast.showToast(
                                                            'This song need vip to play');
                                                        MyLogger.logger.e(
                                                            'This song need vip to play');
                                                      } else if (rawQueue![
                                                              index]
                                                          .isTakenDown) {
                                                        MyToast.showToast(
                                                            'This song is taken down');
                                                        MyLogger.logger.e(
                                                            'This song is taken down');
                                                      } else {
                                                        if (appState.player ==
                                                            null) {
                                                          appState.queue = similarSongs
                                                              .where((song) =>
                                                                  !song
                                                                      .isTakenDown &&
                                                                  (song.payPlay ==
                                                                      0))
                                                              .toList();

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

                                                          // appState.player!
                                                          //     .seek(
                                                          //         Duration
                                                          //             .zero,
                                                          //         index:
                                                          //             index);
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
                                                          appState.queue = similarSongs
                                                              .where((song) =>
                                                                  !song
                                                                      .isTakenDown &&
                                                                  (song.payPlay ==
                                                                      0))
                                                              .toList();

                                                          // Real index in queue, not in raw queue as some songs may be taken down.
                                                          int realIndex = appState
                                                              .queue!
                                                              .indexOf(appState
                                                                      .rawQueue![
                                                                  index]);

                                                          print(realIndex);

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
                                                          // appState.currentPage =
                                                          //     '/song_player_page';
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
                                                      }
                                                    },
                                                    child: SongItem(
                                                      index: index,
                                                      song: rawQueue![index],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        ],
                                      )
                                    : Center(
                                        child: TextButton(
                                          onPressed: () {},
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
