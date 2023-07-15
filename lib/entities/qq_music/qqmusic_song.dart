import 'package:flutter/foundation.dart';
import 'package:playlistmaster/entities/qq_music/qqmusic_singer.dart';

import '../basic/basic_song.dart';

/// Song for qq music.
@immutable
class QQMusicSong extends BasicSong {
  const QQMusicSong(
    this.songId,
    this.songMid,
    this.mediaMid, {
    required super.name,
    required super.singers,
    required super.cover,
    required super.payPlay,
    required super.isTakenDown,
    required super.songLink,
  });

  /// The song id.
  final String songId;

  /// The song mid.
  final String songMid;

  /// The media mid of the song.
  final String mediaMid;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'singers': singers,
      'cover': cover,
      'payPlay': payPlay,
      'isTakenDown': isTakenDown,
      'songLink': songLink,
      'songId': songId,
      'songMid': songMid,
      'mediaMid': mediaMid,
    };
  }

  factory QQMusicSong.fromJson(Map<String, dynamic> json) {
    List<dynamic> singersJson = json['singers'];
    List<QQMusicSinger> singers = singersJson
        .map<QQMusicSinger>((singer) => QQMusicSinger.fromJson(singer))
        .toList();
    return QQMusicSong(
      json['songId'],
      json['songMid'],
      json['mediaMid'],
      name: json['name'],
      singers: singers,
      cover: json['cover'],
      payPlay: json['payPlay'],
      isTakenDown: json['isTakenDown'],
      songLink: json['songLink'],
    );
  }
}
