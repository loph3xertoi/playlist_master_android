import 'package:flutter/foundation.dart';

import '../basic/basic_paged_songs.dart';
import 'qqmusic_song.dart';

/// Paged songs for qq music.
@immutable
class QQMusicPagedSongs extends BasicPagedSongs {
  const QQMusicPagedSongs(this.songs,
      {required super.pageNo, required super.pageSize, required super.total});

  /// Paged searching result.
  final List<QQMusicSong> songs;

  factory QQMusicPagedSongs.fromJson(Map<String, dynamic> json) {
    List<dynamic> songsJson = json['songs'];
    List<QQMusicSong> songs =
        songsJson.map<QQMusicSong>((e) => QQMusicSong.fromJson(e)).toList();
    return QQMusicPagedSongs(
      songs,
      pageNo: json['pageNo'],
      pageSize: json['pageSize'],
      total: json['total'],
    );
  }
}
