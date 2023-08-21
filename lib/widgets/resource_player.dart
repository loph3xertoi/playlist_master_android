// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:better_player/src/controls/better_player_clickable_widget.dart';
import 'package:better_player/src/video_player/video_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:playlistmaster/entities/bilibili/bili_detail_resource.dart';
import 'package:playlistmaster/entities/bilibili/bili_subpage_of_resource.dart';
import 'package:playlistmaster/utils/my_toast.dart';
import 'package:provider/provider.dart';

import '../entities/bilibili/bili_resource.dart';
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

  // Original resources in this opened favlist.
  List<BiliResource>? _originalResourcesOfFavList;

  bool _isLocked = false;

  Timer? _hideTimer;

  // Resource type, 0 for single resource, 1 for resource has multiple sub resources, 2 for episodes.
  late int _resourceType;

  VideoPlayerValue? _latestValue;

  bool _hasSkipedToNext = false;

  int? _currentResourceIndexInFavList;

  late List<String> _playingModeNames;

  late List<IconData> _playingModeIcons;

  Map<String, String> _header = {
    'Referer': 'https://www.bilibili.com',
    'User-Agent':
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
  };

  VideoPlayerValue? get latestValue => _latestValue;

  @override
  void didChangeDependencies() {
    _latestValue = _controller!.value;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // if (!_inDetailFavlistPage) {
    _controller!.dispose();
    // }
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    _appState = state;
    _playingModeNames = state.playingModeNames;
    _playingModeIcons = state.playingModeIcons;
    _detailResource = widget.detailResource;
    _originalResourcesOfFavList = state.rawResourcesInFavList;
    _currentResourceIndexInFavList = state.currentResourceIndexInFavList;
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      autoDispose: false,
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
        controlBarColor: Colors.black12,
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
    if (!kIsWeb) {
      _betterPlayerController.enablePictureInPicture(_betterPlayerKey);
    }
    _betterPlayerController.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.play) {
        _hasSkipedToNext = false;
      }
      if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
        if (!_hasSkipedToNext &&
            _appState!.biliResourcePlayingMode != 0 &&
            _appState!.biliResourcePlayingMode != 1) {
          _skipToNextSubResource();
          _hasSkipedToNext = true;
        }
      }
    });
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
    _originalResourcesOfFavList = appState.rawResourcesInFavList;
    _currentResourceIndexInFavList = appState.currentResourceIndexInFavList;
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

  void _skipToNextSubResource() async {
    dynamic nextSubResource;
    int subPageNo = _appState!.subPageNo;
    int playingMode = _appState!.biliResourcePlayingMode;
    if (playingMode == 2 || playingMode == 4 || playingMode == 5) {
      if (playingMode != 2) {
        if (_resourceType == 0) {
          nextSubResource = await _seekToNextResource();
          if (nextSubResource == null) {
            _hideTimer?.cancel();
            _startHideTimer();
            return;
          }
        } else if (_resourceType == 1) {
          if (subPageNo < _detailResource.subpages!.length) {
            subPageNo = ++_appState!.subPageNo;
            nextSubResource = _detailResource.subpages![subPageNo - 1];
          } else {
            nextSubResource = await _seekToNextResource();
            if (nextSubResource == null) {
              _hideTimer?.cancel();
              _startHideTimer();
              return;
            }
          }
        } else if (_resourceType == 2) {
          if (playingMode == 4) {
            // Don't traverse episodes.
            nextSubResource = await _seekToNextResource();
            if (nextSubResource == null) {
              _hideTimer?.cancel();
              _startHideTimer();
              return;
            }
          } else {
            // Traverse episodes.
            if (subPageNo < _detailResource.episodes!.length) {
              subPageNo = ++_appState!.subPageNo;
              nextSubResource = _detailResource.episodes![subPageNo - 1];
            } else {
              nextSubResource = await _seekToNextResource();
              if (nextSubResource == null) {
                _hideTimer?.cancel();
                _startHideTimer();
                return;
              }
            }
          }
        } else {
          throw Exception('Invalid resource type');
        }
      } else {
        if (_resourceType == 0) {
          _hideTimer?.cancel();
          _startHideTimer();
          return;
        } else if (_resourceType == 1) {
          if (subPageNo < _detailResource.subpages!.length) {
            subPageNo = ++_appState!.subPageNo;
            nextSubResource = _detailResource.subpages![subPageNo - 1];
          } else {
            _hideTimer?.cancel();
            _startHideTimer();
            return;
          }
        } else if (_resourceType == 2) {
          if (subPageNo < _detailResource.episodes!.length) {
            subPageNo = ++_appState!.subPageNo;
            nextSubResource = _detailResource.episodes![subPageNo - 1];
          } else {
            _hideTimer?.cancel();
            _startHideTimer();
            return;
          }
        } else {
          throw Exception('Invalid resource type');
        }
      }
    } else if (playingMode == 3 || playingMode == 6 || playingMode == 7) {
      if (playingMode != 3) {
        if (_resourceType == 0) {
          nextSubResource = await _seekToNextResource();
        } else if (_resourceType == 1) {
          if (subPageNo < _detailResource.subpages!.length) {
            subPageNo = ++_appState!.subPageNo;
            nextSubResource = _detailResource.subpages![subPageNo - 1];
          } else {
            nextSubResource = await _seekToNextResource();
          }
        } else if (_resourceType == 2) {
          if (playingMode == 6) {
            // Don't traverse episodes.
            nextSubResource = await _seekToNextResource();
          } else {
            // Traverse episodes.
            if (subPageNo < _detailResource.episodes!.length) {
              subPageNo = ++_appState!.subPageNo;
              nextSubResource = _detailResource.episodes![subPageNo - 1];
            } else {
              nextSubResource = await _seekToNextResource();
            }
          }
        } else {
          throw Exception('Invalid resource type');
        }
      } else {
        if (_resourceType == 0) {
          _hideTimer?.cancel();
          _startHideTimer();
          return;
        } else if (_resourceType == 1) {
          _appState!.subPageNo =
              subPageNo = subPageNo % _detailResource.subpages!.length + 1;
          nextSubResource = _detailResource.subpages![subPageNo - 1];
        } else if (_resourceType == 2) {
          // Traverse episodes.
          _appState!.subPageNo =
              subPageNo = subPageNo % _detailResource.episodes!.length + 1;
          nextSubResource = _detailResource.episodes![subPageNo - 1];
        } else {
          throw Exception('Invalid resource type');
        }
      }
    } else {
      throw Exception('Invalid playing mode: $playingMode');
    }

    print(_appState);
    final String? title;
    final String? author;
    final String? imageUrl;
    final String? cacheKey;
    final String? resourceId;
    cacheKey = resourceId = '${nextSubResource.bvid}:${nextSubResource.cid}';

    if (_resourceType == 1) {
      title = nextSubResource.partName;
      author = _detailResource.upperName;
      imageUrl = _detailResource.cover;
    } else {
      title = nextSubResource.title;
      author = nextSubResource.upperName;
      imageUrl = nextSubResource.cover;
    }
    var links = await _appState!
        .fetchSongsLink([resourceId], _appState!.currentPlatform);
    final url = 'http://${API.host}${links.mpd}';
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
    _controller!.refresh();
    _controller!.seekTo(Duration.zero);
    _betterPlayerController.setupDataSource(dataSource);
    _hideTimer?.cancel();
    _startHideTimer();
  }

  dynamic _seekToNextResource() async {
    dynamic nextSubResource;
    BiliDetailResource? nextResource;
    int playingMode = _appState!.biliResourcePlayingMode;
    bool hasNext = _currentResourceIndexInFavList! <
        _originalResourcesOfFavList!.length - 1;
    int nextResourceIndex = hasNext ? _currentResourceIndexInFavList! + 1 : 0;
    if (hasNext || playingMode == 6 || playingMode == 7) {
      do {
        if (hasNext || playingMode == 6 || playingMode == 7) {
          nextResource = await _appState!.fetchDetailSong<BiliDetailResource>(
              _originalResourcesOfFavList![nextResourceIndex],
              _appState!.currentPlatform);
          if (nextResource == null) {
            MyToast.showToast(
                'Failed to fetch detail resource ${nextResourceIndex + 1}: ${_appState!.errorMsg}');
            hasNext =
                nextResourceIndex < _originalResourcesOfFavList!.length - 1;
            nextResourceIndex = hasNext ? nextResourceIndex + 1 : 0;
          }
        }
      } while (nextResource == null);
      _appState!.currentResourceIndexInFavList = nextResourceIndex;
      setState(() {
        _detailResource = nextResource!;
      });
      _appState!.currentResource =
          _originalResourcesOfFavList![nextResourceIndex];
      _appState!.currentDetailResource = nextResource;
      _appState!.subPageNo = 1;
      if (_detailResource.isSeasonResource) {
        int subPageNo;
        if (playingMode == 4 || playingMode == 6) {
          var currentBvid = _detailResource.bvid;
          var episodesBvids =
              _detailResource.episodes!.map((e) => e.bvid).toList();
          subPageNo = episodesBvids.indexOf(currentBvid) + 1;
          // _appState!.setSubPageNoWithoutNotify(subPageNo);
          _appState!.subPageNo = subPageNo;
        } else if (playingMode == 5 || playingMode == 7) {
          _appState!.subPageNo = subPageNo = 1;
        } else {
          throw Exception('Invalid playing mode: $playingMode');
        }
        _resourceType = 2;
        nextSubResource = _detailResource.episodes![subPageNo - 1];
      } else if (_detailResource.page > 1) {
        _resourceType = 1;
        nextSubResource = _detailResource.subpages![0];
      } else if (_detailResource.page == 1) {
        _resourceType = 0;
        nextSubResource = _detailResource;
      } else {
        throw Exception('Invalid resource type');
      }
      return nextSubResource;
    } else if (playingMode == 0 ||
        playingMode == 1 ||
        playingMode == 2 ||
        playingMode == 3 ||
        playingMode == 4 ||
        playingMode == 5) {
      return null;
    } else {
      throw Exception('Invalid playing mode: $playingMode');
    }
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
        } else {
          _betterPlayerController.setLooping(false);
        }
      } else if (playingMode == 3) {
        if (_resourceType == 0) {
          _betterPlayerController.setLooping(false);
        } else {
          _betterPlayerController.setLooping(false);
        }
      } else if (playingMode == 4) {
        if (_resourceType == 0) {
          _betterPlayerController.setLooping(false);
        } else {
          _betterPlayerController.setLooping(false);
        }
      } else if (playingMode == 5) {
        if (_resourceType == 0) {
          _betterPlayerController.setLooping(false);
        } else {
          _betterPlayerController.setLooping(false);
        }
      } else if (playingMode == 6) {
        if (_resourceType == 0) {
          _betterPlayerController.setLooping(false);
        } else {
          _betterPlayerController.setLooping(false);
        }
      } else if (playingMode == 7) {
        if (_resourceType == 0) {
          _betterPlayerController.setLooping(false);
        } else {
          _betterPlayerController.setLooping(false);
        }
      } else {
        throw Exception('Invalid playing mode: $playingMode');
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
            SizedBox(width: isSelected ? 16 : 8),
            Icon(_playingModeIcons[playingMode]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _playingModeNames[playingMode],
                style: _getOverflowMenuElementTextStyle(isSelected),
              ),
            ),
            const SizedBox(width: 16),
            Visibility(
                visible: isSelected,
                child: Icon(
                  Icons.check_outlined,
                  color: Colors.black,
                )),
            const SizedBox(width: 16),
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
    for (var index = 0; index < _playingModeNames.length; index++) {
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
