import 'package:flutter/material.dart';

import '../third_lib_change/music_visualizer.dart';

class ResourceItemInQueue extends StatefulWidget {
  final String name;
  final String singers;
  final String cover;
  final bool isPlaying;
  final void Function()? onClose;

  const ResourceItemInQueue({
    super.key,
    required this.name,
    required this.singers,
    required this.cover,
    required this.isPlaying,
    required this.onClose,
  });

  @override
  State<ResourceItemInQueue> createState() => _ResourceItemInQueueState();
}

class _ResourceItemInQueueState extends State<ResourceItemInQueue> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // MyAppState appState = context.watch<MyAppState>();
    return SizedBox(
      height: 40.0,
      child: Row(
        children: <Widget>[
          widget.isPlaying
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 5.0, right: 5.0),
                  child: SizedBox(
                    height: 20.0,
                    width: 20.0,
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
                        ' · ${widget.singers}',
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
