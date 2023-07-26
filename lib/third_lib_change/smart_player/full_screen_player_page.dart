library smart_player;

import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:playlistmaster/third_lib_change/smart_player/progress_bar.dart';

class FullScreenPlayerPage extends StatefulWidget {
  final CachedVideoPlayerController controller;

  ///this variable is use to change text color of time.
  final Color? textColor;

  ///this variable is use to change progress bar color.
  final Color? selectedBarColor;

  ///this variable is used to change progress unSelect bar color.
  final Color? unSelectedBarColor;

  ///this variable is used to change icon color.
  final Color? iconColor;

  const FullScreenPlayerPage(
      {Key? key,
      required this.controller,
      this.textColor,
      this.selectedBarColor,
      this.unSelectedBarColor,
      this.iconColor})
      : super(key: key);

  @override
  State<FullScreenPlayerPage> createState() => _FullScreenPlayerPageState();
}

class _FullScreenPlayerPageState extends State<FullScreenPlayerPage> {
  bool showControls = true;
  bool isLocked = false;
  int aspectIndex = 0;
  late VlcPlayerController _vlcController;

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

  List aspectRatioList = [
    16 / 9,
    1 / 1,
    4 / 3,
    16 / 10,
    21 / 9,
    64 / 27,
    2.21 / 1,
    2.39 / 1,
    5 / 4
  ];

  @override
  void initState() {
    super.initState();
    _vlcController = VlcPlayerController.network(
      widget.controller.dataSource,
    );
    //_vlcController.initialize().then((value) {});
    _vlcController.addListener(listener);
    _vlcController.addOnInitListener(() async {
      await _vlcController.startRendererScanning();
    });
    _vlcController.addOnRendererEventListener((type, id, name) {});
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  void listener() async {
    if (!mounted) return;
    // if (_vlcController.value.isInitialized) {
    //   var oPosition = _vlcController.value.position;
    //   var oDuration = _vlcController.value.duration;
    //   if (oPosition != null && oDuration != null) {}
    //   setState(() {});
    // }
  }

  @override
  void dispose() {
    _vlcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
        color: Colors.black,
        child: GestureDetector(
          onTap: () {
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
                  Center(
                    child: AspectRatio(
                        aspectRatio: aspectRatioList[aspectIndex],
                        child: CachedVideoPlayer(widget.controller)),
                  ),
                  Opacity(
                    opacity: 1,
                    child: Container(
                      color: Colors.transparent,
                      height: 1,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: <Widget>[
                          Center(
                            child: VlcPlayer(
                              virtualDisplay: true,
                              controller: _vlcController,
                              aspectRatio: 16 / 19,
                              placeholder: const Center(
                                  child: CircularProgressIndicator()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 34, left: 8.0, right: 8, bottom: 8),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: isLocked == false
                          ? PopupMenuButton<double>(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onSelected: (speed) {
                                widget.controller.setPlaybackSpeed(speed);
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
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Icon(
                                  Icons.more_vert_rounded,
                                  color: Colors.white,
                                  size: 25.0,
                                ),
                              ),
                            )
                          : InkWell(
                              onTap: () {
                                isLocked = false;
                                showControls = true;
                                setState(() {});
                              },
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 10),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context, widget.controller);
                      },
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 22.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  showControls == true
                      ? customControls(widget.controller)
                      : Container(),
                  isLocked == false
                      ? ProgressBarPage(
                          controller: widget.controller,
                          unSelectedBarColor: widget.unSelectedBarColor,
                          textColor: widget.textColor,
                          selectedBarColor: widget.selectedBarColor,
                        )
                      : Container(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  customControls(CachedVideoPlayerController controller) {
    return Column(
      children: [
        FittedBox(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                color: Colors.black26,
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 50),
                    reverseDuration: const Duration(milliseconds: 200),
                    child: Row(
                      children: [
                        MaterialButton(
                          onPressed: () {
                            showControls = false;
                            isLocked = true;
                            setState(() {});
                          },
                          minWidth: 20,
                          child: Icon(
                            Icons.lock_outline_rounded,
                            color: widget.iconColor ?? Colors.white,
                            size: 20.0,
                          ),
                        ),
                        MaterialButton(
                          onPressed: () {
                            _getRendererDevices();
                          },
                          minWidth: 20,
                          child: Icon(
                            Icons.cast_rounded,
                            color: widget.iconColor ?? Colors.white,
                            size: 20.0,
                          ),
                        ),
                        MaterialButton(
                          onPressed: () {
                            if (aspectIndex != 8) {
                              aspectIndex++;
                            } else {
                              aspectIndex = 0;
                            }
                            setState(() {});
                          },
                          minWidth: 20,
                          child: Icon(
                            Icons.aspect_ratio_rounded,
                            color: widget.iconColor ?? Colors.white,
                            size: 20.0,
                          ),
                        ),
                        MaterialButton(
                          onPressed: () async {
                            var position = await controller.position;
                            controller.seekTo(
                                Duration(seconds: position!.inSeconds - 5));
                            // SimplePip().enterPipMode(
                            //   aspectRatio: [16, 9],
                            // );
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
                        MaterialButton(
                          onPressed: () async {
                            var position = await controller.position;

                            controller.seekTo(
                                Duration(seconds: position!.inSeconds + 5));
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
                            Navigator.pop(context, widget.controller);
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
            ],
          ),
        ),
      ],
    );
  }

  timer() async {
    Duration? duration = await widget.controller.position;
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    int twoDigitMinutes =
        int.parse(twoDigits(duration!.inMinutes.remainder(60)));
    int twoDigitSeconds =
        int.parse(twoDigits(duration.inSeconds.remainder(60)));
    var min = (twoDigitMinutes) * 60;
    var sec = twoDigitSeconds + min;
    return sec;
  }

  void _getRendererDevices() async {
    var castDevices = await _vlcController.getRendererDevices();
    if (castDevices.isNotEmpty && mounted) {
      var selectedCastDeviceName = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Display Devices'),
            content: SizedBox(
              width: double.maxFinite,
              height: 250,
              child: ListView.builder(
                itemCount: castDevices.keys.length /*+ 1*/,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      castDevices.values.elementAt(index).toString(),
                    ),
                    onTap: () {
                      Navigator.pop(context, castDevices.keys.elementAt(index));
                    },
                  );
                },
              ),
            ),
          );
        },
      );
      await _vlcController.castToRenderer(selectedCastDeviceName ?? "");
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No Display Device Found!')));
      }
    }
  }
}
