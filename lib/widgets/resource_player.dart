// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:playlistmaster/entities/bilibili/bili_detail_resource.dart';
import 'package:playlistmaster/entities/bilibili/bili_subpage_of_resource.dart';
import 'package:provider/provider.dart';

import '../entities/dto/bili_links_dto.dart';
import '../http/api.dart';
import '../states/app_state.dart';

class ResourcePlayer extends StatefulWidget {
  final BiliLinksDTO links;
  final dynamic resource;
  const ResourcePlayer({
    Key? key,
    required this.links,
    required this.resource,
  }) : super(key: key);
  @override
  State<ResourcePlayer> createState() => _DashPageState();
}

class _DashPageState extends State<ResourcePlayer> {
  late BetterPlayerController _betterPlayerController;
  GlobalKey _betterPlayerKey = GlobalKey();
  bool _isDisposing = false;

  @override
  void dispose() {
    _betterPlayerController.dispose();
    _isDisposing = true;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      autoPlay: true,
      aspectRatio: 16 / 9,
      autoDetectFullscreenAspectRatio: true,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(errorMessage!),
        );
      },
      controlsConfiguration: BetterPlayerControlsConfiguration(
        // TODO: implement custom controls widget, include kid lock and so on.
        // playerTheme: BetterPlayerTheme.custom,
        // customControlsBuilder: (controller, onPlayerVisibilityChanged) {
        //   return CustomControlsWidget(
        //     controller: controller,
        //     onControlsVisibilityChanged: onPlayerVisibilityChanged,
        //   );
        // },
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
        fullscreenDisableIcon: Icons.fullscreen_rounded,
      ),
    );
    // String mpdName = '${widget.resource.bvid}_${widget.resource.cid}.mpd';
    // String url = 'https://cdn.bitmovin.com/content/assets/art-of-motion-dash-hls-progressive/mpds/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.mpd';
    // String url = 'https://bitmovin-a.akamaihd.net/content/sintel/sintel.mpd';
    // String url = 'https://dash.akamaized.net/envivio/EnvivioDash3/manifest.mpd';
    String url = 'http://${API.host}${widget.links.mpd}';
    // String url =
    //     'https://baikevideo.cdn.bcebos.com/media/mda-OxWC3meZEwxyMv5u/a4d544933fd90ff496d7a72bf521cbed.mp4';
    Map<String, String> header = {
      'Referer': 'https://www.bilibili.com',
      'User-Agent':
          'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
    };
    final String? title;
    final String? author;
    final String? imageUrl;
    if (widget.resource is BiliDetailResource) {
      BiliDetailResource resource = widget.resource as BiliDetailResource;
      title = resource.title;
      author = resource.upperName;
      imageUrl = resource.cover;
    } else if (widget.resource is BiliSubpageOfResource) {
      BiliSubpageOfResource resource = widget.resource as BiliSubpageOfResource;
      title = resource.partName;
      author = state.currentResource!.upperName;
      imageUrl = state.currentResource!.cover;
    } else {
      throw Exception('Invalid resource type');
    }
    String cacheKey = '${widget.resource.bvid}:${widget.resource.cid}';
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      useAsmsSubtitles: true,
      useAsmsTracks: true,
      useAsmsAudioTracks: false,
      headers: header,
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      state.betterPlayerController = _betterPlayerController;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox.expand(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: BetterPlayer(controller: _betterPlayerController),
          ),
        ),
      ),
    );
  }
}
