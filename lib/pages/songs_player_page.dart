import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';
import 'package:just_audio/just_audio.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../http/my_http.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_song.dart';
import '../entities/netease_cloud_music/ncm_detail_song.dart';
import '../entities/qq_music/qqmusic_detail_song.dart';
import '../http/api.dart';
import '../mock_data.dart';
import '../states/app_state.dart';
import '../third_lib_change/just_audio/common.dart';
import '../third_lib_change/like_button/like_button.dart';
import '../utils/my_logger.dart';
import '../utils/my_toast.dart';
import '../utils/theme_manager.dart';
import '../widgets/my_lyrics_displayer.dart';
import '../widgets/my_selectable_text.dart';
import '../widgets/queue_popup.dart';
import '../widgets/songplayer_menu_popup.dart';

class SongsPlayerPage extends StatefulWidget {
  const SongsPlayerPage({super.key});
  @override
  State<SongsPlayerPage> createState() => _SongsPlayerPageState();
}

// TODO: The widget tree will always be rebuild when open lyrics page.
class _SongsPlayerPageState extends State<SongsPlayerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _songCoverRotateAnimation;
  bool? _isUsingMockData;
  int? _currentPlatform;
  bool _isFirstLoadSongsPlayer = false;
  bool _toggleLyrics = false;
  bool _isPlaying = false;
  int _prevSongIndex = 0;
  bool _noPoping = true;
  // True for return original page as all songs are taken down.
  bool _return = false;
  // bool _pressPlayButton = false;

  var _lyricPadding = 40.0;
  LyricsReaderModel? _lyricModel;

  int _playProgress = 0;

  Future<BasicSong?>? _detailSong;
  BasicSong? _simpleDetailSong;
  bool _hasLyrics = true;
  var _lyricUI = MyLyricsDisplayer(
    defaultSize: 20.0,
    defaultExtSize: 14.0,
    otherMainSize: 18.0,
    inlineGap: 0.0,
    highlight: true,
  );
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    );
    _songCoverRotateAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('build songs player page');
    MyAppState appState = context.watch<MyAppState>();
    _isUsingMockData = appState.isUsingMockData;
    _currentPlatform = appState.currentPlatform;
    var songsPlayer = appState.songsPlayer;
    var songsQueue = appState.songsQueue;
    var currentPlayingSongInQueue = appState.currentPlayingSongInQueue;
    var currentSong = appState.currentSong;
    var prevSong = appState.prevSong;
    var currentDetailSong = appState.currentDetailSong;
    var userPlayingMode = appState.userPlayingMode;
    var volume = appState.volume;
    var speed = appState.speed;
    var songsPlayerPositionDataStream = appState.songsPlayerPositionDataStream;
    var carouselController = appState.carouselController;
    var prevCarouselIndex = appState.prevCarouselIndex;
    String? mainLyrics;
    _isFirstLoadSongsPlayer = appState.isFirstLoadSongsPlayer;
    _isPlaying = appState.isSongPlaying;

    if (_simpleDetailSong != currentDetailSong) {
      _simpleDetailSong = currentDetailSong;
      _detailSong = Future.value(currentDetailSong);
    }

    if (_isFirstLoadSongsPlayer) {
      songsPlayer!.seek(Duration.zero, index: currentPlayingSongInQueue);
      _controller.repeat();
    }

    if ((songsQueue?.isNotEmpty ?? false) &&
        (songsQueue!.length > currentPlayingSongInQueue!) &&
        (currentSong!.name != songsQueue[currentPlayingSongInQueue].name)) {
      _controller.reset();
    }

    if (songsQueue?.isEmpty ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (appState.canSongsPlayerPagePop) {
          appState.isSongsPlayerPageOpened = false;
          appState.canSongsPlayerPagePop = false;
          Navigator.of(context).pop();
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (appState.isSongsPlayerPageOpened == false && _noPoping) {
        appState.isSongsPlayerPageOpened = true;
      }
      if (_return) {
        appState.disposeSongsPlayer();
        Navigator.of(context).pop();
      }
      if ((songsQueue?.isNotEmpty ?? false) &&
          (currentSong != songsQueue?[currentPlayingSongInQueue!])) {
        appState.currentSong = songsQueue?[currentPlayingSongInQueue!];
      }

      if (!_isFirstLoadSongsPlayer) {
        if (songsPlayer != null && songsPlayer.playing == true) {
          _controller.repeat();
        } else {
          _controller.stop();
        }
      } else {
        Future.delayed(Duration(milliseconds: 200), () {
          appState.isFirstLoadSongsPlayer = false;
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
      if (currentSong != null &&
          (_detailSong == null || prevSong != currentSong)) {
        _detailSong = _isUsingMockData!
            ? Future.value(MockData.detailSong)
            : appState.fetchDetailSong<BasicSong>(
                currentSong, _currentPlatform!);
      }
    } on SocketException catch (e) {
      MyToast.showToast('Exception thrown: $e');
      MyLogger.logger.e(e);
      rethrow;
    }
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return WillPopScope(
      onWillPop: () async {
        appState.isSongsPlayerPageOpened = false;
        _noPoping = false;
        appState.refreshLibraries!(appState, false);
        return true; // Allow the navigation to proceed
      },
      child: Consumer<ThemeNotifier>(
        builder: (context, theme, _) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: theme.playerPageBackground!,
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
                } else if (snapshot.hasError || snapshot.data == null) {
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
                              Colors.white54,
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
                              _detailSong = appState.fetchDetailSong<BasicSong>(
                                  currentSong!, _currentPlatform!);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  dynamic detailSong;
                  if (_isUsingMockData!) {
                    detailSong = snapshot.data as QQMusicDetailSong;
                  } else {
                    if (_currentPlatform == 0) {
                      throw UnimplementedError(
                          'Not yet implement pms platform');
                    } else if (_currentPlatform == 1) {
                      detailSong = snapshot.data as QQMusicDetailSong;
                    } else if (_currentPlatform == 2) {
                      detailSong = snapshot.data as NCMDetailSong;
                    } else if (_currentPlatform == 3) {
                      throw UnimplementedError(
                          'Not yet implement bilibili platform');
                    } else {
                      throw UnsupportedError('Invalid platform');
                    }
                  }

                  mainLyrics = detailSong.lyrics.lyric;
                  // mainLyrics = detailSong.lyrics.yrc;
                  if (_lyricModel == null || prevSong != currentSong) {
                    if (!_isUsingMockData!) {
                      if (_currentPlatform == 0) {
                        throw UnimplementedError(
                            'Not yet implement pms platform');
                      }
                      if (_currentPlatform == 1) {
                        if (mainLyrics == '[00:00:00]此歌曲为没有填词的纯音乐，请您欣赏') {
                          _hasLyrics = false;
                        } else {
                          _hasLyrics = true;
                          _lyricModel = LyricsModelBuilder.create()
                              .bindLyricToMain(detailSong.lyrics.lyric)
                              .bindLyricToExt(detailSong.lyrics.trans)
                              .getModel();
                        }
                      } else if (_currentPlatform == 2) {
                        if (mainLyrics == '[00:00:00]此歌曲为没有填词的纯音乐，请您欣赏') {
                          _hasLyrics = false;
                        } else {
                          _hasLyrics = true;
                          _lyricModel = LyricsModelBuilder.create()
                              .bindLyricToMain(detailSong.lyrics.lyric)
                              .bindLyricToExt(detailSong.lyrics.tLyric)
                              .getModel();
                        }
                      } else if (_currentPlatform == 3) {
                        throw UnimplementedError(
                            'Not yet implement bilibili platform');
                      } else {
                        throw UnsupportedError('Invalid platform');
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
                                  appState.isSongsPlayerPageOpened = false;
                                  _noPoping = false;
                                  appState.refreshLibraries!(appState, false);
                                  Navigator.pop(context);
                                },
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: MySelectableText(
                                        currentSong?.name ?? '',
                                        style: textTheme.labelMedium!.copyWith(
                                          color: Colors.white,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    MySelectableText(
                                      currentSong == null
                                          ? ''
                                          : currentSong.singers
                                              .map((e) => e.name)
                                              .join(', '),
                                      style: textTheme.labelSmall!.copyWith(
                                        color: Colors.white,
                                        fontSize: 12.0,
                                        overflow: TextOverflow.ellipsis,
                                      ),
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
                                      'song: ${songsPlayer!.position.inMilliseconds}');
                                  print(
                                      'diff: ${_playProgress - songsPlayer.position.inMilliseconds}');
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
                                      child: songsPlayer != null && _hasLyrics
                                          ? buildReaderWidget(songsPlayer)
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
                                                          mainLyrics!.indexOf(
                                                                  ']') +
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
                                top: (MediaQuery.of(context).size.height -
                                        500.0) /
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
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: CarouselSlider.builder(
                                          carouselController:
                                              carouselController,
                                          options: CarouselOptions(
                                            initialPage: songsPlayer
                                                    ?.effectiveIndices!
                                                    .indexOf(
                                                        currentPlayingSongInQueue!) ??
                                                0,
                                            aspectRatio: 1.0,
                                            viewportFraction:
                                                userPlayingMode == 0
                                                    ? 0.8
                                                    : 0.6,
                                            enlargeCenterPage: true,
                                            onPageChanged:
                                                (index, reason) async {
                                              if (reason ==
                                                  CarouselPageChangedReason
                                                      .manual) {
                                                int nextIndex = songsPlayer!
                                                    .effectiveIndices![index];

                                                appState.prevCarouselIndex =
                                                    index;

                                                songsPlayer.seek(Duration.zero,
                                                    index: nextIndex);

                                                Future.delayed(
                                                    Duration(milliseconds: 700),
                                                    () {
                                                  appState.currentPlayingSongInQueue =
                                                      nextIndex;
                                                  if (!(songsPlayer
                                                      .playerState.playing)) {
                                                    songsPlayer.play();
                                                    appState.isSongPlaying =
                                                        true;
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
                                              int itemIndex,
                                              int pageViewIndex) {
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
                                                child: (songsPlayer != null &&
                                                        (songsPlayer
                                                                .effectiveIndices
                                                                ?.isNotEmpty ??
                                                            false) &&
                                                        songsPlayer.effectiveIndices![
                                                                itemIndex] ==
                                                            currentPlayingSongInQueue)
                                                    ? AnimatedBuilder(
                                                        animation:
                                                            _songCoverRotateAnimation,
                                                        builder: (BuildContext
                                                                context,
                                                            Widget? child) {
                                                          return Transform
                                                              .rotate(
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
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                _toggleLyrics =
                                                                    true;
                                                              });
                                                              print(
                                                                  _toggleLyrics);
                                                            },
                                                            child: _isUsingMockData!
                                                                ? Image.asset(
                                                                    // (_userPlayingMode ==0)?
                                                                    // songsOfPlaylist[itemIndex].cover
                                                                    (songsQueue?.isNotEmpty ??
                                                                            false)
                                                                        ? (songsQueue![songsPlayer.effectiveIndices![itemIndex]]
                                                                            .cover)
                                                                        : 'assets/images/default.jpg',
                                                                    fit: BoxFit
                                                                        .fitHeight,
                                                                    height:
                                                                        230.0,
                                                                    width:
                                                                        230.0,
                                                                  )
                                                                : CachedNetworkImage(
                                                                    imageUrl: ((songsQueue?.isNotEmpty ??
                                                                                false) &&
                                                                            songsQueue![songsPlayer.effectiveIndices![itemIndex]]
                                                                                .cover
                                                                                .isNotEmpty)
                                                                        ? kIsWeb
                                                                            ? API.convertImageUrl(songsQueue[songsPlayer.effectiveIndices![itemIndex]]
                                                                                .cover)
                                                                            : songsQueue[songsPlayer.effectiveIndices![itemIndex]]
                                                                                .cover
                                                                        : MyAppState
                                                                            .defaultCoverImage,
                                                                    cacheManager:
                                                                        MyHttp
                                                                            .myImageCacheManager,
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
                                                            //     image: CachedNetworkImageProvider(((songsQueue?.isNotEmpty ??
                                                            //                 false) &&
                                                            //             songsQueue![songsPlayer.effectiveIndices![itemIndex]]
                                                            //                 .cover
                                                            //                 .isNotEmpty)
                                                            //         ? (songsQueue[songsPlayer.effectiveIndices![
                                                            //                 itemIndex]]
                                                            //             .cover)
                                                            //         : MyAppState
                                                            //             .defaultCoverImage),
                                                            //   ),
                                                            // : Image.network(
                                                            //     ((songsQueue?.isNotEmpty ??
                                                            //                 false) &&
                                                            //             songsQueue![songsPlayer.effectiveIndices![itemIndex]]
                                                            //                 .cover
                                                            //                 .isNotEmpty)
                                                            //         ? (songsQueue[songsPlayer.effectiveIndices![
                                                            //                 itemIndex]]
                                                            //             .cover)
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
                                                        child: _isUsingMockData!
                                                            ? Image.asset(
                                                                // (_userPlayingMode ==0)?
                                                                // songsOfPlaylist[itemIndex].cover
                                                                (songsPlayer !=
                                                                            null &&
                                                                        (songsQueue?.isNotEmpty ??
                                                                            false))
                                                                    ? songsQueue![
                                                                            songsPlayer.effectiveIndices![itemIndex]]
                                                                        .cover
                                                                    : 'assets/images/default.jpg',
                                                                fit: BoxFit
                                                                    .fitHeight,
                                                                height: 230.0,
                                                                width: 230.0,
                                                              )
                                                            : CachedNetworkImage(
                                                                imageUrl: ((songsPlayer !=
                                                                                null &&
                                                                            (songsQueue?.isNotEmpty ??
                                                                                false)) &&
                                                                        songsQueue![songsPlayer.effectiveIndices![itemIndex]]
                                                                            .cover
                                                                            .isNotEmpty)
                                                                    ? kIsWeb
                                                                        ? API.convertImageUrl(songsQueue[songsPlayer.effectiveIndices![itemIndex]]
                                                                            .cover)
                                                                        : songsQueue[songsPlayer.effectiveIndices![itemIndex]]
                                                                            .cover
                                                                    : MyAppState
                                                                        .defaultCoverImage,
                                                                cacheManager: MyHttp
                                                                    .myImageCacheManager,
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
                                                        //     image: CachedNetworkImageProvider(((songsPlayer !=
                                                        //                     null &&
                                                        //                 (songsQueue?.isNotEmpty ??
                                                        //                     false)) &&
                                                        //             songsQueue![songsPlayer.effectiveIndices![
                                                        //                     itemIndex]]
                                                        //                 .cover
                                                        //                 .isNotEmpty)
                                                        //         ? songsQueue[songsPlayer
                                                        //                     .effectiveIndices![
                                                        //                 itemIndex]]
                                                        //             .cover
                                                        //         : MyAppState
                                                        //             .defaultCoverImage),
                                                        //   ),
                                                        // : Image.network(
                                                        //     ((songsPlayer != null &&
                                                        //                 (songsQueue?.isNotEmpty ??
                                                        //                     false)) &&
                                                        //             songsQueue![songsPlayer.effectiveIndices![
                                                        //                     itemIndex]]
                                                        //                 .cover
                                                        //                 .isNotEmpty)
                                                        //         ? songsQueue[songsPlayer
                                                        //                     .effectiveIndices![
                                                        //                 itemIndex]]
                                                        //             .cover
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
                                          itemCount: songsQueue?.length,
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
                                              icon:
                                                  Icon(Icons.volume_up_rounded),
                                              onPressed: () {
                                                //TODO: fix bug: volume more than 1 not works.
                                                showSliderDialog(
                                                  context: context,
                                                  title: 'Adjust volume',
                                                  divisions: 10,
                                                  min: 0.0,
                                                  max: 1.0,
                                                  value: volume!,
                                                  stream:
                                                      songsPlayer!.volumeStream,
                                                  onChanged: (volume) {
                                                    songsPlayer
                                                        .setVolume(volume);
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
                                                  stream:
                                                      songsPlayer!.speedStream,
                                                  onChanged: (speed) {
                                                    songsPlayer.setSpeed(speed);
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
                                              icon:
                                                  Icon(Icons.download_rounded),
                                              onPressed: () {
                                                print(appState);
                                                print(songsQueue);
                                                print(carouselController);
                                                print(songsPlayer);
                                                setState(() {});
                                              },
                                            ),
                                            IconButton(
                                              color: Color(0xE5FFFFFF),
                                              icon:
                                                  Icon(Icons.more_vert_rounded),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
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
                                        stream: songsPlayerPositionDataStream,
                                        builder: (context, snapshot) {
                                          final positionData = snapshot.data;
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            if (_toggleLyrics) {
                                              setState(() {
                                                // _playProgress = songsPlayer.positionStream.
                                                _playProgress = positionData
                                                        ?.position
                                                        .inMilliseconds ??
                                                    0;
                                              });
                                            }
                                          });
                                          return SeekBar(
                                            duration: positionData?.duration ??
                                                Duration.zero,
                                            position: positionData?.position ??
                                                Duration.zero,
                                            bufferedPosition: positionData
                                                    ?.bufferedPosition ??
                                                Duration.zero,
                                            onChangeEnd: songsPlayer?.seek,
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
                        padding:
                            const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 22.0),
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
                                          songsPlayer!
                                              .setShuffleModeEnabled(false);
                                          songsPlayer.setLoopMode(LoopMode.all);
                                          carouselController.jumpToPage(
                                              songsPlayer.effectiveIndices!
                                                  .indexOf(songsPlayer
                                                      .currentIndex!));
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
                                          songsPlayer!
                                              .setShuffleModeEnabled(false);
                                          songsPlayer.setLoopMode(LoopMode.one);
                                        },
                                      );
                                    } else if (userPlayingMode == 2) {
                                      return IconButton(
                                        icon: const Icon(
                                            Icons.repeat_one_rounded),
                                        color: Color(0xE5FFFFFF),
                                        onPressed: () {
                                          setState(() {
                                            appState.userPlayingMode = 0;
                                          });
                                          songsPlayer!
                                              .setShuffleModeEnabled(true);
                                          songsPlayer.shuffle();
                                          songsPlayer.setLoopMode(LoopMode.all);
                                          carouselController.jumpToPage(
                                              songsPlayer.effectiveIndices!
                                                  .indexOf(songsPlayer
                                                      .currentIndex!));
                                        },
                                      );
                                    } else {
                                      throw UnsupportedError(
                                          'Invalid playing mode: $userPlayingMode');
                                    }
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.skip_previous_rounded),
                                color: Color(0xE5FFFFFF),
                                onPressed: () async {
                                  int? nextIndex = userPlayingMode == 2
                                      ? (songsPlayer!.currentIndex! - 1) %
                                          (songsQueue?.length ?? 1)
                                      : songsPlayer!.previousIndex!;

                                  songsPlayer.seek(Duration.zero,
                                      index: nextIndex);

                                  Future.delayed(Duration(milliseconds: 700),
                                      () {
                                    appState.currentPlayingSongInQueue =
                                        nextIndex;
                                    if (!(songsPlayer.playerState.playing)) {
                                      songsPlayer.play();
                                      appState.isSongPlaying = true;
                                    }
                                  });
                                  carouselController.animateToPage(songsPlayer
                                      .effectiveIndices!
                                      .indexOf(nextIndex));
                                },
                              ),
                              Material(
                                color: Colors.transparent,
                                child: Center(
                                  child: StreamBuilder<PlayerState>(
                                    stream: songsPlayer?.playerStateStream,
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
                                          icon: const Icon(Icons
                                              .play_circle_outline_rounded),
                                          iconSize: 50.0,
                                          color: Color(0xE5FFFFFF),
                                          onPressed: () {
                                            songsPlayer!.play();
                                          },
                                        );
                                      } else if (processingState !=
                                          ProcessingState.completed) {
                                        return IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(Icons
                                              .pause_circle_outline_rounded),
                                          iconSize: 50.0,
                                          color: Color(0xE5FFFFFF),
                                          onPressed: () {
                                            songsPlayer?.pause();
                                            appState.isSongPlaying = false;
                                          },
                                        );
                                      } else {
                                        return IconButton(
                                          icon:
                                              const Icon(Icons.replay_rounded),
                                          iconSize: 40.0,
                                          color: Color(0xE5FFFFFF),
                                          onPressed: () =>
                                              songsPlayer?.seek(Duration.zero),
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
                                      ? (songsPlayer!.currentIndex! + 1) %
                                          (songsQueue?.length ?? 1)
                                      : songsPlayer!.nextIndex!;

                                  songsPlayer.seek(Duration.zero,
                                      index: nextIndex);

                                  Future.delayed(Duration(milliseconds: 700),
                                      () {
                                    appState.currentPlayingSongInQueue =
                                        nextIndex;
                                    if (!(songsPlayer.playerState.playing)) {
                                      songsPlayer.play();
                                      appState.isSongPlaying = true;
                                    }
                                  });
                                  carouselController.animateToPage(songsPlayer
                                      .effectiveIndices!
                                      .indexOf(nextIndex));
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
      ),
    );
  }

  Stack buildReaderWidget(AudioPlayer? songsPlayer) {
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
            child: MySelectableText(
              'No lyrics',
              style: _lyricUI.getOtherMainTextStyle(),
            ),
          ),
          selectLineBuilder: (progress, confirm) {
            return GestureDetector(
              onTap: () {
                LyricsLog.logD('Click event');
                confirm.call();
                setState(() {
                  songsPlayer?.seek(Duration(milliseconds: progress));
                });
              },
              onLongPress: () {
                LyricsLog.logD('Longpress event');
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
                          LyricsLog.logD('Click event');
                          confirm.call();
                          setState(() {
                            songsPlayer?.seek(Duration(milliseconds: progress));
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
