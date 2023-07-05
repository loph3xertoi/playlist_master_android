import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/retry.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:playlistmaster/entities/detail_song.dart';
import 'package:playlistmaster/entities/song.dart';
import 'package:playlistmaster/http/api.dart';
import 'package:http/http.dart' as http;
import 'package:playlistmaster/http/my_http.dart';
import 'package:playlistmaster/mock_data.dart';
import 'package:playlistmaster/states/app_state.dart';
import 'package:playlistmaster/third_lib_change/just_audio/common.dart';
import 'package:playlistmaster/third_lib_change/like_button/like_button.dart';
import 'package:playlistmaster/utils/my_logger.dart';
import 'package:playlistmaster/utils/my_toast.dart';
import 'package:playlistmaster/utils/theme_manager.dart';
import 'package:playlistmaster/widgets/create_queue_popup.dart';
import 'package:playlistmaster/widgets/create_songplayer_menu_popup.dart';
import 'package:playlistmaster/widgets/my_lyrics_displayer.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SongPlayerPage extends StatefulWidget {
  const SongPlayerPage({super.key});

  @override
  State<SongPlayerPage> createState() => _SongPlayerPageState();
}

// TODO: The widget tree will always be rebuild when open lyrics page.
class _SongPlayerPageState extends State<SongPlayerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _songCoverRotateAnimation;
  bool _isFirstLoadSongPlayer = false;
  bool _toggleLyrics = false;
  bool _isPlaying = false;
  int _prevSongIndex = 0;
  // True for return original page as all songs are taken down.
  bool _return = false;

  var _lyricPadding = 40.0;
  LyricsReaderModel? _lyricModel;

  double _sliderProgress = 0.0;
  int _playProgress = 0;

  Future<DetailSong?>? _detailSong;
  DetailSong? _simpleDetailSong;
  bool _hasLyrics = true;
  // bool isPlaying = false;
  // double max_value = 211658;
// bool isTap = false;
  var _lyricUI = MyLyricsDisplayer(
    defaultSize: 20.0,
    defaultExtSize: 14.0,
    otherMainSize: 18.0,
    inlineGap: 0.0,
    highlight: true,
  );
  // var myPlaying = false;

  @override
  void initState() {
    final state = Provider.of<MyAppState>(context, listen: false);
    var currentDetailSong = state.currentDetailSong;
    // var isUsingMockData = state.isUsingMockData;
    // var openedPlaylist = state.openedPlaylist;
    // var currentSong = state.currentSong;
    // _tid = ModalRoute.of(context)!.settings.arguments as String;
    // if (isUsingMockData) {
    //   _detailSong = Future.value(MockData.detailSong);
    // } else {
    //   _detailSong = fetchDetailSong(currentSong!.songMid);
    // }
    _detailSong = Future.value(currentDetailSong);

    // _lyricModel = LyricsModelBuilder.create()
    //     .bindLyricToMain(MockData.normalLyric)
    //     .bindLyricToExt(MockData.transLyric)
    //     .getModel();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    );
    _songCoverRotateAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<DetailSong?> fetchDetailSong(String songMid) async {
    DefaultCacheManager cacheManager = MyHttp.cacheManager;
    Uri url = Uri.http(
      API.host,
      '${API.detailSong}/$songMid/1',
    );
    String urlString = url.toString();
    dynamic result = await cacheManager.getFileFromMemory(urlString);
    if (result == null || !(result as FileInfo).file.existsSync()) {
      result = await cacheManager.getFileFromCache(urlString);
      if (result == null || !(result as FileInfo).file.existsSync()) {
        MyLogger.logger.d('Loading detail song from network...');
        final client = RetryClient(http.Client());
        try {
          var response = await client.get(url);
          var decodedResponse =
              jsonDecode(utf8.decode(response.bodyBytes)) as Map;
          if (response.statusCode == 200 &&
              decodedResponse['success'] == true) {
            result = DetailSong.fromJson(decodedResponse['data']);
            await cacheManager.putFile(
              urlString,
              response.bodyBytes,
              fileExtension: 'json',
            );
          } else {
            MyToast.showToast(
                'Response error with code: ${response.statusCode}');
            MyLogger.logger
                .e('Response error with code: ${response.statusCode}');
            result = null;
          }
        } catch (e) {
          MyToast.showToast('Exception thrown: $e');
          MyLogger.logger.e('Network error with exception: $e');
          rethrow;
        } finally {
          client.close();
        }
      } else {
        MyLogger.logger.d('Loading detail song from cache...');
      }
    } else {
      MyLogger.logger.d('Loading detail song from memory...');
    }
    if (result is DetailSong) {
      result = Future.value(result);
    } else if (result is FileInfo) {
      var decodedResponse =
          jsonDecode(utf8.decode(result.file.readAsBytesSync())) as Map;
      result = DetailSong.fromJson(decodedResponse['data']);
      result = Future.value(result);
    } else {}
    return result;
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();

    var isUsingMockData = appState.isUsingMockData;
    var player = appState.player;
    var queue = appState.queue;
    var currentPlayingSongInQueue = appState.currentPlayingSongInQueue;
    var currentSong = appState.currentSong;
    var prevSong = appState.prevSong;
    var currentDetailSong = appState.currentDetailSong;
    var userPlayingMode = appState.userPlayingMode;
    var volume = appState.volume;
    var speed = appState.speed;
    var positionDataStream = appState.positionDataStream;
    var carouselController = appState.carouselController;
    var prevCarouselIndex = appState.prevCarouselIndex;
    var isSkipTakenDownSong = appState.isSkipTakenDownSong;
    String? mainLyrics;

    _isFirstLoadSongPlayer = appState.isFirstLoadSongPlayer;
    _isPlaying = appState.isPlaying;

    if (_simpleDetailSong != currentDetailSong || isSkipTakenDownSong) {
      _simpleDetailSong = currentDetailSong;
      _detailSong = Future.value(currentDetailSong);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appState.isSkipTakenDownSong = false;
      });
    }

    if (_isFirstLoadSongPlayer) {
      if (!(currentSong!.isTakenDown)) {
        player!.seek(Duration.zero, index: currentPlayingSongInQueue);
      } else if (queue!.length > 1) {
        MyToast.showToast('Current song is taken down, skip to next.');
        currentPlayingSongInQueue =
            (currentPlayingSongInQueue! + 1) % queue.length;
        currentSong = queue[currentPlayingSongInQueue];
        prevSong = currentSong;
        prevCarouselIndex = (prevCarouselIndex + 1) % queue.length;
        player!.seek(Duration.zero, index: currentPlayingSongInQueue);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          appState.currentPlayingSongInQueue = currentPlayingSongInQueue;
          appState.currentSong = currentSong;
          appState.prevSong = prevSong;
          appState.prevCarouselIndex = prevCarouselIndex;
          carouselController.animateToPage(currentPlayingSongInQueue!);
        });
      } else {
        MyToast.showToast('All songs is taken down, returning to origin page.');
        _return = true;
      }
      _controller.repeat();
    }

    if ((queue?.isNotEmpty ?? false) &&
        (queue!.length > currentPlayingSongInQueue!) &&
        (currentSong!.name != queue[currentPlayingSongInQueue].name)) {
      _controller.reset();
    }

    if (queue?.isEmpty ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (appState.canSongPlayerPagePop) {
          Navigator.of(context).pop();
          appState.isPlayerPageOpened = false;
          appState.canSongPlayerPagePop = false;
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_return) {
        appState.queue = [];
        appState.currentDetailSong = null;
        appState.currentPlayingSongInQueue = 0;
        appState.currentSong = null;
        appState.prevSong = null;
        appState.isPlaying = false;
        appState.player!.stop();
        appState.player!.dispose();
        appState.player = null;
        appState.initQueue!.clear();
        appState.isPlayerPageOpened = false;
        appState.canSongPlayerPagePop = false;
        Navigator.of(context).pop();
      }
      if ((queue?.isNotEmpty ?? false) &&
          (currentSong != queue?[currentPlayingSongInQueue!])) {
        appState.currentSong = queue?[currentPlayingSongInQueue!];
      }

      if (!_isFirstLoadSongPlayer) {
        if (player != null && player.playing == true) {
          _controller.repeat();
        } else {
          _controller.stop();
        }
      } else {
        Future.delayed(Duration(milliseconds: 200), () {
          appState.isFirstLoadSongPlayer = false;
          // appState.coverRotatingController = _controller;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 0), () {
        if (_prevSongIndex != currentPlayingSongInQueue &&
            carouselController.ready == true &&
            mounted) {
          // carouselController.jumpToPage(currentPlayingSongInQueue!);
          _prevSongIndex = currentPlayingSongInQueue!;
        }
      });
    });

    try {
      if (currentDetailSong == null || prevSong != currentSong) {
        _detailSong = isUsingMockData
            ? Future.value(MockData.detailSong)
            : fetchDetailSong(currentSong!.songMid);
      }
    } on SocketException catch (e) {
      MyToast.showToast('Exception thrown: $e');
      MyLogger.logger.e(e);
      rethrow;
    }
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Consumer<ThemeNotifier>(
      builder: (context, theme, _) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: theme.songPlayerPageBg!,
            stops: [0.0, 0.33, 0.67, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder(
            future: _detailSong,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
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
                        style: textTheme.labelLarge,
                        // style: TextStyle(
                        //   color: Colors.white70,
                        //   fontFamily: 'Roboto',
                        //   fontSize: 16.0,
                        // ),
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
                          style: textTheme.labelMedium,
                        ),
                        onPressed: () {
                          setState(() {
                            _detailSong = fetchDetailSong(currentSong!.songMid);
                          });
                        },
                      ),
                    ],
                  ),
                );
              } else {
                DetailSong detailSong = snapshot.data as DetailSong;
                mainLyrics = detailSong.lyrics.lyric;
                if (_lyricModel == null || prevSong != currentSong) {
                  if (!isUsingMockData) {
                    if (mainLyrics == '[00:00:00]此歌曲为没有填词的纯音乐，请您欣赏') {
                      _hasLyrics = false;
                    } else {
                      _hasLyrics = true;
                      _lyricModel = LyricsModelBuilder.create()
                          .bindLyricToMain(detailSong.lyrics.lyric)
                          .bindLyricToExt(detailSong.lyrics.trans)
                          .getModel();
                    }
                  } else {
                    _lyricModel = LyricsModelBuilder.create()
                        .bindLyricToMain(MockData.normalLyric)
                        .bindLyricToExt(MockData.transLyric)
                        .getModel();
                  }
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (currentDetailSong == null || prevSong != currentSong) {
                    appState.currentDetailSong = detailSong;
                  }
                  if (prevSong != currentSong) {
                    appState.prevSong = currentSong;
                  }
                  if (prevCarouselIndex != currentPlayingSongInQueue) {
                    appState.prevCarouselIndex = currentPlayingSongInQueue!;
                  }
                });

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Container(
                        height: 75.0,
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: double.infinity,
                          height: 42.0,
                          child: Row(children: [
                            IconButton(
                              color: Color(0xE5FFFFFF),
                              icon: Icon(Icons.arrow_back_rounded),
                              onPressed: () {
                                // _appState.initSongPlayer = true;
                                appState.isPlayerPageOpened = false;
                                Navigator.pop(context);
                              },
                            ),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: SelectableText(
                                      detailSong.name,
                                      style: textTheme.labelMedium!.copyWith(
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      // style: TextStyle(
                                      //   color: Color(0xE5FFFFFF),
                                      //   fontFamily: 'Roboto',
                                      //   fontSize: 18.0,
                                      // ),
                                      // overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SelectableText(
                                    detailSong.singers
                                        .map((e) => e.name)
                                        .join(','),
                                    style: textTheme.labelSmall!.copyWith(
                                      fontSize: 12.0,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    // style: TextStyle(
                                    //   color: Color(0x80FFFFFF),
                                    //   fontFamily: 'Roboto',
                                    //   fontSize: 12.0,
                                    // ),
                                    // overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              color: Color(0xE5FFFFFF),
                              icon: Icon(Icons.share_rounded),
                              onPressed: () {
                                print(appState);
                                print('lyrics: $_playProgress');
                                print(
                                    'song: ${player!.position.inMilliseconds}');
                                print(
                                    'diff: ${_playProgress - player.position.inMilliseconds}');
                                setState(() {});
                                // print(max_value);
                              },
                            ),
                          ]),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                          alignment: AlignmentDirectional.topCenter,
                          children: [
                            Positioned(
                              top: 30.0,
                              // height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              // top: (MediaQuery.of(context).size.height - 500.0) / 2,
                              child: IgnorePointer(
                                ignoring: !_toggleLyrics,
                                child: AnimatedOpacity(
                                  opacity: _toggleLyrics ? 1.0 : 0.0,
                                  duration: Duration(milliseconds: 500),
                                  child: ShaderMask(
                                    shaderCallback: (rect) {
                                      return LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        stops: [0.0, 0.1, 0.9, 1.0],
                                        colors: [
                                          Colors.transparent,
                                          Colors.black,
                                          Colors.black,
                                          Colors.transparent
                                        ],
                                      ).createShader(Rect.fromLTRB(
                                          0, 0, rect.width, rect.height));
                                    },
                                    blendMode: BlendMode.dstIn,
                                    child: player != null && _hasLyrics
                                        ? buildReaderWidget(player)
                                        : Center(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _toggleLyrics =
                                                      !_toggleLyrics;
                                                });
                                              },
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: 500.0,
                                                color: Colors.transparent,
                                                child: Center(
                                                  child: Text(
                                                    mainLyrics!.substring(
                                                        mainLyrics!
                                                                .indexOf(']') +
                                                            1),
                                                    style: textTheme
                                                        .labelMedium!
                                                        .copyWith(
                                                      color: Colors.white54,
                                                      fontSize: 16.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top:
                                  (MediaQuery.of(context).size.height - 500.0) /
                                      2,
                              width: MediaQuery.of(context).size.width,
                              child: IgnorePointer(
                                ignoring: _toggleLyrics,
                                child: AnimatedOpacity(
                                  opacity: _toggleLyrics ? 0.0 : 1.0,
                                  duration: Duration(milliseconds: 500),
                                  child: Center(
                                    child: SizedBox(
                                      height: 250.0,
                                      width: MediaQuery.of(context).size.width,
                                      child: CarouselSlider.builder(
                                        carouselController: carouselController,
                                        options: CarouselOptions(
                                          initialPage: player?.effectiveIndices!
                                                  .indexOf(
                                                      currentPlayingSongInQueue!) ??
                                              0,
                                          aspectRatio: 1.0,
                                          viewportFraction:
                                              userPlayingMode == 0 ? 0.8 : 0.6,
                                          enlargeCenterPage: true,
                                          onPageChanged: (index, reason) async {
                                            if (reason ==
                                                CarouselPageChangedReason
                                                    .manual) {
                                              int nextIndex = player!
                                                  .effectiveIndices![index];

                                              bool isForward = (index >
                                                          prevCarouselIndex &&
                                                      index != 0) ||
                                                  (index == 0 &&
                                                      prevCarouselIndex ==
                                                          queue!.length - 1);
                                              appState.prevCarouselIndex =
                                                  index;
                                              Song? nextSong =
                                                  queue![nextIndex];
                                              // AudioSource nextAudioSource =
                                              //     appState.initQueue![nextIndex];

                                              LockCachingAudioSource
                                                  nextAudioSource = (player
                                                          .audioSource!
                                                          .sequence[nextIndex]
                                                      as LockCachingAudioSource);
                                              var songUri = nextAudioSource.uri;

                                              // Network error. Show toast and retrieve the song again.
                                              if (songUri is String &&
                                                  (songUri as String) == '2') {
                                                print(
                                                    'Network error, try again later.');
                                                MyToast.showToast(
                                                    'Network error, try again later.');
                                                String songLinkString =
                                                    await appState
                                                        .fetchSongLink(
                                                            nextSong, '128', 1);
                                                MediaItem originTag =
                                                    nextAudioSource.tag
                                                        as MediaItem;
                                                if (songLinkString != '2') {
                                                  var newAudioSource =
                                                      AudioSource.uri(
                                                    Uri.parse(songLinkString),
                                                    tag: MediaItem(
                                                      id: nextIndex.toString(),
                                                      album: originTag.album,
                                                      artist: originTag.artist,
                                                      title: originTag.title,
                                                      artUri: originTag.artUri,
                                                    ),
                                                  );
                                                  appState.initQueue!
                                                      .removeAt(nextIndex);
                                                  appState.initQueue!.insert(
                                                      nextIndex,
                                                      newAudioSource);
                                                  player.seek(Duration.zero,
                                                      index: nextIndex);
                                                  Future.delayed(
                                                      Duration(
                                                          milliseconds: 700),
                                                      () {
                                                    appState.currentPlayingSongInQueue =
                                                        nextIndex;
                                                    if (!(player
                                                        .playerState.playing)) {
                                                      player.play();
                                                      appState.isPlaying = true;
                                                    }
                                                  });
                                                  return;
                                                } else {
                                                  // Network error still.
                                                  int nextIndex = isForward
                                                      ? player.effectiveIndices![
                                                          (index + 1) %
                                                              queue.length]
                                                      : player.effectiveIndices![
                                                          (index - 1) %
                                                              queue.length];
                                                  player.seek(Duration.zero,
                                                      index: nextIndex);
                                                  Future.delayed(
                                                      Duration(
                                                          milliseconds: 700),
                                                      () {
                                                    appState.currentPlayingSongInQueue =
                                                        nextIndex;
                                                    if (!(player
                                                        .playerState.playing)) {
                                                      player.play();
                                                      appState.isPlaying = true;
                                                    }
                                                  });
                                                  return;
                                                }
                                              }

                                              // Next song is taken down.
                                              if (nextSong.isTakenDown) {
                                                MyToast.showToast(
                                                    'Current song is taken down, skip to next.');
                                                int nextIndex = isForward
                                                    ? player.effectiveIndices![
                                                        (index + 1) %
                                                            queue.length]
                                                    : player.effectiveIndices![
                                                        (index - 1) %
                                                            queue.length];
                                                player.seek(Duration.zero,
                                                    index: nextIndex);
                                                carouselController
                                                    .jumpToPage(nextIndex);
                                                Future.delayed(
                                                    Duration(milliseconds: 700),
                                                    () {
                                                  appState.currentPlayingSongInQueue =
                                                      nextIndex;
                                                  if (!(player
                                                      .playerState.playing)) {
                                                    player.play();
                                                    appState.isPlaying = true;
                                                  }
                                                });
                                                return;
                                              }

                                              player.seek(Duration.zero,
                                                  index: nextIndex);

                                              Future.delayed(
                                                  Duration(milliseconds: 700),
                                                  () {
                                                appState.currentPlayingSongInQueue =
                                                    nextIndex;
                                                if (!(player
                                                    .playerState.playing)) {
                                                  player.play();
                                                  appState.isPlaying = true;
                                                }
                                              });
                                            }
                                          },
                                          onScrolled: (position) {
                                            // print(position);
                                          },
                                          // enlargeStrategy: CenterPageEnlargeStrategy.scale,
                                          enlargeFactor: 0.45,
                                        ),
                                        // items: imageSliders,
                                        itemBuilder: (BuildContext context,
                                            int itemIndex, int pageViewIndex) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 10.0,
                                              bottom: 10.0,
                                            ),
                                            child: Container(
                                              width: 230.0,
                                              height: 230.0,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                // color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color(0x40000000),
                                                    spreadRadius: 0.0,
                                                    blurRadius: 4.0,
                                                    offset: Offset(0.0,
                                                        4.0), // changes position of shadow
                                                  ),
                                                ],
                                              ),
                                              child: (player != null &&
                                                      (player.effectiveIndices
                                                              ?.isNotEmpty ??
                                                          false) &&
                                                      player.effectiveIndices![
                                                              itemIndex] ==
                                                          currentPlayingSongInQueue)
                                                  ? AnimatedBuilder(
                                                      animation:
                                                          _songCoverRotateAnimation,
                                                      builder:
                                                          (BuildContext context,
                                                              Widget? child) {
                                                        return Transform.rotate(
                                                          angle:
                                                              _songCoverRotateAnimation
                                                                      .value *
                                                                  2 *
                                                                  pi,
                                                          child: child,
                                                        );
                                                      },
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    150.0)),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              _toggleLyrics =
                                                                  true;
                                                            });
                                                            print(
                                                                _toggleLyrics);
                                                          },
                                                          child: isUsingMockData
                                                              ? Image.asset(
                                                                  // (_userPlayingMode ==0)?
                                                                  // songsOfPlaylist[itemIndex].coverUri
                                                                  (queue?.isNotEmpty ??
                                                                          false)
                                                                      ? (queue![
                                                                              player.effectiveIndices![itemIndex]]
                                                                          .coverUri)
                                                                      : 'assets/images/songs_cover/tit.jpeg',
                                                                  fit: BoxFit
                                                                      .fitHeight,
                                                                  height: 230.0,
                                                                  width: 230.0,
                                                                )
                                                              : CachedNetworkImage(
                                                                  imageUrl: ((queue?.isNotEmpty ??
                                                                              false) &&
                                                                          queue![player.effectiveIndices![itemIndex]]
                                                                              .coverUri
                                                                              .isNotEmpty)
                                                                      ? (queue[player.effectiveIndices![
                                                                              itemIndex]]
                                                                          .coverUri)
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
                                                                ),
                                                          // : Image(
                                                          //     image: CachedNetworkImageProvider(((queue?.isNotEmpty ??
                                                          //                 false) &&
                                                          //             queue![player.effectiveIndices![itemIndex]]
                                                          //                 .coverUri
                                                          //                 .isNotEmpty)
                                                          //         ? (queue[player.effectiveIndices![
                                                          //                 itemIndex]]
                                                          //             .coverUri)
                                                          //         : MyAppState
                                                          //             .defaultCoverImage),
                                                          //   ),
                                                          // : Image.network(
                                                          //     ((queue?.isNotEmpty ??
                                                          //                 false) &&
                                                          //             queue![player.effectiveIndices![itemIndex]]
                                                          //                 .coverUri
                                                          //                 .isNotEmpty)
                                                          //         ? (queue[player.effectiveIndices![
                                                          //                 itemIndex]]
                                                          //             .coverUri)
                                                          //         : MyAppState
                                                          //             .defaultCoverImage,
                                                          //     fit: BoxFit
                                                          //         .fitHeight,
                                                          //     height: 230.0,
                                                          //     width: 230.0,
                                                          //   ),
                                                        ),
                                                      ),
                                                    )
                                                  : ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  150.0)),
                                                      child: isUsingMockData
                                                          ? Image.asset(
                                                              // (_userPlayingMode ==0)?
                                                              // songsOfPlaylist[itemIndex].coverUri
                                                              (player != null &&
                                                                      (queue?.isNotEmpty ??
                                                                          false))
                                                                  ? queue![player
                                                                              .effectiveIndices![
                                                                          itemIndex]]
                                                                      .coverUri
                                                                  : 'assets/images/songs_cover/tit.jpeg',
                                                              fit: BoxFit
                                                                  .fitHeight,
                                                              height: 230.0,
                                                              width: 230.0,
                                                            )
                                                          : CachedNetworkImage(
                                                              imageUrl: ((player !=
                                                                              null &&
                                                                          (queue?.isNotEmpty ??
                                                                              false)) &&
                                                                      queue![player.effectiveIndices![
                                                                              itemIndex]]
                                                                          .coverUri
                                                                          .isNotEmpty)
                                                                  ? queue[player
                                                                              .effectiveIndices![
                                                                          itemIndex]]
                                                                      .coverUri
                                                                  : MyAppState
                                                                      .defaultCoverImage,
                                                              progressIndicatorBuilder: (context,
                                                                      url,
                                                                      downloadProgress) =>
                                                                  CircularProgressIndicator(
                                                                      value: downloadProgress
                                                                          .progress),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  Icon(MdiIcons
                                                                      .debian),
                                                            ),
                                                      // : Image(
                                                      //     image: CachedNetworkImageProvider(((player !=
                                                      //                     null &&
                                                      //                 (queue?.isNotEmpty ??
                                                      //                     false)) &&
                                                      //             queue![player.effectiveIndices![
                                                      //                     itemIndex]]
                                                      //                 .coverUri
                                                      //                 .isNotEmpty)
                                                      //         ? queue[player
                                                      //                     .effectiveIndices![
                                                      //                 itemIndex]]
                                                      //             .coverUri
                                                      //         : MyAppState
                                                      //             .defaultCoverImage),
                                                      //   ),
                                                      // : Image.network(
                                                      //     ((player != null &&
                                                      //                 (queue?.isNotEmpty ??
                                                      //                     false)) &&
                                                      //             queue![player.effectiveIndices![
                                                      //                     itemIndex]]
                                                      //                 .coverUri
                                                      //                 .isNotEmpty)
                                                      //         ? queue[player
                                                      //                     .effectiveIndices![
                                                      //                 itemIndex]]
                                                      //             .coverUri
                                                      //         : MyAppState
                                                      //             .defaultCoverImage,
                                                      //     fit: BoxFit
                                                      //         .fitHeight,
                                                      //     height: 230.0,
                                                      //     width: 230.0,
                                                      //   ),
                                                    ),
                                            ),
                                          );
                                        },
                                        itemCount: queue?.length,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            AnimatedPositioned(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.fastOutSlowIn,
                              bottom: _toggleLyrics ? 20.0 : 90.0,
                              width: MediaQuery.of(context).size.width,
                              child: IgnorePointer(
                                ignoring: _toggleLyrics,
                                child: AnimatedOpacity(
                                  duration: Duration(milliseconds: 500),
                                  opacity: _toggleLyrics ? 0.0 : 1.0,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                    ),
                                    child: SizedBox(
                                      height: 50.0,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            color: Color(0xE5FFFFFF),
                                            icon: Icon(Icons.volume_up_rounded),
                                            onPressed: () {
                                              //TODO: fix bug: volume more than 1 not works.
                                              showSliderDialog(
                                                context: context,
                                                title: 'Adjust volume',
                                                divisions: 10,
                                                min: 0.0,
                                                max: 1.0,
                                                value: volume!,
                                                stream: player!.volumeStream,
                                                onChanged: (volume) {
                                                  player.setVolume(volume);
                                                  appState.volume = volume;
                                                },
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Text(
                                              '${speed!.toStringAsFixed(1)}x',
                                              style: const TextStyle(
                                                color: Color(0xE5FFFFFF),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            onPressed: () {
                                              showSliderDialog(
                                                context: context,
                                                title: 'Adjust speed',
                                                divisions: 99,
                                                min: 0.1,
                                                max: 10.0,
                                                value: speed,
                                                stream: player!.speedStream,
                                                onChanged: (speed) {
                                                  player.setSpeed(speed);
                                                  appState.speed = speed;
                                                },
                                              );
                                            },
                                          ),
                                          SizedBox(
                                            width: 50.0,
                                            child: LikeButton(
                                              size: 24.0,
                                              isLiked: false,
                                              iconColor: Color(0xE5FFFFFF),
                                            ),
                                          ),
                                          IconButton(
                                            color: Color(0xE5FFFFFF),
                                            icon: Icon(Icons.download_rounded),
                                            onPressed: () {
                                              print(appState);
                                              print(queue);
                                              print(carouselController);
                                              print(player);
                                              setState(() {});
                                            },
                                          ),
                                          IconButton(
                                            color: Color(0xE5FFFFFF),
                                            icon: Icon(Icons.more_vert_rounded),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                // builder: (context) => Dialog(
                                                //   child: Text('hello'),
                                                // ),
                                                builder: (_) =>
                                                    CreateSongplayerMenuDialog(),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0.0,
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 30.0,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: SizedBox(
                                    height: 30.0,
                                    child: StreamBuilder<PositionData>(
                                      stream: positionDataStream,
                                      builder: (context, snapshot) {
                                        final positionData = snapshot.data;
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          if (_toggleLyrics) {
                                            setState(() {
                                              // _playProgress = player.positionStream.
                                              _playProgress = positionData
                                                      ?.position
                                                      .inMilliseconds ??
                                                  0;
                                              _sliderProgress =
                                                  _playProgress.toDouble();
                                            });
                                          }
                                        });
                                        return SeekBar(
                                          duration: positionData?.duration ??
                                              Duration.zero,
                                          position: positionData?.position ??
                                              Duration.zero,
                                          bufferedPosition:
                                              positionData?.bufferedPosition ??
                                                  Duration.zero,
                                          onChangeEnd: player?.seek,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 22.0),
                      child: SizedBox(
                        height: 50.0,
                        child: Row(
                          // mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: Builder(
                                builder: (context) {
                                  if (userPlayingMode == 0) {
                                    return IconButton(
                                      icon: const Icon(Icons.shuffle_rounded),
                                      color: Color(0xE5FFFFFF),
                                      onPressed: () {
                                        setState(() {
                                          appState.userPlayingMode = 1;
                                        });
                                        player!.setShuffleModeEnabled(false);
                                        player.setLoopMode(LoopMode.all);
                                        carouselController.jumpToPage(player
                                            .effectiveIndices!
                                            .indexOf(player.currentIndex!));
                                      },
                                    );
                                  } else if (userPlayingMode == 1) {
                                    return IconButton(
                                      icon: const Icon(Icons.repeat_rounded),
                                      color: Color(0xE5FFFFFF),
                                      onPressed: () {
                                        setState(() {
                                          appState.userPlayingMode = 2;
                                        });
                                        player!.setShuffleModeEnabled(false);
                                        player.setLoopMode(LoopMode.one);
                                      },
                                    );
                                  } else if (userPlayingMode == 2) {
                                    return IconButton(
                                      icon:
                                          const Icon(Icons.repeat_one_rounded),
                                      color: Color(0xE5FFFFFF),
                                      onPressed: () {
                                        setState(() {
                                          appState.userPlayingMode = 0;
                                        });
                                        player!.setShuffleModeEnabled(true);
                                        player.shuffle();
                                        player.setLoopMode(LoopMode.all);
                                        carouselController.jumpToPage(player
                                            .effectiveIndices!
                                            .indexOf(player.currentIndex!));
                                      },
                                    );
                                  } else {
                                    throw Exception(
                                        'Invalid user playing mode.');
                                  }
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.skip_previous_rounded),
                              color: Color(0xE5FFFFFF),
                              onPressed: () async {
                                int? nextIndex = userPlayingMode == 2
                                    ? (player!.currentIndex! - 1) %
                                        (queue?.length ?? 1)
                                    : player!.previousIndex!;

                                // appState.prevCarouselIndex = index;
                                Song? nextSong = queue![nextIndex];

                                LockCachingAudioSource nextAudioSource =
                                    (player.audioSource!.sequence[nextIndex]
                                        as LockCachingAudioSource);
                                var songUri = nextAudioSource.uri;

                                // Network error. Show toast and retrieve the song again.
                                if (songUri is String &&
                                    (songUri as String) == '2') {
                                  print('Network error, try again later.');
                                  MyToast.showToast(
                                      'Network error, try again later.');
                                  String songLinkString = await appState
                                      .fetchSongLink(nextSong, '128', 1);
                                  MediaItem originTag =
                                      nextAudioSource.tag as MediaItem;
                                  if (songLinkString != '2') {
                                    var newAudioSource = AudioSource.uri(
                                      Uri.parse(songLinkString),
                                      tag: MediaItem(
                                        id: nextIndex.toString(),
                                        album: originTag.album,
                                        artist: originTag.artist,
                                        title: originTag.title,
                                        artUri: originTag.artUri,
                                      ),
                                    );
                                    appState.initQueue!.removeAt(nextIndex);
                                    appState.initQueue!
                                        .insert(nextIndex, newAudioSource);
                                    player.seek(Duration.zero,
                                        index: nextIndex);
                                    Future.delayed(Duration(milliseconds: 700),
                                        () {
                                      appState.currentPlayingSongInQueue =
                                          nextIndex;
                                      if (!(player.playerState.playing)) {
                                        player.play();
                                        appState.isPlaying = true;
                                      }
                                    });
                                    carouselController.animateToPage(player
                                        .effectiveIndices!
                                        .indexOf(nextIndex));
                                    return;
                                  } else {
                                    // Network error still.
                                    int? nextIndex = userPlayingMode == 2
                                        ? (player.currentIndex! - 2) %
                                            queue.length
                                        : (player.previousIndex! - 1) %
                                            queue.length;
                                    player.seek(Duration.zero,
                                        index: nextIndex);
                                    Future.delayed(Duration(milliseconds: 700),
                                        () {
                                      appState.currentPlayingSongInQueue =
                                          nextIndex;
                                      if (!(player.playerState.playing)) {
                                        player.play();
                                        appState.isPlaying = true;
                                      }
                                    });
                                    carouselController.animateToPage(player
                                        .effectiveIndices!
                                        .indexOf(nextIndex));
                                    return;
                                  }
                                }

                                // Next song is taken down.
                                if (nextSong.isTakenDown) {
                                  MyToast.showToast(
                                      'Current song is taken down, skip to next.');
                                  int? nextIndex = userPlayingMode == 2
                                      ? (player.currentIndex! - 2) %
                                          queue.length
                                      : (player.previousIndex! - 1) %
                                          queue.length;
                                  player.seek(Duration.zero, index: nextIndex);
                                  Future.delayed(Duration(milliseconds: 700),
                                      () {
                                    appState.currentPlayingSongInQueue =
                                        nextIndex;
                                    if (!(player.playerState.playing)) {
                                      player.play();
                                      appState.isPlaying = true;
                                    }
                                  });
                                  carouselController.animateToPage(player
                                      .effectiveIndices!
                                      .indexOf(nextIndex));
                                  return;
                                }

                                player.seek(Duration.zero, index: nextIndex);

                                Future.delayed(Duration(milliseconds: 700), () {
                                  appState.currentPlayingSongInQueue =
                                      nextIndex;
                                  if (!(player.playerState.playing)) {
                                    player.play();
                                    appState.isPlaying = true;
                                  }
                                });
                                carouselController.animateToPage(player
                                    .effectiveIndices!
                                    .indexOf(nextIndex));
                                // player?.seek(Duration.zero,
                                //     index: userPlayingMode == 2
                                //         ? (player.currentIndex! +
                                //                 (queue?.length ?? 0) -
                                //                 1) %
                                //             (queue?.length ?? 1)
                                //         : player.previousIndex);
                                // carouselController.animateToPage(player
                                //         ?.effectiveIndices!
                                //         .indexOf(userPlayingMode == 2
                                //             ? (player.currentIndex! +
                                //                     (queue?.length ?? 0) -
                                //                     1) %
                                //                 (queue?.length ?? 1)
                                //             : player.previousIndex!) ??
                                //     0);
                                // Future.delayed(Duration(milliseconds: 700), () {
                                //   appState.currentPlayingSongInQueue =
                                //       player?.currentIndex;

                                //   if (!(player?.playerState.playing ?? true)) {
                                //     player?.play();
                                //     appState.isPlaying = true;
                                //   }
                                // });
                              },
                            ),
                            Material(
                              color: Colors.transparent,
                              child: Center(
                                child: StreamBuilder<PlayerState>(
                                  stream: player?.playerStateStream,
                                  builder: (context, snapshot) {
                                    final playerState = snapshot.data;
                                    final processingState =
                                        playerState?.processingState;
                                    final playing = playerState?.playing;
                                    if (processingState ==
                                            ProcessingState.loading ||
                                        processingState ==
                                            ProcessingState.buffering) {
                                      return SizedBox(
                                        // margin: const EdgeInsets.all(10.0),
                                        width: 50.0,
                                        height: 50.0,
                                        child:
                                            const CircularProgressIndicator(),
                                      );
                                    } else if (playing != true) {
                                      return IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                            Icons.play_circle_outline_rounded),
                                        iconSize: 50.0,
                                        color: Color(0xE5FFFFFF),
                                        onPressed: () {
                                          player!.play();
                                          // appState.isPlaying = true;
                                          // player.positionStream.listen((event) {
                                          //   // _sliderProgress = event.inMilliseconds.toDouble();
                                          //   setState(() {
                                          //     _sliderProgress =
                                          //         event.inMilliseconds.toDouble();
                                          //     _playProgress = event.inMilliseconds;
                                          //     print(_playProgress);
                                          //   });
                                          // });
                                          // player.durationStream.listen((event) {
                                          //   setState(() {
                                          //     max_value =
                                          //         event!.inMilliseconds.toDouble();
                                          //   });
                                          // });
                                          setState(() {
                                            _controller.repeat();
                                          });
                                        },
                                      );
                                    } else if (processingState !=
                                        ProcessingState.completed) {
                                      return IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                            Icons.pause_circle_outline_rounded),
                                        iconSize: 50.0,
                                        color: Color(0xE5FFFFFF),
                                        onPressed: () {
                                          player?.pause();
                                          // appState.isPlaying = false;
                                          setState(() {
                                            _controller.stop();
                                          });
                                        },
                                      );
                                    } else {
                                      return IconButton(
                                        icon: const Icon(Icons.replay_rounded),
                                        iconSize: 40.0,
                                        color: Color(0xE5FFFFFF),
                                        onPressed: () =>
                                            player?.seek(Duration.zero),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.skip_next_rounded),
                              color: Color(0xE5FFFFFF),
                              onPressed: () async {
                                int? nextIndex = userPlayingMode == 2
                                    ? (player!.currentIndex! + 1) %
                                        (queue?.length ?? 1)
                                    : player!.nextIndex!;

                                // appState.prevCarouselIndex = index;
                                Song? nextSong = queue![nextIndex];

                                LockCachingAudioSource nextAudioSource =
                                    (player.audioSource!.sequence[nextIndex]
                                        as LockCachingAudioSource);
                                var songUri = nextAudioSource.uri;

                                // Network error. Show toast and retrieve the song again.
                                if (songUri is String &&
                                    (songUri as String) == '2') {
                                  print('Network error, try again later.');
                                  MyToast.showToast(
                                      'Network error, try again later.');
                                  String songLinkString = await appState
                                      .fetchSongLink(nextSong, '128', 1);
                                  MediaItem originTag =
                                      nextAudioSource.tag as MediaItem;
                                  if (songLinkString != '2') {
                                    var newAudioSource = AudioSource.uri(
                                      Uri.parse(songLinkString),
                                      tag: MediaItem(
                                        id: nextIndex.toString(),
                                        album: originTag.album,
                                        artist: originTag.artist,
                                        title: originTag.title,
                                        artUri: originTag.artUri,
                                      ),
                                    );
                                    appState.initQueue!.removeAt(nextIndex);
                                    appState.initQueue!
                                        .insert(nextIndex, newAudioSource);
                                    player.seek(Duration.zero,
                                        index: nextIndex);
                                    Future.delayed(Duration(milliseconds: 700),
                                        () {
                                      appState.currentPlayingSongInQueue =
                                          nextIndex;
                                      if (!(player.playerState.playing)) {
                                        player.play();
                                        appState.isPlaying = true;
                                      }
                                    });
                                    carouselController.animateToPage(player
                                        .effectiveIndices!
                                        .indexOf(nextIndex));
                                    return;
                                  } else {
                                    // Network error still.
                                    int? nextIndex = userPlayingMode == 2
                                        ? (player.currentIndex! + 2) %
                                            queue.length
                                        : (player.nextIndex! + 1) %
                                            queue.length;
                                    player.seek(Duration.zero,
                                        index: nextIndex);
                                    Future.delayed(Duration(milliseconds: 700),
                                        () {
                                      appState.currentPlayingSongInQueue =
                                          nextIndex;
                                      if (!(player.playerState.playing)) {
                                        player.play();
                                        appState.isPlaying = true;
                                      }
                                    });
                                    carouselController.animateToPage(player
                                        .effectiveIndices!
                                        .indexOf(nextIndex));
                                    return;
                                  }
                                }

                                // Next song is taken down.
                                if (nextSong.isTakenDown) {
                                  MyToast.showToast(
                                      'Current song is taken down, skip to next.');
                                  int? nextIndex = userPlayingMode == 2
                                      ? (player.currentIndex! + 2) %
                                          queue.length
                                      : (player.nextIndex! + 1) % queue.length;
                                  player.seek(Duration.zero, index: nextIndex);
                                  Future.delayed(Duration(milliseconds: 700),
                                      () {
                                    appState.currentPlayingSongInQueue =
                                        nextIndex;
                                    if (!(player.playerState.playing)) {
                                      player.play();
                                      appState.isPlaying = true;
                                    }
                                  });
                                  carouselController.animateToPage(player
                                      .effectiveIndices!
                                      .indexOf(nextIndex));
                                  return;
                                }

                                player.seek(Duration.zero, index: nextIndex);

                                Future.delayed(Duration(milliseconds: 700), () {
                                  appState.currentPlayingSongInQueue =
                                      nextIndex;
                                  if (!(player.playerState.playing)) {
                                    player.play();
                                    appState.isPlaying = true;
                                  }
                                });
                                carouselController.animateToPage(player
                                    .effectiveIndices!
                                    .indexOf(nextIndex));

                                // player?.seek(Duration.zero,
                                //     index: userPlayingMode == 2
                                //         ? (player.currentIndex! + 1) %
                                //             (queue?.length ?? 1)
                                //         : player.nextIndex);
                                // carouselController.animateToPage(player
                                //         ?.effectiveIndices!
                                //         .indexOf(userPlayingMode == 2
                                //             ? (player.currentIndex! + 1) %
                                //                 (queue?.length ?? 1)
                                //             : player.nextIndex!) ??
                                //     0);
                                // Future.delayed(Duration(milliseconds: 700), () {
                                //   appState.currentPlayingSongInQueue =
                                //       player?.currentIndex;

                                //   if (!(player?.playerState.playing ?? true)) {
                                //     player?.play();
                                //     appState.isPlaying = true;
                                //   }
                                // });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.queue_music_rounded),
                              color: Color(0xE5FFFFFF),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => ShowQueueDialog(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            }),
      ),
    );
  }

  Stack buildReaderWidget(AudioPlayer? player) {
    return Stack(
      children: [
        LyricsReader(
          padding: EdgeInsets.symmetric(horizontal: _lyricPadding),
          model: _lyricModel,
          position: _playProgress,
          lyricUi: _lyricUI,
          playing: _isPlaying,
          size:
              Size(double.infinity, MediaQuery.of(context).size.height - 280.0),
          onTap: () {
            setState(() {
              _toggleLyrics = !_toggleLyrics;
            });
          },
          emptyBuilder: () => Center(
            child: SelectableText(
              "No lyrics",
              style: _lyricUI.getOtherMainTextStyle(),
            ),
          ),
          selectLineBuilder: (progress, confirm) {
            return GestureDetector(
              onTap: () {
                LyricsLog.logD("Click event");
                confirm.call();
                setState(() {
                  player?.seek(Duration(milliseconds: progress));
                });
              },
              onLongPress: () {
                LyricsLog.logD("Longpress event");
                confirm.call();
                String copied = '';
                int index = _lyricModel!.getCurrentLine(progress);
                LyricsLineModel selectedLine = _lyricModel!.lyrics[index];
                if (selectedLine.hasMain && selectedLine.hasExt) {
                  copied = '${selectedLine.mainText}\n${selectedLine.extText}';
                } else if (selectedLine.hasMain && !selectedLine.hasExt) {
                  copied = selectedLine.mainText!;
                } else if (!selectedLine.hasMain && selectedLine.hasExt) {
                  copied = selectedLine.extText!;
                } else {
                  copied = 'No lyrics found.';
                }
                Clipboard.setData(ClipboardData(text: copied));
              },
              child: Container(
                color: Colors.transparent,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          LyricsLog.logD("Click event");
                          confirm.call();
                          setState(() {
                            player?.seek(Duration(milliseconds: progress));
                          });
                        },
                        icon: Icon(Icons.play_arrow_rounded,
                            color: Colors.white.withOpacity(0.25))),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.25)),
                        height: 1.0,
                        width: double.infinity,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 5.0),
                      child: Text(
                        RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                                .firstMatch(
                                    "${Duration(milliseconds: _playProgress)}")
                                ?.group(1) ??
                            '${Duration(milliseconds: _playProgress)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.25),
                          fontSize: 12.0,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
