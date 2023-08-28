import 'package:flutter/foundation.dart';

import '../basic/basic_song.dart';
import 'pms_singer.dart';

/// Song for pms.
@immutable
class PMSSong extends BasicSong {
  const PMSSong(
    this.id,
    this.type, {
    required super.name,
    required super.singers,
    required super.cover,
    required super.payPlay,
    required super.isTakenDown,
    super.songLink,
  });

  /// The id of pms song.
  final int id;

  /// The type of this song, 1 for qqmusic, 2 for ncm, 3 for bilibili.
  final int type;

  factory PMSSong.fromJson(Map<String, dynamic> json) {
    List<dynamic> singersJson = json['singers'];
    List<PMSSinger> singers = singersJson
        .map<PMSSinger>((singer) => PMSSinger.fromJson(singer))
        .toList();
    return PMSSong(
      json['id'],
      json['type'],
      name: json['name'],
      singers: singers,
      cover: json['cover'],
      payPlay: json['payPlay'],
      isTakenDown: json['isTakenDown'],
    );
  }

  @override
  String toString() {
    return 'PMSSong{id: $id, type: $type, name: $name, singers: $singers, cover: $cover, payPlay: $payPlay, isTakenDown: $isTakenDown}';
  }
}
