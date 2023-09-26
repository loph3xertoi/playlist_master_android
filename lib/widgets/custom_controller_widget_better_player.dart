import 'dart:async';

import 'package:better_player/src/configuration/better_player_controls_configuration.dart';
import 'package:better_player/src/controls/better_player_clickable_widget.dart';
import 'package:better_player/src/controls/better_player_controls_state.dart';
import 'package:better_player/src/controls/better_player_material_progress_bar.dart';
import 'package:better_player/src/controls/better_player_multiple_gesture_detector.dart';
import 'package:better_player/src/controls/better_player_progress_colors.dart';
import 'package:better_player/src/core/better_player_controller.dart';
import 'package:better_player/src/core/better_player_utils.dart';
import 'package:better_player/src/video_player/video_player.dart';
// Flutter imports:
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../states/app_state.dart';

class CustomControlsWidget extends StatefulWidget {
  ///Callback used to send information if player bar is hidden or not
  final Function(bool visbility) onControlsVisibilityChanged;

  final BetterPlayerController? controller;

  const CustomControlsWidget({
    Key? key,
    required this.onControlsVisibilityChanged,
    required this.controller,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CustomControlsWidgetState();
  }
}

class _CustomControlsWidgetState
    extends BetterPlayerControlsState<CustomControlsWidget> {
  VideoPlayerValue? _latestValue;
  double? _latestVolume;
  Timer? _hideTimer;
  Timer? _initTimer;
  Timer? _showAfterExpandCollapseTimer;
  bool _displayTapped = false;
  bool _wasLoading = false;
  bool _isLocked = false;
  MyAppState? _appState;
  BetterPlayerController? _betterPlayerController;
  VideoPlayerController? _controller;
  StreamSubscription? _controlsVisibilityStreamSubscription;

  @override
  VideoPlayerValue? get latestValue => _latestValue;

  @override
  BetterPlayerController? get betterPlayerController => _betterPlayerController;

  @override
  BetterPlayerControlsConfiguration get betterPlayerControlsConfiguration =>
      _betterPlayerController!.betterPlayerControlsConfiguration;

  @override
  Widget build(BuildContext context) {
    _appState = context.watch<MyAppState>();
    return WillPopScope(
      onWillPop: () async {
        if (_isLocked) {
          setState(() {
            _isLocked = false;
            _appState!.isResourcePlayerLocked = _isLocked;
          });
          return false;
        }
        if (_betterPlayerController!.isFullScreen) {
          // Timer(Duration(milliseconds: 300), () {
          //   setState(() {
          //     _appState!.isFullScreen = false;
          //   });
          // });
          _onExpandCollapse();
          return false;
        }
        return true;
      },
      child: buildLTRDirectionality(_buildMainWidget()),
    );
  }

  ///Builds main widget of the controls.
  Widget _buildMainWidget() {
    _wasLoading = isLoading(_latestValue);
    if (_latestValue?.hasError == true) {
      return Container(
        color: Colors.black,
        child: _buildErrorWidget(),
      );
    }
    return GestureDetector(
      onTap: () {
        if (BetterPlayerMultipleGestureDetector.of(context) != null) {
          BetterPlayerMultipleGestureDetector.of(context)!.onTap?.call();
        }
        controlsNotVisible
            ? cancelAndRestartTimer()
            : changePlayerControlsNotVisible(true);
      },
      onDoubleTap: () {
        if (BetterPlayerMultipleGestureDetector.of(context) != null) {
          BetterPlayerMultipleGestureDetector.of(context)!.onDoubleTap?.call();
        }
        cancelAndRestartTimer();
      },
      onLongPress: () {
        if (BetterPlayerMultipleGestureDetector.of(context) != null) {
          BetterPlayerMultipleGestureDetector.of(context)!.onLongPress?.call();
        }
      },
      child: AbsorbPointer(
        absorbing: controlsNotVisible,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_wasLoading)
              Center(child: _buildLoadingWidget())
            else
              _buildHitArea(),
            Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),
            Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),
            _buildNextVideoWidget(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dispose();
    // _controller!.dispose();
    // _betterPlayerController!.dispose();
    super.dispose();
  }

  void _dispose() {
    _controller?.removeListener(_updateState);
    _hideTimer?.cancel();
    _initTimer?.cancel();
    _showAfterExpandCollapseTimer?.cancel();
    _controlsVisibilityStreamSubscription?.cancel();
  }

  @override
  void didChangeDependencies() {
    final oldController = _betterPlayerController;
    _betterPlayerController = BetterPlayerController.of(context);
    _controller = _betterPlayerController!.videoPlayerController;
    _latestValue = _controller!.value;

    if (oldController != _betterPlayerController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  Widget _buildErrorWidget() {
    final errorBuilder =
        _betterPlayerController!.betterPlayerConfiguration.errorBuilder;
    if (errorBuilder != null) {
      return errorBuilder(
          context,
          _betterPlayerController!
              .videoPlayerController!.value.errorDescription);
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              color: Colors.white70,
              size: 42,
            ),
            Text(
              _betterPlayerController!.translations.generalDefaultError,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14.0,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
            if (betterPlayerControlsConfiguration.enableRetry)
              TextButton(
                onPressed: () {
                  _betterPlayerController!.retryDataSource();
                },
                child: Text(
                  _betterPlayerController!.translations.generalRetry,
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
    }
  }

  Widget _buildTopBar() {
    if (!betterPlayerController!.controlsEnabled || _isLocked) {
      return const SizedBox();
    }

    return Container(
      child: (betterPlayerControlsConfiguration.enableOverflowMenu)
          ? AnimatedOpacity(
              opacity: controlsNotVisible ? 0.0 : 1.0,
              duration: betterPlayerControlsConfiguration.controlsHideTime,
              onEnd: _onPlayerHide,
              child: SizedBox(
                height: betterPlayerControlsConfiguration.controlBarHeight,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildBackButton(),
                    Spacer(),
                    if (betterPlayerControlsConfiguration.enablePip)
                      _buildPipButtonWrapperWidget(
                          controlsNotVisible, _onPlayerHide)
                    else
                      const SizedBox(),
                    _buildMoreButton(),
                  ],
                ),
              ),
            )
          : const SizedBox(),
    );
  }

  Widget _buildPipButton() {
    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        betterPlayerController!.enablePictureInPicture(
            betterPlayerController!.betterPlayerGlobalKey!);
      },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          betterPlayerControlsConfiguration.pipMenuIcon,
          color: betterPlayerControlsConfiguration.iconsColor,
        ),
      ),
    );
  }

  Widget _buildPipButtonWrapperWidget(
      bool hideStuff, void Function() onPlayerHide) {
    return FutureBuilder<bool>(
      future: betterPlayerController!.isPictureInPictureSupported(),
      builder: (context, snapshot) {
        final bool isPipSupported = snapshot.data ?? false;
        if (isPipSupported &&
            _betterPlayerController!.betterPlayerGlobalKey != null) {
          return AnimatedOpacity(
            opacity: hideStuff ? 0.0 : 1.0,
            duration: betterPlayerControlsConfiguration.controlsHideTime,
            onEnd: onPlayerHide,
            child: SizedBox(
              height: betterPlayerControlsConfiguration.controlBarHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildPipButton(),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildMoreButton() {
    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        onShowMoreClicked();
      },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          betterPlayerControlsConfiguration.overflowMenuIcon,
          color: betterPlayerControlsConfiguration.iconsColor,
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        _onBackClicked();
      },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.arrow_back_rounded,
          color: betterPlayerControlsConfiguration.iconsColor,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    if (!betterPlayerController!.controlsEnabled || _isLocked) {
      return const SizedBox();
    }
    return AnimatedOpacity(
      opacity: controlsNotVisible ? 0.0 : 1.0,
      duration: betterPlayerControlsConfiguration.controlsHideTime,
      onEnd: _onPlayerHide,
      child: SizedBox(
        height: betterPlayerControlsConfiguration.controlBarHeight + 20.0,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (betterPlayerControlsConfiguration.enablePlayPause)
                    _buildPlayPause(_controller!)
                  else
                    const SizedBox(),
                  if (_betterPlayerController!.isLiveStream())
                    _buildLiveWidget()
                  else
                    betterPlayerControlsConfiguration.enableProgressText
                        ? _buildPastPosition()
                        : const SizedBox(),
                  if (_betterPlayerController!.isLiveStream())
                    const Spacer()
                  else
                    betterPlayerControlsConfiguration.enableProgressBar
                        ? _buildProgressBar()
                        : const Spacer(),
                  if (_betterPlayerController!.isLiveStream())
                    _buildLiveWidget()
                  else
                    betterPlayerControlsConfiguration.enableProgressText
                        ? _buildTotalDuration()
                        : const SizedBox(),
                  if (betterPlayerControlsConfiguration.enableMute)
                    _buildMuteButton(_controller)
                  else
                    const SizedBox(),
                  if (betterPlayerControlsConfiguration.enableFullscreen)
                    _buildExpandButton()
                  else
                    const SizedBox(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveWidget() {
    return SizedBox(
      width: 30.0,
      height: 30.0,
      child: Text(
        _betterPlayerController!.translations.controlsLive,
        style: TextStyle(
            color: betterPlayerControlsConfiguration.liveTextColor,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildExpandButton() {
    return BetterPlayerMaterialClickableWidget(
      onTap: _onExpandCollapse,
      child: AnimatedOpacity(
        opacity: controlsNotVisible ? 0.0 : 1.0,
        duration: betterPlayerControlsConfiguration.controlsHideTime,
        child: SizedBox(
          height: 40.0,
          width: 40.0,
          child: Center(
            child: Icon(
              _betterPlayerController!.isFullScreen
                  ? betterPlayerControlsConfiguration.fullscreenDisableIcon
                  : betterPlayerControlsConfiguration.fullscreenEnableIcon,
              color: betterPlayerControlsConfiguration.iconsColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHitArea() {
    if (!betterPlayerController!.controlsEnabled) {
      return const SizedBox();
    }
    return Center(
      child: AnimatedOpacity(
        opacity: controlsNotVisible ? 0.0 : 1.0,
        duration: betterPlayerControlsConfiguration.controlsHideTime,
        child: _buildMiddleRow(),
      ),
    );
  }

  Widget _buildMiddleRow() {
    return Container(
      color: betterPlayerControlsConfiguration.controlBarColor,
      width: double.infinity,
      height: double.infinity,
      child: _betterPlayerController?.isLiveStream() == true
          ? const SizedBox()
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_isLocked)
                  _buildLockButton()
                else
                  const SizedBox(
                    height: 40.0,
                    width: 40.0,
                  ),
                if (betterPlayerControlsConfiguration.enableSkips && !_isLocked)
                  _buildSkipButton()
                else
                  const SizedBox(),
                if (!_isLocked) _buildReplayButton(_controller!),
                if (betterPlayerControlsConfiguration.enableSkips && !_isLocked)
                  _buildForwardButton()
                else
                  const SizedBox(),
                _buildLockButton()
              ],
            ),
    );
  }

  Widget _buildHitAreaClickableButton(
      {Widget? icon,
      double width = 40.0,
      double height = 40.0,
      required void Function() onClicked}) {
    return SizedBox(
      width: width,
      height: height,
      child: BetterPlayerMaterialClickableWidget(
        onTap: onClicked,
        child: Align(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(48),
            ),
            child: Stack(
              children: [icon!],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLockButton() {
    return _buildHitAreaClickableButton(
      icon: Icon(
        _isLocked ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
        size: 24,
        color: betterPlayerControlsConfiguration.iconsColor.withOpacity(0.7),
      ),
      onClicked: () {
        setState(() {
          _isLocked = !_isLocked;
          _appState!.isResourcePlayerLocked = _isLocked;
        });
      },
    );
  }

  Widget _buildSkipButton() {
    return _buildHitAreaClickableButton(
      icon: Icon(
        betterPlayerControlsConfiguration.skipBackIcon,
        size: 24,
        color: betterPlayerControlsConfiguration.iconsColor.withOpacity(0.7),
      ),
      onClicked: skipBack,
    );
  }

  Widget _buildForwardButton() {
    return _buildHitAreaClickableButton(
      icon: Icon(
        betterPlayerControlsConfiguration.skipForwardIcon,
        size: 24,
        color: betterPlayerControlsConfiguration.iconsColor.withOpacity(0.7),
      ),
      onClicked: skipForward,
    );
  }

  Widget _buildReplayButton(VideoPlayerController controller) {
    final bool isFinished = isVideoFinished(_latestValue);
    return _buildHitAreaClickableButton(
      icon: isFinished
          ? Icon(
              Icons.replay,
              size: 45,
              color:
                  betterPlayerControlsConfiguration.iconsColor.withOpacity(0.7),
            )
          : Icon(
              controller.value.isPlaying
                  ? betterPlayerControlsConfiguration.pauseIcon
                  : betterPlayerControlsConfiguration.playIcon,
              size: 45,
              color:
                  betterPlayerControlsConfiguration.iconsColor.withOpacity(0.7),
            ),
      width: 60.0,
      height: 60.0,
      onClicked: () {
        if (isFinished) {
          if (_latestValue != null && _latestValue!.isPlaying) {
            if (_displayTapped) {
              changePlayerControlsNotVisible(true);
            } else {
              cancelAndRestartTimer();
            }
          } else {
            _onPlayPause();
            changePlayerControlsNotVisible(true);
          }
        } else {
          _onPlayPause();
        }
      },
    );
  }

  Widget _buildNextVideoWidget() {
    return StreamBuilder<int?>(
      stream: _betterPlayerController!.nextVideoTimeStream,
      builder: (context, snapshot) {
        final time = snapshot.data;
        if (time != null && time > 0) {
          return BetterPlayerMaterialClickableWidget(
            onTap: () {
              _betterPlayerController!.playNextVideo();
            },
            child: Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: EdgeInsets.only(
                    bottom:
                        betterPlayerControlsConfiguration.controlBarHeight + 20,
                    right: 24),
                decoration: BoxDecoration(
                  color: betterPlayerControlsConfiguration.controlBarColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    "${_betterPlayerController!.translations.controlsNextVideoIn} $time...",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildMuteButton(
    VideoPlayerController? controller,
  ) {
    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        cancelAndRestartTimer();
        if (_latestValue!.volume == 0) {
          _betterPlayerController!.setVolume(_latestVolume ?? 0.5);
        } else {
          _latestVolume = controller!.value.volume;
          _betterPlayerController!.setVolume(0.0);
        }
      },
      child: AnimatedOpacity(
        opacity: controlsNotVisible ? 0.0 : 1.0,
        duration: betterPlayerControlsConfiguration.controlsHideTime,
        child: SizedBox(
          width: 40.0,
          height: 40.0,
          child: Icon(
            (_latestValue != null && _latestValue!.volume > 0)
                ? betterPlayerControlsConfiguration.muteIcon
                : betterPlayerControlsConfiguration.unMuteIcon,
            color: betterPlayerControlsConfiguration.iconsColor,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayPause(VideoPlayerController controller) {
    return BetterPlayerMaterialClickableWidget(
      key: const Key("better_player_material_controls_play_pause_button"),
      onTap: _onPlayPause,
      child: SizedBox(
        height: 40.0,
        width: 40.0,
        child: Icon(
          controller.value.isPlaying
              ? betterPlayerControlsConfiguration.pauseIcon
              : betterPlayerControlsConfiguration.playIcon,
          color: betterPlayerControlsConfiguration.iconsColor,
        ),
      ),
    );
  }

  Widget _buildPastPosition() {
    final textTheme = Theme.of(context).textTheme;
    final position =
        _latestValue != null ? _latestValue!.position : Duration.zero;

    return SizedBox(
      width: 40.0,
      child: Text(
        BetterPlayerUtils.formatDuration(position),
        style: textTheme.labelSmall!.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildTotalDuration() {
    final textTheme = Theme.of(context).textTheme;
    final duration = _latestValue != null && _latestValue!.duration != null
        ? _latestValue!.duration!
        : Duration.zero;

    return SizedBox(
      width: 40.0,
      child: Text(
        BetterPlayerUtils.formatDuration(duration),
        style: textTheme.labelSmall!.copyWith(color: Colors.white),
      ),
    );
  }

  @override
  void cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();

    changePlayerControlsNotVisible(false);
    _displayTapped = true;
  }

  Future<void> _initialize() async {
    _controller!.addListener(_updateState);

    _updateState();

    if ((_controller!.value.isPlaying) ||
        _betterPlayerController!.betterPlayerConfiguration.autoPlay) {
      _startHideTimer();
    }

    if (betterPlayerControlsConfiguration.showControlsOnInitialize) {
      _initTimer = Timer(const Duration(milliseconds: 200), () {
        changePlayerControlsNotVisible(false);
      });
    }

    _controlsVisibilityStreamSubscription =
        _betterPlayerController!.controlsVisibilityStream.listen((state) {
      changePlayerControlsNotVisible(!state);
      if (!controlsNotVisible) {
        cancelAndRestartTimer();
      }
    });
  }

  void _onExpandCollapse() {
    changePlayerControlsNotVisible(true);
    if (_betterPlayerController!.isFullScreen) {
      Timer(Duration(milliseconds: 300), () {
        _appState!.isFullScreen = false;
      });
    } else {
      _appState!.isFullScreen = true;
    }
    _betterPlayerController!.toggleFullScreen();
    _showAfterExpandCollapseTimer =
        Timer(betterPlayerControlsConfiguration.controlsHideTime, () {
      setState(() {
        cancelAndRestartTimer();
      });
    });
  }

  void _onPlayPause() {
    bool isFinished = false;

    if (_latestValue?.position != null && _latestValue?.duration != null) {
      isFinished = _latestValue!.position >= _latestValue!.duration!;
    }

    if (_controller!.value.isPlaying) {
      changePlayerControlsNotVisible(false);
      _hideTimer?.cancel();
      _betterPlayerController!.pause();
    } else {
      cancelAndRestartTimer();

      if (!_controller!.value.initialized) {
      } else {
        if (isFinished) {
          _betterPlayerController!.seekTo(const Duration());
        }
        _betterPlayerController!.play();
        _betterPlayerController!.cancelNextVideoTimer();
      }
    }
  }

  void _startHideTimer() {
    if (_betterPlayerController!.controlsAlwaysVisible) {
      return;
    }
    _hideTimer = Timer(const Duration(milliseconds: 3000), () {
      changePlayerControlsNotVisible(true);
    });
  }

  void _updateState() {
    if (mounted) {
      if (!controlsNotVisible ||
          isVideoFinished(_controller!.value) ||
          _wasLoading ||
          isLoading(_controller!.value)) {
        setState(() {
          _latestValue = _controller!.value;
          if (isVideoFinished(_latestValue) &&
              _betterPlayerController?.isLiveStream() == false) {
            changePlayerControlsNotVisible(false);
          }
        });
      }
    }
  }

  Widget _buildProgressBar() {
    return Flexible(
      flex: 9999,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: BetterPlayerMaterialVideoProgressBar(
          _controller,
          _betterPlayerController,
          onDragStart: () {
            _hideTimer?.cancel();
          },
          onDragEnd: () {
            _startHideTimer();
          },
          onTapDown: () {
            cancelAndRestartTimer();
          },
          colors: BetterPlayerProgressColors(
              playedColor:
                  betterPlayerControlsConfiguration.progressBarPlayedColor,
              handleColor:
                  betterPlayerControlsConfiguration.progressBarHandleColor,
              bufferedColor:
                  betterPlayerControlsConfiguration.progressBarBufferedColor,
              backgroundColor:
                  betterPlayerControlsConfiguration.progressBarBackgroundColor),
        ),
      ),
    );
  }

  void _onBackClicked() {
    if (_betterPlayerController!.isFullScreen) {
      _onExpandCollapse();
    } else {
      _appState!.inDetailFavlistPage = false;
      if (_appState!.songsPlayer != null) {
        _appState!.songsPlayer!.play();
      }
      Navigator.pop(context);
    }
  }

  void _onPlayerHide() {
    _betterPlayerController!.toggleControlsVisibility(!controlsNotVisible);
    widget.onControlsVisibilityChanged(!controlsNotVisible);
  }

  Widget? _buildLoadingWidget() {
    if (betterPlayerControlsConfiguration.loadingWidget != null) {
      return Container(
        color: betterPlayerControlsConfiguration.controlBarColor,
        child: betterPlayerControlsConfiguration.loadingWidget,
      );
    }

    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(
          betterPlayerControlsConfiguration.loadingColor),
    );
  }
}
