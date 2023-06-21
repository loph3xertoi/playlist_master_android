import 'dart:math';

import 'package:flutter/material.dart';
import 'package:playlistmaster/mock_data.dart';
import 'package:playlistmaster/states/app_state.dart';
import 'package:playlistmaster/widgets/create_queue_popup.dart';
import 'package:provider/provider.dart';

class BottomPlayer extends StatefulWidget {
  @override
  State<BottomPlayer> createState() => _BottomPlayerState();
}

class _BottomPlayerState extends State<BottomPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _songCoverRotateAnimation;
  bool _isPlaying = true;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    );
    _songCoverRotateAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    return Container(
      height: 54.0,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.transparent.withOpacity(0.2),
            spreadRadius: 0.0,
            blurRadius: 4.0,
            offset: Offset(0.0, 0.0), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(10.0, 2.0, 8.0, 2.0),
        child: Row(
          children: [
            // AnimatedRotation(
            //   turns: 5,
            //   duration: Duration(seconds: 100),
            //   child: SizedBox(
            //     height: 50.0,
            //     width: 50.0,
            //     child: Image.asset(
            //       'assets/images/songs_cover/tit.png',
            //       fit: BoxFit.fill,
            //     ),
            //   ),
            // ),
            AnimatedBuilder(
              animation: _songCoverRotateAnimation,
              builder: (BuildContext context, Widget? child) {
                return Transform.rotate(
                  angle: _songCoverRotateAnimation.value * 2 * pi,
                  child: child,
                );
              },
              child: SizedBox(
                height: 50.0,
                width: 50.0,
                child: Image.asset(
                  'assets/images/songs_cover/tit.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    'Tit',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Color(0xB2000000),
                      letterSpacing: 0.25,
                    ),
                  ),
                  Text(
                    ' - Little Tit',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Color(0x42000000),
                      letterSpacing: 0.25,
                    ),
                  ),
                ]),
              ),
            ),
            IconButton(
              icon: _isPlaying
                  ? Icon(Icons.pause_circle_outline_rounded)
                  : Icon(Icons.play_circle_outline_rounded),
              onPressed: () {
                setState(() {
                  if (!_isPlaying) {
                    _controller.repeat();
                  } else {
                    _controller.stop();
                  }
                  _isPlaying = !_isPlaying;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.queue_music_rounded),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) => ShowQueueDialog(
                          songsQueue: MockData.songs,
                        ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
