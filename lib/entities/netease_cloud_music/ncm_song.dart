import 'package:flutter/foundation.dart';

import '../basic/basic_song.dart';
import 'ncm_singer.dart';

/// Song for ncm.
@immutable
class NCMSong extends BasicSong {
  const NCMSong(
    this.id,
    this.mvId, {
    required super.name,
    required super.singers,
    required super.cover,
    required super.payPlay,
    required super.isTakenDown,
    required super.songLink,
  });

  /// The song's id.
  final int id;

  /// The MV's id of this song.
  final int mvId;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'singers': singers,
      'cover': cover,
      'payPlay': payPlay,
      'isTakenDown': isTakenDown,
      'songLink': songLink,
      'id': id,
      'mvId': mvId
    };
  }

  factory NCMSong.fromJson(Map<String, dynamic> json) {
    List<dynamic> singersJson = json['singers'];
    List<NCMSinger> singers = singersJson
        .map<NCMSinger>((singer) => NCMSinger.fromJson(singer))
        .toList();
    return NCMSong(
      json['id'],
      json['mvId'],
      name: json['name'],
      singers: singers,
      cover: json['cover'],
      payPlay: json['payPlay'],
      isTakenDown: json['isTakenDown'],
      songLink: json['songLink'],
    );
  }

  @override
  String toString() {
    return 'NCMSong{id: $id, mvId: $mvId, name: $name, singers: $singers, cover: $cover, payPlay: $payPlay, isTakenDown: $isTakenDown, songLink: $songLink}';
  }
}
