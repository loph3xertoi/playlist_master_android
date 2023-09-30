import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fplayer/fplayer.dart';
import 'package:humanize_big_int/humanize_big_int.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../entities/basic/basic_video.dart';
import '../entities/netease_cloud_music/ncm_detail_video.dart';
import '../entities/netease_cloud_music/ncm_video.dart';
import '../entities/qq_music/qqmusic_detail_video.dart';
import '../entities/qq_music/qqmusic_video.dart';
import '../http/api.dart';
import '../http/my_http.dart';
import '../states/app_state.dart';
import '../utils/my_logger.dart';
import '../widgets/my_selectable_text.dart';
import '../widgets/show_video_player_sidebar.dart';

/// FPlayer for video player, but the resolution list and playing button state and the
/// fullscreen switching still have some bugs.
class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key, required this.video});

  final BasicVideo video;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  final FPlayer _songsPlayer = FPlayer();
  late Future<BasicVideo?> _detailVideo;
  late int _platform;
  String? _resolutionKey;
  // Speed list.
  Map<String, double> _speedList = {
    '2.0': 2.0,
    '1.5': 1.5,
    '1.0': 1.0,
    '0.5': 0.5,
  };

  // Resolution list.
  late Future<Map<String, ResolutionItem>> _resolutionList;

  @override
  void deactivate() {
    final state = Provider.of<MyAppState>(context, listen: false);
    state.videoSeekTime = _songsPlayer.currentPos.inMilliseconds;
    super.deactivate();
  }

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    var isUsingMockData = state.isUsingMockData;
    var currentPlatform = state.currentPlatform;
    if (currentPlatform == 0) {
      // Change platform id for pms.
      if (widget.video is QQMusicVideo) {
        currentPlatform = 1;
      } else if (widget.video is NCMVideo) {
        currentPlatform = 2;
      } else {
        throw 'Invalid video type';
      }
    }
    _platform = currentPlatform;
    if (isUsingMockData) {
      throw UnimplementedError('No mock data for video');
    } else {
      _detailVideo = state.fetchDetailMV(widget.video, currentPlatform);
    }
    _resolutionList = _getResolutionList(_detailVideo, currentPlatform);
    _startPlay();
  }

  @override
  void dispose() async {
    super.dispose();
    try {
      await ScreenBrightness().resetScreenBrightness();
    } catch (e) {
      print(e);
      throw 'Failed to reset brightness';
    }
    // _songsPlayer.removeListener(_preparedListener);
    _songsPlayer.release();
  }

  void _startPlay() async {
    var resolutionList = await _resolutionList;
    await _songsPlayer.setOption(FOption.hostCategory, 'request-screen-on', 1);
    await _songsPlayer.setOption(
        FOption.hostCategory, 'request-audio-focus', 1);
    await _songsPlayer.setOption(FOption.playerCategory, 'reconnect', 20);
    await _songsPlayer.setOption(FOption.playerCategory, 'framedrop', 20);
    await _songsPlayer.setOption(
        FOption.playerCategory, 'enable-accurate-seek', 1);
    await _songsPlayer.setOption(FOption.playerCategory, 'mediacodec', 1);
    await _songsPlayer.setOption(FOption.playerCategory, 'packet-buffering', 0);
    await _songsPlayer.setOption(FOption.playerCategory, 'soundtouch', 1);

    await _songsPlayer.setLoop(0);

    // _songsPlayer.addListener(_preparedListener);

    // Play video of 360p by default.
    _setVideoUrl(resolutionList.values.toList().first.url);
  }

  // Cache the video with the url.
  Future<String> _getVideoUrlIfCached(String rawUrl) async {
    CacheManager cacheManager = MyHttp.videoCacheManager;
    dynamic result = await cacheManager.getFileFromMemory(rawUrl);
    if (result == null || !(result as FileInfo).file.existsSync()) {
      result = await cacheManager.getFileFromCache(rawUrl);
      if (result == null || !(result as FileInfo).file.existsSync()) {
        MyLogger.logger.d('This video is not in cache.');
        result = rawUrl;
      } else {
        MyLogger.logger.d('Loading video from cache...');
      }
    } else {
      // The key is in memory and the value is in cache(sqlite).
      MyLogger.logger.d('Loading video from memory...');
    }
    if (result is FileInfo) {
      String filePath = result.file.uri.toString();
      result = Future.value(filePath);
    }
    return result;
  }

  // void _preparedListener() {
  //   FValue value = _songsPlayer.value;
  //   print('Resolution: ${value.size}');
  //   if (value.prepared) {
  //     print('prepared');
  //   }
  // }

  // Determine the resolution URLs based on the length of videoLinks
  Future<Map<String, ResolutionItem>> _getResolutionList(
      Future<BasicVideo?> video, int platform) async {
    Map<String, ResolutionItem> resolutionList = {};
    if (platform == 1) {
      List<String> videoLinks;
      QQMusicDetailVideo qqMusicDetailVideo =
          (await video) as QQMusicDetailVideo;
      videoLinks = qqMusicDetailVideo.links;
      if (videoLinks.isNotEmpty) {
        String finalUrl = await _getVideoUrlIfCached(videoLinks[0]);
        resolutionList['360p'] = ResolutionItem(value: 360, url: finalUrl);
      }
      if (videoLinks.length >= 2) {
        String finalUrl = await _getVideoUrlIfCached(videoLinks[1]);
        resolutionList['480p'] = ResolutionItem(value: 480, url: finalUrl);
      }
      if (videoLinks.length >= 3) {
        String finalUrl = await _getVideoUrlIfCached(videoLinks[2]);
        resolutionList['720p'] = ResolutionItem(value: 720, url: finalUrl);
      }
      if (videoLinks.length >= 4) {
        String finalUrl = await _getVideoUrlIfCached(videoLinks[3]);
        resolutionList['1080p'] = ResolutionItem(value: 1080, url: finalUrl);
      }
      if (videoLinks.length >= 5) {
        for (int i = 4; i < videoLinks.length; i++) {
          String finalUrl = await _getVideoUrlIfCached(videoLinks[i]);
          String resolutionName = '1080p${i - 3}';
          resolutionList[resolutionName] =
              ResolutionItem(value: 1080, url: finalUrl);
        }
      }
    } else if (platform == 2) {
      NCMDetailVideo ncmDetailVideo = (await video) as NCMDetailVideo;
      Map<String, String> videoLinks = ncmDetailVideo.links;

      await Future.forEach(videoLinks.entries,
          (MapEntry<String, String> entry) async {
        String newUrl = await _getVideoUrlIfCached(entry.value);
        ResolutionItem newValue =
            ResolutionItem(value: int.parse(entry.key), url: newUrl);
        resolutionList['${entry.key}p'] = newValue;
      });
    } else if (platform == 3) {
      throw UnimplementedError(
        'Not yet implement bilibili platform',
      );
    } else {
      throw UnsupportedError('Invalid platform');
    }
    return resolutionList;
  }

  Future<void> _setVideoUrl(String url) async {
    try {
      await _songsPlayer.setDataSource(url, autoPlay: true, showCover: true);
    } catch (error) {
      throw Exception('Exception: $error');
    }
  }

  void _updateResolutionList() async {
    _resolutionList = _getResolutionList(_detailVideo, _platform);
    Map<String, ResolutionItem> resolutionList = await _resolutionList;
    await _songsPlayer.reset();
    await _setVideoUrl(resolutionList[_resolutionKey]!.url);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    Size size = mediaQueryData.size;
    // double videoHeight = size.width * 7 / 16;
    return FutureBuilder(
      future: Future.wait([_detailVideo, _resolutionList]),
      // future: Future.wait(
      //     [_detailVideo, _getResolutionList(_detailVideo, currentPlatform)]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          MyLogger.logger
              .e(snapshot.hasError ? '${snapshot.error}' : appState.errorMsg);
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
                      style: textTheme.labelMedium!.copyWith(
                        color: colorScheme.onSecondary,
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
                        color: colorScheme.onSecondary,
                      ),
                      label: Text(
                        'Retry',
                        style: textTheme.labelMedium!.copyWith(
                          color: colorScheme.onSecondary,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _detailVideo =
                              appState.fetchDetailMV(widget.video, _platform);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          dynamic detailVideo;
          if (_platform == 0) {
            throw UnimplementedError('Not yet implement pms platform');
          } else if (_platform == 1) {
            detailVideo = snapshot.data![0] as QQMusicDetailVideo;
          } else if (_platform == 2) {
            detailVideo = snapshot.data![0] as NCMDetailVideo;
          } else if (_platform == 3) {
            throw UnimplementedError('Not yet implement bilibili platform');
          } else {
            throw UnsupportedError('Invalid platform');
          }
          Map<String, ResolutionItem> resolutionList =
              snapshot.data![1] as Map<String, ResolutionItem>;
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.video.name, style: textTheme.labelSmall),
              backgroundColor: colorScheme.primary,
              iconTheme: IconThemeData(color: colorScheme.onSecondary),
            ),
            body: Material(
              color: Colors.black,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 50.0),
                      child: FView(
                        player: _songsPlayer,
                        // width: double.infinity,
                        // height: videoHeight,
                        color: Colors.black,
                        fsFit: FFit.contain,
                        fit: FFit.fitWidth,
                        panelBuilder: fPanelBuilder(
                          title: detailVideo.name,
                          speedList: _speedList,
                          isResolution: true,
                          resolutionList: resolutionList,
                          settingFun: () async {
                            print(_songsPlayer);
                            print(_songsPlayer.value.size!.height);
                            // String key =
                            //     '${_songsPlayer.value.size!.height.toInt()}p';
                            // String videoLink = resolutionList[key]!.url;

                            String videoLink = _songsPlayer.dataSource!;
                            _resolutionKey = resolutionList.keys.firstWhere(
                                (key) => resolutionList[key]!.url == videoLink,
                                orElse: () => '');
                            showDialog(
                              context: context,
                              builder: (_) => ShowVideoPlayerSidebar(
                                videoLink: videoLink,
                                updateResolutionList: _updateResolutionList,
                              ),
                            );
                          },
                          onError: () async {
                            await _songsPlayer.reset();
                            String originalUrl;
                            if (_platform == 1) {
                              originalUrl = detailVideo.links[0];
                            } else if (_platform == 2) {
                              originalUrl = detailVideo.links.values[0];
                            } else {
                              throw UnimplementedError(
                                  'Not yet implement other platform');
                            }
                            _setVideoUrl(originalUrl);
                          },
                          onVideoEnd: () async {
                            // await _songsPlayer.reset();
                            // _setVideoUrl(detailVideo.videoLinks[0]);
                          },
                          onVideoTimeChange: () {
                            // 视频时间变动则触发一次，可以保存视频播放历史
                            appState.videoSeekTime =
                                _songsPlayer.currentPos.inMilliseconds;
                          },
                          onVideoPrepared: () async {
                            // 视频初始化完毕，如有历史记录时间段则可以触发快进
                            int seekTime = appState.videoSeekTime;
                            dynamic videoId;
                            if (_platform == 1) {
                              videoId = detailVideo.vid;
                            } else if (_platform == 2) {
                              videoId = detailVideo.id;
                            } else {
                              throw UnimplementedError(
                                  'Not yet implement other platform');
                            }
                            try {
                              if (seekTime >= 1 &&
                                  videoId == appState.lastVideoVid) {
                                /// seekTo必须在FState.prepared
                                print('seekTo');
                                await _songsPlayer.seekTo(seekTime);
                                // MyToast.showToast('Seek to $formattedTime');
                                appState.videoSeekTime = 0;
                              } else {
                                appState.lastVideoVid = videoId;
                              }
                            } catch (error) {
                              print('Exception: $error');
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  _platform == 1
                      ? QQMusicVideoInfoArea(
                          size: size,
                          detailVideo: detailVideo,
                          textTheme: textTheme)
                      : NCMVideoInfoArea(
                          size: size,
                          detailVideo: detailVideo,
                          textTheme: textTheme),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class QQMusicVideoInfoArea extends StatelessWidget {
  const QQMusicVideoInfoArea({
    super.key,
    required this.size,
    required this.detailVideo,
    required this.textTheme,
  });

  final Size size;
  final QQMusicDetailVideo detailVideo;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.width * 0.6,
      width: size.width,
      child: Column(children: [
        Row(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 30.0,
              width: 30.0,
              child: CircleAvatar(
                radius: 15.0,
                backgroundImage: CachedNetworkImageProvider(
                  detailVideo.singers.isNotEmpty
                      ? kIsWeb
                          ? API.convertImageUrl(detailVideo.singers[0].headPic!)
                          : detailVideo.singers[0].headPic!
                      : MyAppState.defaultCoverImage,
                  headers: {
                    'Cookie': MyAppState.cookie!,
                    'User-Agent':
                        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36',
                  },
                  cacheManager: MyHttp.myImageCacheManager,
                ),
              ),
            ),
          ),
          Text(
            detailVideo.singers.map((e) => e.name).join('/'),
            style: textTheme.labelMedium!.copyWith(color: Colors.white),
          ),
        ]),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SizedBox(
            width: size.width,
            child: Text(
              detailVideo.name,
              style: textTheme.labelSmall!
                  .copyWith(color: Colors.white.withOpacity(0.8)),
            ),
          ),
        ),
        detailVideo.desc.isNotEmpty
            ? Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    detailVideo.desc,
                    style: textTheme.labelSmall!.copyWith(
                        fontSize: 10.0, color: Colors.white.withOpacity(0.8)),
                  ),
                ),
              )
            : Container(),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 20.0),
                child: Text(
                  '${humanizeInt(detailVideo.playCount)} views',
                  style: textTheme.labelSmall!
                      .copyWith(color: Colors.white.withOpacity(0.4)),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 20.0),
                child: Text(
                  DateFormat('yyyy-MM-dd').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          detailVideo.pubDate * 1000)),
                  style: textTheme.labelSmall!
                      .copyWith(color: Colors.white.withOpacity(0.4)),
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}

class NCMVideoInfoArea extends StatelessWidget {
  const NCMVideoInfoArea({
    super.key,
    required this.size,
    required this.detailVideo,
    required this.textTheme,
  });

  final Size size;
  final NCMDetailVideo detailVideo;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    RegExp regex = RegExp(r'[a-zA-Z]');
    bool isMV = !regex.hasMatch(detailVideo.id);
    return SizedBox(
      height: size.width * 0.6,
      width: size.width,
      child: Column(children: [
        Row(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 30.0,
              width: 30.0,
              child: CircleAvatar(
                radius: 15.0,
                backgroundImage: CachedNetworkImageProvider(
                  detailVideo.singers.isNotEmpty
                      ? kIsWeb
                          ? API.convertImageUrl(detailVideo.singers[0].headPic!)
                          : detailVideo.singers[0].headPic!
                      : MyAppState.defaultCoverImage,
                  headers: {
                    'Cookie': MyAppState.cookie!,
                    'User-Agent':
                        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36',
                  },
                  cacheManager: MyHttp.myImageCacheManager,
                ),
              ),
            ),
          ),
          Text(
            detailVideo.singers.map((e) => e.name).join('/'),
            style: textTheme.labelMedium!.copyWith(color: Colors.white),
          ),
        ]),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            isMV
                ? Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: SizedBox(
                      width: 20.0,
                      child: Image.asset('assets/images/ncm_mv.png'),
                    ),
                  )
                : Container(),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                detailVideo.name,
                style: textTheme.labelSmall!
                    .copyWith(color: Colors.white.withOpacity(0.8)),
              ),
            ),
          ],
        ),
        detailVideo.desc.isNotEmpty
            ? Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    detailVideo.desc,
                    style: textTheme.labelSmall!.copyWith(
                        fontSize: 10.0, color: Colors.white.withOpacity(0.8)),
                  ),
                ),
              )
            : Container(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 20.0),
                    child: Text(
                      '${humanizeInt(detailVideo.playCount)} views',
                      style: textTheme.labelSmall!
                          .copyWith(color: Colors.white.withOpacity(0.4)),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 20.0),
                    child: Text(
                      isMV
                          ? detailVideo.publishTime
                          : DateFormat('yyyy-MM-dd').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(detailVideo.publishTime))),
                      style: textTheme.labelSmall!
                          .copyWith(color: Colors.white.withOpacity(0.4)),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Icon(
                      Icons.insert_comment_sharp,
                      color: Colors.white,
                    ),
                    Text(
                      '${detailVideo.commentCount}',
                      style: textTheme.labelSmall!.copyWith(
                        color: Colors.white,
                        fontSize: 10.0,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      Icons.thumb_up_rounded,
                      color: Colors.white,
                    ),
                    Text(
                      '${detailVideo.subCount}',
                      style: textTheme.labelSmall!.copyWith(
                        color: Colors.white,
                        fontSize: 10.0,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      Icons.share_rounded,
                      color: Colors.white,
                    ),
                    Text(
                      '${detailVideo.shareCount}',
                      style: textTheme.labelSmall!.copyWith(
                        color: Colors.white,
                        fontSize: 10.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ]),
    );
  }
}
