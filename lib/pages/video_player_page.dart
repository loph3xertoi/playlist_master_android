import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fplayer/fplayer.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../entities/basic/basic_video.dart';
import '../entities/qq_music/qqmusic_detail_video.dart';
import '../http/my_http.dart';
import '../states/app_state.dart';
import '../utils/my_logger.dart';
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
  final FPlayer _player = FPlayer();
  late Future<BasicVideo?> _detailVideo;
  late int platform;
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
    state.videoSeekTime = _player.currentPos.inMilliseconds;
    super.deactivate();
  }

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    var isUsingMockData = state.isUsingMockData;
    var currentPlatform = state.currentPlatform;
    platform = currentPlatform;
    if (isUsingMockData) {
      throw Exception('No mock data for video');
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
    // _player.removeListener(_preparedListener);
    _player.release();
  }

  void _startPlay() async {
    var resolutionList = await _resolutionList;
    await _player.setOption(FOption.hostCategory, 'request-screen-on', 1);
    await _player.setOption(FOption.hostCategory, 'request-audio-focus', 1);
    await _player.setOption(FOption.playerCategory, 'reconnect', 20);
    await _player.setOption(FOption.playerCategory, 'framedrop', 20);
    await _player.setOption(FOption.playerCategory, 'enable-accurate-seek', 1);
    await _player.setOption(FOption.playerCategory, 'mediacodec', 1);
    await _player.setOption(FOption.playerCategory, 'packet-buffering', 0);
    await _player.setOption(FOption.playerCategory, 'soundtouch', 1);

    await _player.setLoop(0);

    // _player.addListener(_preparedListener);

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
  //   FValue value = _player.value;
  //   print('Resolution: ${value.size}');
  //   if (value.prepared) {
  //     print('prepared');
  //   }
  // }

  // Determine the resolution URLs based on the length of videoLinks
  Future<Map<String, ResolutionItem>> _getResolutionList(
      Future<BasicVideo?> video, int platform) async {
    Map<String, ResolutionItem> resolutionList = {};
    List<String> videoLinks;
    if (platform == 1) {
      QQMusicDetailVideo qqMusicDetailVideo =
          (await video) as QQMusicDetailVideo;
      videoLinks = qqMusicDetailVideo.links;
    } else {
      throw Exception('Only implement qq music platform');
    }
    // String? finalUrl = await _cachedVideoUrl(url);
    // if (finalUrl == null) {
    //   throw Exception('Http request error.');
    // }
    // Add resolutions based on the length of videoLinks
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

    return resolutionList;
  }

  Future<void> _setVideoUrl(String url) async {
    try {
      await _player.setDataSource(url, autoPlay: true, showCover: true);
    } catch (error) {
      throw Exception('Exception: $error');
    }
  }

  void _updateResolutionList() async {
    _resolutionList = _getResolutionList(_detailVideo, platform);
    Map<String, ResolutionItem> resolutionList = await _resolutionList;
    await _player.reset();
    await _setVideoUrl(resolutionList[_resolutionKey]!.url);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    var currentPlatform = appState.currentPlatform;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SelectableText(
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
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
                      _detailVideo =
                          appState.fetchDetailMV(widget.video, currentPlatform);
                    });
                  },
                ),
              ],
            ),
          );
        } else {
          dynamic detailVideo;
          if (currentPlatform == 1) {
            detailVideo = snapshot.data![0] as QQMusicDetailVideo;
          } else {
            throw Exception('Only implement qq music platform');
          }
          Map<String, ResolutionItem> resolutionList =
              snapshot.data![1] as Map<String, ResolutionItem>;
          return Scaffold(
            body: Material(
              color: Colors.black,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 50.0),
                      child: FView(
                        player: _player,
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
                            print(_player);
                            print(_player.value.size!.height);
                            // String key =
                            //     '${_player.value.size!.height.toInt()}p';
                            // String videoLink = resolutionList[key]!.url;

                            String videoLink = _player.dataSource!;
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
                            await _player.reset();
                            _setVideoUrl(detailVideo.videoLinks[0]);
                          },
                          onVideoEnd: () async {
                            // await _player.reset();
                            // _setVideoUrl(detailVideo.videoLinks[0]);
                          },
                          onVideoTimeChange: () {
                            // 视频时间变动则触发一次，可以保存视频播放历史
                            appState.videoSeekTime =
                                _player.currentPos.inMilliseconds;
                          },
                          onVideoPrepared: () async {
                            // 视频初始化完毕，如有历史记录时间段则可以触发快进
                            print('daw${detailVideo.vid}');
                            int seekTime = appState.videoSeekTime;
                            try {
                              if (seekTime >= 1 &&
                                  detailVideo.vid == appState.lastVideoVid) {
                                /// seekTo必须在FState.prepared
                                print('seekTo');
                                await _player.seekTo(seekTime);
                                int seconds = (seekTime / 1000).truncate();
                                int minutes = (seconds / 60).truncate();
                                seconds %= 60;
                                String formattedTime =
                                    '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
                                // MyToast.showToast('Seek to $formattedTime');
                                appState.videoSeekTime = 0;
                              } else {
                                appState.lastVideoVid = detailVideo.vid;
                              }
                            } catch (error) {
                              print('Exception: $error');
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
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
                                'https://y.qq.com/music/photo_new/T001R300x300M000${detailVideo.singers[0].mid}_2.jpg',
                              ),
                            ),
                          ),
                        ),
                        Text(
                          detailVideo.singers.map((e) => e.name).join(', '),
                          style: textTheme.labelMedium!
                              .copyWith(color: Colors.white),
                        ),
                      ]),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                                      fontSize: 10.0,
                                      color: Colors.white.withOpacity(0.8)),
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
                                  horizontal: 5.0, vertical: 20.0),
                              child: Text(
                                'viewed times: ${NumberFormat('#,###').format(detailVideo.playCnt)}',
                                style: textTheme.labelSmall!.copyWith(
                                    color: Colors.white.withOpacity(0.4)),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0, vertical: 20.0),
                              child: Text(
                                DateFormat('yyyy-MM-dd HH:mm:ss').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        detailVideo.pubDate * 1000)),
                                style: textTheme.labelSmall!.copyWith(
                                    color: Colors.white.withOpacity(0.4)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
