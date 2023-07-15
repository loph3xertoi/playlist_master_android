import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../basic/basic_library.dart';
import 'qqmusic_song.dart';

/// Detail playlist of qq music.
@immutable
class QQMusicDetailPlaylist extends BasicLibrary {
  const QQMusicDetailPlaylist(
    this.listenNum,
    this.dirId,
    this.tid,
    this.songs, {
    required super.name,
    required super.cover,
    required super.itemCount,
    this.desc = 'A description for your library.',
  });

  /// The description of your playlist.
  final String desc;

  /// Listen times of this playlist.
  final int listenNum;

  /// The dirId(local dawid) of this playlist.
  final int dirId;

  /// The tid(global id) of this playlist.
  final String tid;

  /// All basic songs in this playlist.
  final List<QQMusicSong> songs;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cover': cover,
      'itemCount': itemCount,
      'desc': desc,
      'listenNum': listenNum,
      'dirId': dirId,
      'tid': tid,
      'songs': songs.map((song) => song.toJson()).toList(),
    };
  }

  factory QQMusicDetailPlaylist.fromJson(Map<String, dynamic> json) {
    List<dynamic> songsJson = json['songs'];
    List<QQMusicSong> songs =
        songsJson.map<QQMusicSong>((e) => QQMusicSong.fromJson(e)).toList();
    return QQMusicDetailPlaylist(
      json['listenNum'],
      json['dirId'],
      json['tid'],
      songs,
      name: json['name'],
      cover: json['cover'],
      itemCount: json['itemCount'],
      desc: json['desc'],
    );
  }
}
