import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';

class MyLyricsDisplayer extends LyricUI {
  double defaultSize;
  double defaultExtSize;
  double otherMainSize;
  double bias;
  double lineGap;
  double inlineGap;
  LyricAlign lyricAlign;
  LyricBaseLine lyricBaseLine;
  bool highlight;
  HighlightDirection highlightDirection;
  TextTheme? textTheme;

  MyLyricsDisplayer({
    this.defaultSize = 18,
    this.defaultExtSize = 14,
    this.otherMainSize = 16,
    this.bias = 0.5,
    this.lineGap = 25,
    this.inlineGap = 25,
    this.lyricAlign = LyricAlign.CENTER,
    this.lyricBaseLine = LyricBaseLine.CENTER,
    this.highlight = true,
    this.highlightDirection = HighlightDirection.LTR,
    this.textTheme,
  });

  MyLyricsDisplayer.clone(MyLyricsDisplayer myLyricsDisplayer)
      : this(
          defaultSize: myLyricsDisplayer.defaultSize,
          defaultExtSize: myLyricsDisplayer.defaultExtSize,
          otherMainSize: myLyricsDisplayer.otherMainSize,
          bias: myLyricsDisplayer.bias,
          lineGap: myLyricsDisplayer.lineGap,
          inlineGap: myLyricsDisplayer.inlineGap,
          lyricAlign: myLyricsDisplayer.lyricAlign,
          lyricBaseLine: myLyricsDisplayer.lyricBaseLine,
          highlight: myLyricsDisplayer.highlight,
          highlightDirection: myLyricsDisplayer.highlightDirection,
        );

  @override
  TextStyle getPlayingExtTextStyle() => textTheme == null
      ? TextStyle(
          color: Colors.grey[300],
          fontSize: defaultExtSize,
          fontFamily: 'Roboto',
        )
      : textTheme!.labelSmall!.copyWith(
          fontSize: defaultExtSize,
        );

  @override
  TextStyle getOtherExtTextStyle() => textTheme == null
      ? TextStyle(
          color: Colors.grey[300],
          fontSize: defaultExtSize,
          fontFamily: 'Roboto',
        )
      : textTheme!.labelSmall!.copyWith(
          fontSize: defaultExtSize,
        );

  @override
  TextStyle getOtherMainTextStyle() => textTheme == null
      ? TextStyle(
          color: Colors.grey[200],
          fontSize: otherMainSize,
          fontFamily: 'Roboto',
        )
      : textTheme!.labelMedium!.copyWith(
          fontSize: defaultSize,
        );

  @override
  TextStyle getPlayingMainTextStyle() => textTheme == null
      ? TextStyle(
          color: Colors.white,
          fontSize: defaultSize,
          fontFamily: 'Roboto',
        )
      : textTheme!.labelMedium!.copyWith(
          fontSize: defaultSize,
        );

  @override
  double getInlineSpace() => inlineGap;

  @override
  double getLineSpace() => lineGap;

  @override
  double getPlayingLineBias() => bias;

  @override
  LyricAlign getLyricHorizontalAlign() => lyricAlign;

  @override
  LyricBaseLine getBiasBaseLine() => lyricBaseLine;

  @override
  bool enableHighlight() => highlight;

  @override
  HighlightDirection getHighlightDirection() => highlightDirection;
}
