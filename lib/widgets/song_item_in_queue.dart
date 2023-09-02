import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_singer.dart';
import '../states/app_state.dart';
import '../third_lib_change/music_visualizer.dart';

class SongItemInQueue extends StatefulWidget {
  final String name;
  final int payPlayType;
  final List<BasicSinger> singers;
  final String cover;
  final bool isPlaying;
  final int? songType;
  final void Function()? onClose;

  const SongItemInQueue({
    super.key,
    required this.name,
    required this.payPlayType,
    required this.singers,
    required this.cover,
    required this.isPlaying,
    this.songType,
    required this.onClose,
  });

  @override
  State<SongItemInQueue> createState() => _SongItemInQueueState();
}

class _SongItemInQueueState extends State<SongItemInQueue> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    var currentPlatform = appState.currentPlatform;
    return Container(
      margin: EdgeInsets.only(right: 12.0),
      child: SizedBox(
        height: 40.0,
        child: Row(
          children: <Widget>[
            if (currentPlatform == 0)
              Container(
                margin: EdgeInsets.only(left: 3.0, right: 19.0),
                width: 3.0,
                height: 50.0,
                color: _getColorForSongType(widget.songType),
              )
            else
              SizedBox(
                width: 25.0,
                height: 50.0,
              ),
            widget.isPlaying
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 5.0, right: 5.0),
                    child: SizedBox(
                      height: 20.0,
                      width: 20.0,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: currentPlatform == 2
                            ? Image.asset(
                                'assets/images/song_playing_state.webp',
                                color: Color.fromARGB(255, 187, 0, 0),
                              )
                            : MusicVisualizer(
                                barCount: 3,
                                duration: 400,
                                color: Color(0xFFD40000),
                              ),
                      ),
                    ),
                  )
                : Container(),
            Expanded(
              child: Row(
                children: [
                  (currentPlatform == 2 && widget.payPlayType == 1)
                      ? Padding(
                          padding: const EdgeInsets.only(right: 3.0),
                          child: Image.asset(
                            'assets/images/vip_item_ncm.png',
                            width: 20.0,
                          ),
                        )
                      : Container(),
                  Flexible(
                    flex: 3,
                    child: Text(
                      widget.name,
                      style: textTheme.labelMedium!.copyWith(
                        fontSize: 15.0,
                        color: widget.isPlaying
                            ? Color.fromARGB(255, 187, 0, 0)
                            : colorScheme.onSecondary,
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
                          ' · ${widget.singers.map((e) => e.name).join(', ')}',
                          style: textTheme.labelMedium!.copyWith(
                            fontSize: 10.0,
                            color: widget.isPlaying
                                ? Color(0xFFFF0000)
                                : colorScheme.tertiary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              color: colorScheme.onPrimary,
              icon: Icon(Icons.close_rounded),
              onPressed: widget.onClose,
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForSongType(int? songType) {
    Color songColor;
    if (songType == null || songType == 0) {
      songColor = Colors.transparent;
    } else if (songType == 1) {
      songColor = Color(0xFF13BE72);
    } else if (songType == 2) {
      songColor = Color(0xFFDF0000);
    } else if (songType == 3) {
      songColor = Color(0xFFFF558A);
    } else {
      throw 'Invalid song type';
    }
    return songColor;
  }
}
