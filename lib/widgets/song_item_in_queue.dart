import 'package:flutter/material.dart';

import '../entities/basic/basic_singer.dart';
import '../third_lib_change/music_visualizer.dart';

class SongItemInQueue extends StatefulWidget {
  final String name;
  final List<BasicSinger> singers;
  final String cover;
  final bool isPlaying;
  final void Function()? onClose;

  const SongItemInQueue({
    super.key,
    required this.name,
    required this.singers,
    required this.cover,
    required this.isPlaying,
    required this.onClose,
  });

  @override
  State<SongItemInQueue> createState() => _SongItemInQueueState();
}

class _SongItemInQueueState extends State<SongItemInQueue> {
  // final List<Color> _colors = [
  //   Color(0xFFD40000),
  // ];

  @override
  Widget build(BuildContext context) {
    // MyAppState appState = context.watch<MyAppState>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 40.0,
      child: Row(
        children: <Widget>[
          widget.isPlaying
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 12.0,
                    width: 12.0,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: MusicVisualizer(
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
                Flexible(
                  flex: 3,
                  child: Text(
                    widget.name,
                    style: textTheme.labelMedium!.copyWith(
                      fontSize: 15.0,
                      color: widget.isPlaying
                          ? Color(0xFFFF0000)
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
    );
  }
}
