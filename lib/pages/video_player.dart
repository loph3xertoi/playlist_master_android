import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fplayer/fplayer.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:playlistmaster/entities/song.dart';
import 'package:playlistmaster/entities/video.dart';
import 'package:playlistmaster/states/app_state.dart';
import 'package:playlistmaster/utils/my_toast.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key, required this.song});

  final Song song;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  final FPlayer _player = FPlayer();
  late Future<Video> _video;

  // Speed list.
  Map<String, double> _speedList = {
    '2.0': 2.0,
    '1.5': 1.5,
    '1.0': 1.0,
    '0.5': 0.5,
  };

  // Resolution list.
  late Map<String, ResolutionItem> _resolutionList;

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
    _video = state.fetchMVDetail(widget.song, 1);
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
    Video video = await _video;
    _resolutionList = _getResolutionList(video.videoLinks);
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
    _setVideoUrl(video.videoLinks[0]);
  }

  // void _preparedListener() {
  //   FValue value = _player.value;
  //   print('Resolution: ${value.size}');
  //   if (value.prepared) {
  //     print('prepared');
  //   }
  // }

  // Determine the resolution URLs based on the length of videoLinks
  Map<String, ResolutionItem> _getResolutionList(List<String> videoLinks) {
    Map<String, ResolutionItem> resolutionList = {};

    // Add resolutions based on the length of videoLinks
    if (videoLinks.isNotEmpty) {
      resolutionList['360p'] = ResolutionItem(value: 360, url: videoLinks[0]);
    }
    if (videoLinks.length >= 2) {
      resolutionList['480p'] = ResolutionItem(value: 480, url: videoLinks[1]);
    }
    if (videoLinks.length >= 3) {
      resolutionList['720p'] = ResolutionItem(value: 720, url: videoLinks[2]);
    }
    if (videoLinks.length >= 4) {
      resolutionList['1080p'] = ResolutionItem(value: 1080, url: videoLinks[3]);
    }
    if (videoLinks.length >= 5) {
      for (int i = 4; i < videoLinks.length; i++) {
        String resolutionName = '1080p${i - 3}';
        resolutionList[resolutionName] =
            ResolutionItem(value: 1080, url: videoLinks[i]);
      }
    }

    return resolutionList;
  }

  Future<void> _setVideoUrl(String url) async {
    try {
      await _player.setDataSource(url, autoPlay: true, showCover: true);
    } catch (error) {
      print('Exception: $error');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    Size size = mediaQueryData.size;
    double videoHeight = size.width * 7 / 16;

    return FutureBuilder(
      future: _video,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _video = appState.fetchMVDetail(widget.song, 1);
                    });
                  },
                ),
              ],
            ),
          );
        } else {
          Video detailVideo = snapshot.data as Video;
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
                          resolutionList: _resolutionList,
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
                                MyToast.showToast('Seek to $formattedTime');
                                seekTime = 0;
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
                          detailVideo.singers[0].name,
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
                                        detailVideo.pubdate * 1000)),
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
