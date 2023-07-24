import 'package:flutter/foundation.dart';

import '../basic/basic_lyrics.dart';

/// Lyrics for qq music.
@immutable
class QQMusicLyrics extends BasicLyrics {
  const QQMusicLyrics(this.trans, {required super.lyric});

  /// Translate of lyrics.
  final String trans;

  factory QQMusicLyrics.fromJson(Map<String, dynamic> json) {
    return QQMusicLyrics(
      json['trans'],
      lyric: json['lyric'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'lyric': lyric, 'trans': trans};
  }

  @override
  String toString() {
    return 'QQMusicLyrics{lyric: $lyric, trans: $trans}';
  }
}
