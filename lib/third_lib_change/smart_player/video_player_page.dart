library smart_player;

import 'dart:async';
import 'dart:math';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:playlistmaster/third_lib_change/smart_player/progress_bar.dart';
import 'full_screen_player_page.dart';

class SmartPlayer extends StatefulWidget {
  ///this url contains video url.
  final String url;

  ///this variable is used to show advertisement or not by default it is false.
  final bool? showAds;

  ///this variable is used to start video at specific point,
  ///initially video started at starting and convert length in seconds and send in this variable.
  final int? startedAt;

  ///this variable contains video url of advertisement before main video play.
  final String? adsUrl;

  ///this variable is use to hide controls by default it is true.
  final bool? showControls;

  ///this variable is use to change text color of time.
  final Color? textColor;

  ///this variable is use to change progress bar color.
  final Color? selectedBarColor;

  ///this variable is used to change progress unSelect bar color.
  final Color? unSelectedBarColor;

  ///this variable is used to change skip video text color.
  final Color? skipText;

  ///this variable is used to change icon color.
  final Color? iconColor;

  const SmartPlayer(
      {Key? key,
      required this.url,
      this.showAds,
      this.startedAt = 0,
      this.adsUrl = '',
      this.showControls = true,
      this.textColor,
      this.selectedBarColor,
      this.unSelectedBarColor,
      this.skipText,
      this.iconColor})
      : super(key: key);

  @override
  SmartPlayerState createState() => SmartPlayerState();
}

class SmartPlayerState extends State<SmartPlayer> {
  CachedVideoPlayerController? _controller;
  CachedVideoPlayerController? _adsController;
  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];
  bool isSkipped = false;
  bool showControls = true;
  bool isLocked = false;
  int totalLength = 0;
  String advertisementUrl = '';

  @override
  void initState() {
    super.initState();
    showControls = widget.showControls ?? true;
    advertisementUrl = widget.adsUrl?.trim() ?? '';
    _adsController = CachedVideoPlayerController.network(advertisementUrl
            .isNotEmpty
        ? advertisementUrl
        : 'https://cdn.download.ams.birds.cornell.edu/api/v1/asset/347497131/mp4/1280');
    _adsController?.initialize().then((_) => setState(() {}));
    _adsController?.play();
    _controller = CachedVideoPlayerController.network(widget.url);
    _controller?.initialize().then((_) => setState(() {
          String twoDigits(int n) => n.toString().padLeft(2, '0');
          int twoDigitMinutes = int.parse(
              twoDigits(_controller!.value.duration.inMinutes.remainder(60)));
          int twoDigitSeconds = int.parse(
              twoDigits(_controller!.value.duration.inSeconds.remainder(60)));
          var min = (twoDigitMinutes) * 60;
          totalLength = twoDigitSeconds + min;
          if (widget.startedAt != 0) {
            _controller?.seekTo(Duration(seconds: widget.startedAt ?? 0));
          }
          if (widget.showAds == false) {
            _controller?.play();
          }
        }));
  }

  @override
  Future<void> dispose() async {
    // timer();
    _controller?.dispose();
    _adsController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: InkWell(
        onTap: () {
          if (widget.showControls == false) {
            return;
          }
          if (!isLocked) {
            showControls = showControls == true ? false : true;
            setState(() {});
          }
        },
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.width * (9 / 16),
                  width: MediaQuery.of(context).size.width,
                  child: CachedVideoPlayer(
                      isSkipped == false && widget.showAds == true
                          ? _adsController!
                          : _controller!),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 6, right: 8.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: isLocked == false
                        ? PopupMenuButton<double>(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onSelected: (speed) {
                              _controller?.setPlaybackSpeed(speed);
                            },
                            itemBuilder: (context) {
                              return [
                                for (final speed in _examplePlaybackRates)
                                  PopupMenuItem(
                                    value: speed,
                                    child: Text(
                                      '${speed}x',
                                    ),
                                  )
                              ];
                            },
                            child: const Icon(
                              Icons.more_vert_rounded,
                              color: Colors.white,
                              size: 25.0,
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              isLocked = false;
                              showControls = true;
                              setState(() {});
                            },
                            child: const Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.white,
                              size: 25.0,
                            ),
                          ),
                  ),
                )
              ],
            ),
            isSkipped == false && widget.showAds == true
                ? InkWell(
                    onTap: () {
                      setState(() {
                        isSkipped = true;
                      });
                      _adsController?.dispose();
                      _controller?.play();
                    },
                    child: Container(
                      alignment: Alignment.bottomRight,
                      padding: const EdgeInsets.only(right: 10, bottom: 20),
                      child: Text('Skip ads',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: widget.skipText ?? Colors.white)),
                    ),
                  )
                : showControls == true
                    ? _controlsOverlay(_controller!)
                    : Container(),
            isSkipped == false && widget.showAds == true
                ? Container()
                : isLocked == false
                    ? ProgressBarPage(
                        controller: _controller!,
                        textColor: widget.textColor,
                        selectedBarColor: widget.selectedBarColor,
                        unSelectedBarColor: widget.unSelectedBarColor)
                    : Container(),
          ],
        ),
      ),
    );
  }

  _controlsOverlay(CachedVideoPlayerController controller) {
    return Container(
      color: Colors.black26,
      height: 80,
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: FittedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  onPressed: () {
                    // print(">>>>>>>>>>>>>>>");
                    // SimplePip().enterPipMode(
                    //   aspectRatio: [16, 9],
                    // );
                    // setState((){});
                    // SimplePip().enterPipMode();

                    showControls = false;
                    isLocked = true;
                    setState(() {});
                  },
                  minWidth: 20,
                  child: Icon(
                    Icons.lock_open_rounded,
                    color: widget.iconColor ?? Colors.white,
                    size: 20.0,
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    var position = await controller.position;
                    controller
                        .seekTo(Duration(seconds: position!.inSeconds - 5));
                    setState(() {});
                  },
                  minWidth: 20,
                  child: Icon(
                    Icons.replay_5_rounded,
                    color: widget.iconColor ?? Colors.white,
                    size: 20.0,
                  ),
                ),
                controller.value.isPlaying
                    ? MaterialButton(
                        minWidth: 20,
                        onPressed: () {
                          controller.value.isPlaying
                              ? controller.pause()
                              : controller.play();
                          setState(() {});
                        },
                        child: Icon(
                          Icons.pause_rounded,
                          color: widget.iconColor ?? Colors.white,
                          size: 30.0,
                        ),
                      )
                    : MaterialButton(
                        minWidth: 20,
                        onPressed: () {
                          controller.value.isPlaying
                              ? controller.pause()
                              : controller.play();
                          setState(() {});
                        },
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: widget.iconColor ?? Colors.white,
                          size: 30.0,
                        ),
                      ),
                const SizedBox(
                  width: 10,
                ),
                MaterialButton(
                  onPressed: () async {
                    var position = await controller.position;
                    controller
                        .seekTo(Duration(seconds: position!.inSeconds + 5));
                    setState(() {});
                  },
                  minWidth: 20,
                  child: Icon(
                    Icons.forward_5_rounded,
                    color: widget.iconColor ?? Colors.white,
                    size: 20.0,
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    // var sec = await timer();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => FullScreenPlayerPage(
                                  // duration: sec,
                                  controller: _controller!,
                                  selectedBarColor: widget.selectedBarColor,
                                  unSelectedBarColor: widget.unSelectedBarColor,
                                  textColor: widget.textColor,
                                  iconColor: widget.iconColor,
                                ))).then((value) => {
                          _controller = value,
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.portraitDown,
                            DeviceOrientation.portraitUp
                          ]),
                        });
                  },
                  minWidth: 20,
                  child: Icon(
                    Icons.fullscreen_rounded,
                    color: widget.iconColor ?? Colors.white,
                    size: 20.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // timer() async {
  //   Duration? duration = await _controller?.position;
  //   String twoDigits(int n) => n.toString().padLeft(2, "0");
  //   int twoDigitMinutes =
  //       int.parse(twoDigits(duration!.inMinutes.remainder(60)));
  //   int twoDigitSeconds =
  //       int.parse(twoDigits(duration.inSeconds.remainder(60)));
  //   var min = (twoDigitMinutes) * 60;
  //   // var sec = twoDigitSeconds + min;
  // }

  String formatDuration(Duration position) {
    final ms = position.inMilliseconds;
    int seconds = ms ~/ 1000;
    final int hours = seconds ~/ 3600;
    seconds = seconds % 3600;
    var minutes = seconds ~/ 60;
    seconds = seconds % 60;
    final hoursString = hours >= 10
        ? '$hours'
        : hours == 0
            ? '00'
            : '0$hours';
    final minutesString = minutes >= 10
        ? '$minutes'
        : minutes == 0
            ? '00'
            : '0$minutes';
    final secondsString = seconds >= 10
        ? '$seconds'
        : seconds == 0
            ? '00'
            : '0$seconds';
    final formattedTime =
        '${hoursString == '00' ? '' : '$hoursString:'}$minutesString:$secondsString';
    return formattedTime;
  }

  getRandomTimer() {
    int ads = 3;
    List<int> time = [];
    Random random = Random();
    for (int i = 0; i < ads; i++) {
      int randomNumber = random.nextInt(100);
      time.add(randomNumber);
    }
  }
}
