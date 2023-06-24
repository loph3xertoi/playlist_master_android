import 'package:flutter/material.dart';
import 'package:playlistmaster/entities/singer.dart';
import 'package:playlistmaster/third_lib_change/music_visualizer.dart';

class SongItemInQueue extends StatefulWidget {
  final String name;
  final List<Singer> singers;
  final String coverUri;
  final bool isPlaying;
  final void Function()? onClose;

  const SongItemInQueue({
    super.key,
    required this.name,
    required this.singers,
    required this.coverUri,
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
          Text(
            widget.name,
            style: TextStyle(
              fontSize: 15.0,
              color: widget.isPlaying ? Color(0xFFFF0000) : Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              '·${widget.singers[0].name}',
              style: TextStyle(
                fontSize: 10.0,
                color: widget.isPlaying ? Color(0xFFFF0000) : Color(0x42000000),
              ),
            ),
          ),
          IconButton(
            color: Color(0x42000000),
            icon: Icon(Icons.close_rounded),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }
}
