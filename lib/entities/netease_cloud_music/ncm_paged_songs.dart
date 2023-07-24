import 'package:flutter/foundation.dart';

import '../basic/basic_paged_songs.dart';
import 'ncm_song.dart';

/// Paged songs for ncm.
@immutable
class NCMPagedSongs extends BasicPagedSongs {
  const NCMPagedSongs(this.songs,
      {required super.pageNo, required super.pageSize, required super.total});

  /// Paged searching result.
  final List<NCMSong> songs;

  factory NCMPagedSongs.fromJson(Map<String, dynamic> json) {
    List<dynamic> songsJson = json['songs'];
    List<NCMSong> songs =
        songsJson.map<NCMSong>((e) => NCMSong.fromJson(e)).toList();
    return NCMPagedSongs(
      songs,
      pageNo: json['pageNo'],
      pageSize: json['pageSize'],
      total: json['total'],
    );
  }

  @override
  String toString() {
    return 'NCMPagedSongs{songs: $songs, pageNo: $pageNo, pageSize: $pageSize, total: $total}';
  }
}
