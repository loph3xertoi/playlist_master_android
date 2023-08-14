// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:better_player/src/video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:playlistmaster/entities/bilibili/bili_detail_resource.dart';
import 'package:playlistmaster/entities/bilibili/bili_subpage_of_resource.dart';
import 'package:provider/provider.dart';

import '../states/app_state.dart';
import 'custom_controller_widget_better_player.dart';

class ResourcePlayer extends StatefulWidget {
  final BiliDetailResource detailResource;
  const ResourcePlayer({
    Key? key,
    required this.detailResource,
  }) : super(key: key);
  @override
  State<ResourcePlayer> createState() => _DashPageState();
}

class _DashPageState extends State<ResourcePlayer> {
  GlobalKey _betterPlayerKey = GlobalKey();

  late BetterPlayerController _betterPlayerController;

  late VideoPlayerController? _controller;

  late BiliDetailResource _detailResource;

  // The sub resource or episode currently playing, may be BiliDetailResource(episode)
  // or BiliSubPageOfResource(sub resource).
  late dynamic _currentPlayingSubResource;

  int _subPageNo = 1;

  bool _isDisposing = false;

  bool _isLocked = false;

  Timer? _hideTimer;

  // Resource type, 0 for single resource, 1 for resource has multiple sub resources, 2 for episodes.
  late int _resourceType;

  VideoPlayerValue? _latestValue;

  VideoPlayerValue? get latestValue => _latestValue;

  @override
  void didChangeDependencies() {
    _latestValue = _controller!.value;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _isDisposing = true;
    // _controller!.dispose();
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    _detailResource = widget.detailResource;
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      autoPlay: true,
      aspectRatio: 16 / 9,
      autoDetectFullscreenAspectRatio: true,
      routePageBuilder:
          (context, animation, secondaryAnimation, controllerProvider) {
        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            return _buildFullScreenVideo(
                context, animation, controllerProvider);
          },
        );
      },
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_rounded,
                color: Colors.white70,
                size: 42,
              ),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.0,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  _betterPlayerController.retryDataSource();
                },
                child: Text(
                  _betterPlayerController.translations.generalRetry,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.0,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        );
      },
      controlsConfiguration: BetterPlayerControlsConfiguration(
        // TODO: implement custom controls widget, include kid lock and so on.
        playerTheme: BetterPlayerTheme.custom,
        customControlsBuilder: (controller, onPlayerVisibilityChanged) {
          return CustomControlsWidget(
            controller: controller,
            onControlsVisibilityChanged: onPlayerVisibilityChanged,
          );
        },
        controlBarColor: Colors.transparent,
        loadingWidget: Lottie.asset(
          'assets/images/video_buffering.json',
          fit: BoxFit.scaleDown,
        ),
        showControlsOnInitialize: false,
        playIcon: Icons.play_arrow_rounded,
        pauseIcon: Icons.pause_rounded,
        muteIcon: Icons.volume_up_rounded,
        unMuteIcon: Icons.volume_off_rounded,
        pipMenuIcon: Icons.picture_in_picture_rounded,
        skipBackIcon: Icons.replay_10_rounded,
        qualitiesIcon: Icons.hd_rounded,
        subtitlesIcon: Icons.closed_caption_rounded,
        audioTracksIcon: Icons.audiotrack_rounded,
        skipForwardIcon: Icons.forward_10_rounded,
        overflowMenuIcon: Icons.more_vert_rounded,
        playbackSpeedIcon: Icons.shutter_speed_rounded,
        fullscreenEnableIcon: Icons.fullscreen_rounded,
        fullscreenDisableIcon: Icons.fullscreen_exit_rounded,
      ),
    );
    // String mpdName = '${widget.resource.bvid}_${widget.resource.cid}.mpd';
    // String url = 'https://cdn.bitmovin.com/content/assets/art-of-motion-dash-hls-progressive/mpds/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.mpd';
    // String url = 'https://bitmovin-a.akamaihd.net/content/sintel/sintel.mpd';
    // String url = 'https://dash.akamaized.net/envivio/EnvivioDash3/manifest.mpd';
    // String url = 'http://${API.host}${widget.links.mpd}';
    String url =
        'https://baikevideo.cdn.bcebos.com/media/mda-OxWC3meZEwxyMv5u/a4d544933fd90ff496d7a72bf521cbed.mp4';
    Map<String, String> header = {
      'Referer': 'https://www.bilibili.com',
      'User-Agent':
          'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
    };

    if (_detailResource.isSeasonResource) {
      _resourceType = 2;
    } else if (_detailResource.page > 1) {
      _resourceType = 1;
    } else if (_detailResource.page == 1) {
      _resourceType = 0;
    } else {
      throw Exception('Invalid resource type');
    }

    final String? title;
    final String? author;
    final String? imageUrl;
    final String? cacheKey;

    if (_resourceType == 1) {
      BiliSubpageOfResource resource = _detailResource.subpages![0];
      title = resource.partName;
      author = state.currentResource!.upperName;
      imageUrl = state.currentResource!.cover;
      cacheKey = '${resource.bvid}:${resource.cid}';
    } else {
      title = _detailResource.title;
      author = _detailResource.upperName;
      imageUrl = _detailResource.cover;
      cacheKey = '${_detailResource.bvid}:${_detailResource.cid}';
    }

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      useAsmsSubtitles: true,
      useAsmsTracks: true,
      useAsmsAudioTracks: false,
      // headers: header,
      // videoFormat: BetterPlayerVideoFormat.dash,
      cacheConfiguration: BetterPlayerCacheConfiguration(
        useCache: true,
        key: cacheKey,
      ),
      notificationConfiguration: BetterPlayerNotificationConfiguration(
        showNotification: true,
        title: title,
        author: author,
        imageUrl: imageUrl,
        activityName: 'com.ryanheise.audioservice.AudioServiceActivity',
      ),
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(dataSource);
    _betterPlayerController.setBetterPlayerGlobalKey(_betterPlayerKey);
    _betterPlayerController.enablePictureInPicture(_betterPlayerKey);
    _controller = _betterPlayerController.videoPlayerController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      state.betterPlayerController = _betterPlayerController;
    });
  }

  Widget _buildFullScreenVideo(
      BuildContext context,
      Animation<double> animation,
      BetterPlayerControllerProvider controllerProvider) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BetterPlayerMultipleGestureDetector(
        onDoubleTap: _onPlayPause,
        child: Container(
          alignment: Alignment.center,
          color: Colors.black,
          child: controllerProvider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    _isLocked = appState.isResourcePlayerLocked;
    return Scaffold(
      body: Center(
        child: SizedBox.expand(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: BetterPlayerMultipleGestureDetector(
                onDoubleTap: _onPlayPause,
                child: BetterPlayer(controller: _betterPlayerController)),
          ),
        ),
      ),
    );
  }

  void _startHideTimer() {
    if (_betterPlayerController.controlsAlwaysVisible) {
      return;
    }
    _hideTimer = Timer(const Duration(milliseconds: 3000), () {
      _betterPlayerController.setControlsVisibility(false);
    });
  }

  void cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();
    _betterPlayerController.setControlsVisibility(false);
  }

  void _onPlayPause() {
    if (_isLocked) {
      return;
    }

    bool isFinished = false;

    if (_latestValue?.position != null && _latestValue?.duration != null) {
      isFinished = _latestValue!.position >= _latestValue!.duration!;
    }

    if (_controller!.value.isPlaying) {
      _betterPlayerController.setControlsVisibility(true);
      _hideTimer?.cancel();
      _betterPlayerController.pause();
    } else {
      cancelAndRestartTimer();

      if (!_controller!.value.initialized) {
      } else {
        if (isFinished) {
          _betterPlayerController.seekTo(const Duration());
        }
        _betterPlayerController.play();
        _betterPlayerController.cancelNextVideoTimer();
      }
    }
  }
}
