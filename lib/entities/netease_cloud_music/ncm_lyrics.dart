import 'package:flutter/foundation.dart';

import '../basic/basic_lyrics.dart';

/// Lyrics for ncm.
@immutable
class NCMLyrics extends BasicLyrics {
  const NCMLyrics(this.kLyric, this.tLyric, this.romaLrc, this.yrc, this.ytLrc,
      {required super.lyric});

  /// Pin yin format.
  final String kLyric;

  /// Translate to chinese.
  final String tLyric;

  /// Roma format.
  final String romaLrc;

  /// Per-character format.
  final String yrc;

  /// Per-character format translated to chinese.
  final String ytLrc;

  factory NCMLyrics.fromJson(Map<String, dynamic> json) {
    return NCMLyrics(
      json["klyric"],
      json["tlyric"],
      json["romaLrc"],
      json["yrc"],
      json["ytLrc"],
      lyric: json["lyric"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lyric': lyric,
      'klyric': kLyric,
      'tlyric': tLyric,
      'romaLrc': romaLrc,
      'yrc': yrc,
      'ytLrc': ytLrc
    };
  }

  @override
  String toString() {
    return 'NCMLyrics{lrc: $lyric, kLyric: $kLyric, tLyric: $tLyric, romaLrc: $romaLrc, yrc: $yrc, ytLrc: $ytLrc}';
  }
}
