library smart_player;

import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProgressBarPage extends StatefulWidget {
  final CachedVideoPlayerController controller;

  ///this variable is used to change text color of time.
  final Color? textColor;

  ///this variable is used to change progress selected bar color.
  final Color? selectedBarColor;

  ///this variable is used to change progress unSelect bar color.
  final Color? unSelectedBarColor;

  const ProgressBarPage(
      {Key? key,
      required this.controller,
      this.textColor,
      this.selectedBarColor,
      this.unSelectedBarColor})
      : super(key: key);

  @override
  ProgressBarPageState createState() => ProgressBarPageState();
}

class ProgressBarPageState extends State<ProgressBarPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setStateIfMounted();
    });
  }

  void setStateIfMounted() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(() {});
  }

  void seekToRelativePosition(Offset globalPosition) {
    final box = context.findRenderObject() as RenderBox;
    final Offset tapPos = box.globalToLocal(globalPosition);
    final double relative = tapPos.dx / box.size.width;
    final Duration position = widget.controller.value.duration * relative;
    widget.controller.seekTo(position);
  }

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
        '${hoursString.toLowerCase() == '00' ? '' : '$hoursString:'}$minutesString:$secondsString';
    return formattedTime;
  }

  bool isMute = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    bool mediaOrientation() {
      var orientation = MediaQuery.of(context).orientation;
      if (orientation == Orientation.landscape) {
        return true;
      } else {
        return false;
      }
    }

    return SafeArea(
      child: Container(
        color: Colors.black26,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.only(top: 7.0, left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                formatDuration(widget.controller.value.position),
                style: TextStyle(
                    color: widget.textColor ?? Colors.white70, fontSize: 16.0),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 30,
                width: mediaOrientation()
                    ? MediaQuery.of(context).size.width - 200
                    : MediaQuery.of(context).size.width - 150,
                child: GestureDetector(
                  child: CustomPaint(
                    painter: progressFiller(
                        controller: widget.controller,
                        selectedBarColor: widget.selectedBarColor,
                        unSelectedBarColor: widget.unSelectedBarColor),
                  ),
                  onHorizontalDragStart: (DragStartDetails details) {
                    if (!widget.controller.value.isInitialized) {
                      return;
                    }

                    if (widget.controller.value.isPlaying) {
                      widget.controller.pause();
                    }
                  },
                  onHorizontalDragUpdate: (DragUpdateDetails details) {
                    seekToRelativePosition(details.globalPosition);
                  },
                  onHorizontalDragEnd: (DragEndDetails details) {
                    widget.controller.play();
                  },
                  onTapDown: (TapDownDetails details) {
                    if (!widget.controller.value.isInitialized) {
                      return;
                    }
                    seekToRelativePosition(details.globalPosition);
                  },
                ),
              ),
              Text(
                formatDuration(widget.controller.value.duration),
                style: TextStyle(
                    color: widget.textColor ?? Colors.white70, fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: camel_case_types
class progressFiller extends CustomPainter {
  CachedVideoPlayerController controller;

  ///this variable is used to change progress bar color.
  final Color? selectedBarColor;

  ///this variable is used to change progress unSelect bar color.
  final Color? unSelectedBarColor;

  progressFiller(
      {required this.controller,
      this.selectedBarColor,
      this.unSelectedBarColor});

  @override
  void paint(Canvas canvas, Size size) {
    const height = 5.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(
              0.0,
              size.height /
                  2), //TO control the position of slider in the container
          Offset(
              size.width,
              size.height / 2 +
                  height), //TO control the position of slider in the container
        ),
        const Radius.circular(5.0), //To make end's of slider to be circular
      ),
      Paint()..color = unSelectedBarColor ?? Colors.white70,
    );
    final double partPlayed = controller.value.duration.inMilliseconds != 0
        ? controller.value.position.inMilliseconds /
            controller.value.duration.inMilliseconds
        : 0.0;
    final double playful =
        partPlayed > 1 ? size.width : partPlayed * size.width;
    canvas.drawRRect(
      //To fill the part played in the slider
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, size.height / 2),
          Offset(playful, size.height / 2 + height),
        ),
        const Radius.circular(5.0),
      ),
      Paint()..color = selectedBarColor ?? Colors.red,
    );

    canvas.drawCircle(
        Offset(playful, size.height / 2 + 2),
        10.0,
        Paint()
          ..color = selectedBarColor ??
              Colors.red); //circular head attached at the end of slider
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
