import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../entities/bilibili/bili_resource.dart';
import '../states/app_state.dart';
import 'queue_popup.dart';

class BottomPlayer extends StatefulWidget {
  @override
  State<BottomPlayer> createState() => _BottomPlayerState();
}

class _BottomPlayerState extends State<BottomPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _songCoverRotateAnimation;
  MyAppState? _appState;
  late bool _isPlaying;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    var currentPlatform = state.currentPlatform;
    _isPlaying =
        currentPlatform == 3 ? state.isResourcePlaying : state.isSongPlaying;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    );
    _songCoverRotateAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('build bottom player');
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    var currentPlatform = appState.currentPlatform;
    var isUsingMockData = appState.isUsingMockData;
    var currentSong = appState.currentSong;
    var currentResource = appState.currentResource;
    var isSongPlaying = appState.isSongPlaying;
    var isResourcePlaying = appState.isResourcePlaying;
    _isPlaying = currentPlatform == 3 ? isResourcePlaying : isSongPlaying;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
      // if (currentPlatform == 3) {
      //   if (isResourcePlaying == true && _isPlaying == false) {
      //     _controller.repeat();
      //     _isPlaying = true;
      //   } else if (isResourcePlaying == false && _isPlaying == true) {
      //     _controller.stop();
      //     setState(() {
      //       _isPlaying = false;
      //     });
      //   }
      // } else {
      //   if (isSongPlaying == true && _isPlaying == false) {
      //     _controller.repeat();
      //     setState(() {
      //       _isPlaying = true;
      //     });
      //   } else if (isSongPlaying == false && _isPlaying == true) {
      //     _controller.stop();
      //     setState(() {
      //       _isPlaying = false;
      //     });
      //   }
      // }
    });
    return Material(
      child: InkWell(
        onTap: () {
          // appState.isSongsPlayerPageOpened = true;
          if (currentPlatform == 3) {
            // appState.canResourcesPlayerPagePop = true;
            Navigator.pushNamed(context, '/detail_resource_page');
            // Navigator.pushNamed(context, '/resources_player_page');
          } else {
            appState.canSongsPlayerPagePop = true;
            Navigator.pushNamed(context, '/songs_player_page');
          }
        },
        child: Ink(
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
          child: Padding(
            padding: EdgeInsets.fromLTRB(10.0, 2.0, 8.0, 2.0),
            child: Row(
              children: [
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
                              currentPlatform == 3
                                  ? currentResource!.cover
                                  : currentSong!.cover,
                              fit: BoxFit.fill,
                            )
                          : CachedNetworkImage(
                              imageUrl: currentPlatform == 3
                                  ? currentResource?.cover.isNotEmpty ?? false
                                      ? currentResource!.cover
                                      : MyAppState.defaultCoverImage
                                  : currentSong?.cover.isNotEmpty ?? false
                                      ? currentSong!.cover
                                      : MyAppState.defaultCoverImage,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      CircularProgressIndicator(
                                          value: downloadProgress.progress),
                              errorWidget: (context, url, error) =>
                                  Icon(MdiIcons.debian),
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 3,
                          child: Text(
                            currentPlatform == 3
                                ? '${currentResource?.title}'
                                : '${currentSong?.name}',
                            style: textTheme.labelMedium!.copyWith(
                              fontSize: 15.0,
                              color: colorScheme.onSecondary,
                              textBaseline: TextBaseline.alphabetic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Text(
                                currentPlatform == 3
                                    ? ' · ${currentResource?.upperName}'
                                    : ' · ${currentSong?.singers.map((e) => e.name).join(', ')}',
                                style: textTheme.labelMedium!.copyWith(
                                  fontSize: 11.0,
                                  color: colorScheme.onSecondary,
                                  textBaseline: TextBaseline.alphabetic,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  color: colorScheme.tertiary,
                  icon: _isPlaying
                      ? Icon(Icons.pause_circle_outline_rounded)
                      : Icon(Icons.play_circle_outline_rounded),
                  onPressed: () {
                    setState(() {
                      if (currentPlatform == 3) {
                        if (!_isPlaying) {
                          _controller.repeat();
                          appState.resourcesPlayer!.play();
                          appState.isResourcePlaying = true;
                        } else {
                          _controller.stop();
                          appState.resourcesPlayer!.pause();
                          appState.isResourcePlaying = false;
                        }
                      } else {
                        if (!_isPlaying) {
                          _controller.repeat();
                          appState.songsPlayer!.play();
                          appState.isSongPlaying = true;
                        } else {
                          _controller.stop();
                          appState.songsPlayer!.pause();
                          appState.isSongPlaying = false;
                        }
                      }
                    });
                  },
                ),
                IconButton(
                  color: colorScheme.tertiary,
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
