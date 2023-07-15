import 'package:flutter/foundation.dart';

/// Lyrics for qq music.
@immutable
class QQMusicLyrics {
  const QQMusicLyrics(
    this.lyric,
    this.trans,
  );

  /// Lyrics of song.
  final String lyric;

  /// Translate of lyrics.
  final String trans;

  factory QQMusicLyrics.fromJson(Map<String, dynamic> json) {
    return QQMusicLyrics(
      json['lyric'],
      json['trans'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'lyric': lyric, 'trans': trans};
  }
}
