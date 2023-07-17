import 'package:flutter/foundation.dart';

import '../basic/basic_library.dart';

/// Playlist for qq music.
@immutable
class QQMusicPlaylist extends BasicLibrary {
  const QQMusicPlaylist(
    this.dirId,
    this.tid, {
    required super.name,
    required super.cover,
    required super.itemCount,
  });

  /// The dirId(local id) of this playlist.
  final int dirId;

  /// The tid(global id) of this playlist.
  final String tid;

  factory QQMusicPlaylist.fromJson(Map<String, dynamic> json) {
    return QQMusicPlaylist(
      json['dirId'],
      json['tid'],
      name: json['name'],
      cover: json['cover'],
      itemCount: json['itemCount'],
    );
  }

  @override
  String toString() {
    return 'QQMusicPlaylist{dirId: $dirId, tid: $tid, name: $name, cover: $cover, itemCount: $itemCount}';
  }
}
