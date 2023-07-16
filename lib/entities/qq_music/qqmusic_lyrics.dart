import 'package:flutter/foundation.dart';

/// Lyrics for qq music.
@immutable
class QQMusicLyrics {
  const QQMusicLyrics(
    this._lyric,
    this._trans,
  );

  /// Lyrics of song.
  final String _lyric;

  /// Translate of lyrics.
  final String _trans;

  factory QQMusicLyrics.fromJson(Map<String, dynamic> json) {
    return QQMusicLyrics(
      json['lyric'],
      json['trans'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'lyric': _lyric, 'trans': _trans};
  }

  @override
  String toString() {
    return 'Lyrics{lyric: $lyric, trans: $trans}';
  }

  String get lyric => _lyric;

  String get trans => _trans;
}
