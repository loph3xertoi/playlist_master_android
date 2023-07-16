import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';

class MyLyricsReader extends LyricsReader {
  @override
  State<StatefulWidget> createState() => MyLyricReaderState();

  MyLyricsReader({
    super.position = 0,
    super.model,
    super.padding,
    super.size,
    super.selectLineBuilder,
    super.lyricUi,
    super.onTap,
    super.playing,
    super.emptyBuilder,
  });
}

class MyLyricReaderState extends LyricReaderState {
  @override
  void scrollToPlayLine([bool animation = true]) {}
}
