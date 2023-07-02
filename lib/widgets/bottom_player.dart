import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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
  var _isPlaying = true;

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
    var isUsingMockData = appState.isUsingMockData;
    var currentPlayingSongInQueue = appState.currentPlayingSongInQueue;
    var queue = appState.queue;
    var currentSong = appState.currentSong;
    var isPlaying = appState.isPlaying;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPlaying == true && _isPlaying == false) {
        _controller.repeat();
        _isPlaying = true;
      } else if (isPlaying == false && _isPlaying == true) {
        _controller.stop();
        _isPlaying = false;
      }
    });
    return Container(
      height: 54.0,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.transparent.withOpacity(0.2),
            spreadRadius: 0.0,
            blurRadius: 4.0,
            offset: Offset(0.0, 0.0), // changes position of shadow
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: () {
            appState.isPlayerPageOpened = true;
            Navigator.pushNamed(context, '/song_player');
          },
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      child: isUsingMockData
                          ? Image.asset(
                              currentSong!.coverUri,
                              fit: BoxFit.fill,
                              // height: 230.0,
                              // width: 230.0,
                            )
                          : CachedNetworkImage(
                              imageUrl: currentSong!.coverUri.isNotEmpty
                                  ? currentSong.coverUri
                                  : MyAppState.defaultCoverImage,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      CircularProgressIndicator(
                                          value: downloadProgress.progress),
                              errorWidget: (context, url, error) =>
                                  Icon(MdiIcons.debian),
                            ),
                      // : Image(
                      //     image: CachedNetworkImageProvider(
                      //       currentSong!.coverUri.isNotEmpty
                      //           ? currentSong.coverUri
                      //           : MyAppState.defaultCoverImage,
                      //     ),
                      //   ),
                      // : Image.network(
                      //     currentSong!.coverUri.isNotEmpty
                      //         ? currentSong.coverUri
                      //         : MyAppState.defaultCoverImage,
                      //     fit: BoxFit.fill,
                      //   ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            currentSong.name,
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Color(0xB2000000),
                              letterSpacing: 0.25,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            ' - ${currentSong.singers[0].name}',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Color(0x42000000),
                              letterSpacing: 0.25,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: isPlaying
                      ? Icon(Icons.pause_circle_outline_rounded)
                      : Icon(Icons.play_circle_outline_rounded),
                  onPressed: () {
                    setState(() {
                      if (!isPlaying) {
                        _controller.repeat();
                        appState.player!.play();
                        appState.isPlaying = true;
                      } else {
                        _controller.stop();
                        appState.player!.pause();
                        appState.isPlaying = false;
                      }
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.queue_music_rounded),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ShowQueueDialog(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
