// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:better_player/src/controls/better_player_clickable_widget.dart';
import 'package:better_player/src/video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:playlistmaster/entities/bilibili/bili_detail_resource.dart';
import 'package:playlistmaster/entities/bilibili/bili_subpage_of_resource.dart';
import 'package:playlistmaster/utils/my_toast.dart';
import 'package:provider/provider.dart';

import '../http/api.dart';
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

  MyAppState? _appState;

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

  List<String> _playingModeNames = [
    'Current once',
    'Current repeat',
    'Playlists once',
    'Playlists repeat',
  ];

  Map<String, String> _header = {
    'Referer': 'https://www.bilibili.com',
    'User-Agent':
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
  };

  List<IconData> _playingModeIcons = [
    Icons.repeat_one_rounded,
    Icons.repeat_one_on_rounded,
    Icons.repeat_rounded,
    Icons.repeat_on_rounded,
  ];

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
    _appState = state;
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
        overflowMenuCustomItems: [
          BetterPlayerOverflowMenuItem(Icons.repeat_rounded, 'Playing mode',
              () {
            _buildPlayingModeList();
          }),
        ],
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
    // String url =
    //     'https://baikevideo.cdn.bcebos.com/media/mda-OxWC3meZEwxyMv5u/a4d544933fd90ff496d7a72bf521cbed.mp4';
    String uri = _detailResource.links!.mpd;
    String url = 'http://${API.host}$uri';
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
      headers: _header,
      videoFormat: BetterPlayerVideoFormat.dash,
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
    _appState = appState;
    _isLocked = appState.isResourcePlayerLocked;
    return Scaffold(
      body: Center(
        child: SizedBox.expand(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: BetterPlayerMultipleGestureDetector(
                onDoubleTap: _onPlayPause,
                child: BetterPlayer(controller: _betterPlayerController)),
            // onLongPress: () async {
            //   dynamic currentPlayingSubResource =
            //       appState.currentPlayingSubResource;
            //   print(appState);
            //   final String? title;
            //   final String? author;
            //   final String? imageUrl;
            //   final String? cacheKey;
            //   final String? resourceId;

            //   if (_resourceType == 1) {
            //     title = currentPlayingSubResource.partName;
            //     author = _detailResource.upperName;
            //     imageUrl = _detailResource.cover;
            //     cacheKey =
            //         '${currentPlayingSubResource.bvid}:${currentPlayingSubResource.cid}';
            //     resourceId =
            //         '${currentPlayingSubResource.bvid}:${currentPlayingSubResource.cid}';
            //   } else {
            //     title = currentPlayingSubResource.title;
            //     author = currentPlayingSubResource.upperName;
            //     imageUrl = currentPlayingSubResource.cover;
            //     cacheKey =
            //         '${currentPlayingSubResource.bvid}:${currentPlayingSubResource.cid}';
            //     resourceId =
            //         '${currentPlayingSubResource.bvid}:${currentPlayingSubResource.cid}';
            //   }
            //   var links = await appState.fetchSongsLink([resourceId], 3);
            //   final url = 'http://${API.host}${links.mpd}';
            //   BetterPlayerDataSource dataSource = BetterPlayerDataSource(
            //     BetterPlayerDataSourceType.network,
            //     url,
            //     useAsmsSubtitles: true,
            //     useAsmsTracks: true,
            //     useAsmsAudioTracks: false,
            //     headers: _header,
            //     videoFormat: BetterPlayerVideoFormat.dash,
            //     cacheConfiguration: BetterPlayerCacheConfiguration(
            //       useCache: true,
            //       key: cacheKey,
            //     ),
            //     notificationConfiguration:
            //         BetterPlayerNotificationConfiguration(
            //       showNotification: true,
            //       title: title,
            //       author: author,
            //       imageUrl: imageUrl,
            //       activityName:
            //           'com.ryanheise.audioservice.AudioServiceActivity',
            //     ),
            //   );
            //   _betterPlayerController.setupDataSource(dataSource);
            //   // _betterPlayerController.stop
            //   print(_betterPlayerController);
            // },
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

  // TODO
  void setPlayingMode(int playingMode) {
    setState(() {
      _appState!.biliResourcePlayingMode = playingMode;
      MyToast.showToast(
          'Change to playing mode: ${_playingModeNames[playingMode]}');
      if (playingMode == 0) {
        _betterPlayerController.setLooping(false);
      } else if (playingMode == 1) {
        _betterPlayerController.setLooping(true);
      } else if (playingMode == 2) {
        if (_resourceType == 0) {
          _betterPlayerController.setLooping(false);
        } else {}
      } else if (playingMode == 3) {
        if (_resourceType == 0) {
          _betterPlayerController.setLooping(true);
        } else {}
      } else {
        throw Exception('Invalid playing mode');
      }
    });
  }

  Widget _buildPlayingModeRow(int playingMode) {
    final bool isSelected = playingMode == _appState!.biliResourcePlayingMode;
    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        Navigator.of(context).pop();
        setPlayingMode(playingMode);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            SizedBox(width: isSelected ? 8 : 16),
            Visibility(
                visible: isSelected,
                child: Icon(
                  Icons.check_outlined,
                  color: Colors.black,
                )),
            const SizedBox(width: 16),
            Text(
              _playingModeNames[playingMode],
              style: _getOverflowMenuElementTextStyle(isSelected),
            ),
            const SizedBox(width: 16),
            Icon(_playingModeIcons[playingMode]),
          ],
        ),
      ),
    );
  }

  TextStyle _getOverflowMenuElementTextStyle(bool isSelected) {
    return TextStyle(
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      color: isSelected ? Colors.black : Colors.black.withOpacity(0.7),
    );
  }

  void _buildPlayingModeList() {
    final List<Widget> children = [];
    for (var index = 0; index < 4; index++) {
      children.add(_buildPlayingModeRow(index));
    }
    _showMaterialBottomSheet(children);
  }

  void _showMaterialBottomSheet(List<Widget> children) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      context: context,
      useRootNavigator:
          _betterPlayerController.betterPlayerConfiguration.useRootNavigator,
      builder: (context) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: _betterPlayerController
                    .betterPlayerControlsConfiguration.overflowModalColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0)),
              ),
              child: Column(
                children: children,
              ),
            ),
          ),
        );
      },
    );
  }
}
