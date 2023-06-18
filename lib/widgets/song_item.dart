import 'package:flutter/material.dart';

import '../entities/song.dart';
import '../third_lib_change/music_visualizer.dart';

class SongItem extends StatefulWidget {
  final int index;
  final Song song;

  const SongItem({
    super.key,
    required this.index,
    required this.song,
  });

  @override
  State<SongItem> createState() => _SongItemState();
}

class _SongItemState extends State<SongItem> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: SizedBox(
              width: 40.0,
              height: 50.0,
              child: Center(
                child: Text(
                  (widget.index + 1).toString(),
                  style: TextStyle(
                    color: Color(0x4D000000),
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.song.name,
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
                Text(
                  widget.song.singers[0].name,
                  style: TextStyle(
                    fontSize: 10.0,
                    color: Color(0x42000000),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40.0,
            child: Row(children: [
              IconButton(
                  onPressed: () {},
                  color: Color(0x42000000),
                  icon: Icon(
                    Icons.favorite_outline_rounded,
                  )),
              IconButton(
                  onPressed: () {},
                  color: Color(0x42000000),
                  icon: Icon(
                    Icons.playlist_add_rounded,
                  )),
              IconButton(
                  onPressed: () {},
                  color: Color(0x42000000),
                  icon: Icon(
                    Icons.more_vert_rounded,
                  )),
            ]),
          ),
        ],
      ),
    );
  }
}
