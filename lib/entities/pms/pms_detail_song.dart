import 'package:flutter/foundation.dart';

import '../basic/basic_song.dart';
import '../bilibili/bili_resource.dart';
import '../netease_cloud_music/ncm_song.dart';
import '../qq_music/qqmusic_song.dart';
import 'pms_singer.dart';

/// Detail pms song.
@immutable
class PMSDetailSong extends BasicSong {
  const PMSDetailSong(
    this.id,
    this.type,
    this.basicSong,
    this.biliResource, {
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

  /// Original QQMusic song or NCM song.
  final BasicSong? basicSong;

  /// Original BiliBili resources.
  final BiliResource? biliResource;

  factory PMSDetailSong.fromJson(Map<String, dynamic> json) {
    int type = json['type'];
    List<dynamic> singersJson = json['singers'];
    List<PMSSinger> singers = singersJson
        .map<PMSSinger>((singer) => PMSSinger.fromJson(singer))
        .toList();
    BasicSong? basicSong;
    BiliResource? biliResource;
    if (type == 1) {
      basicSong = QQMusicSong.fromJson(json['basicSong']);
    } else if (type == 2) {
      basicSong = NCMSong.fromJson(json['basicSong']);
    } else if (type == 3) {
      biliResource = BiliResource.fromJson(json['biliResource']);
    } else {
      throw 'Invalid type';
    }
    return PMSDetailSong(
      json['id'],
      type,
      basicSong,
      biliResource,
      name: json['name'],
      singers: singers,
      cover: json['cover'],
      payPlay: json['payPlay'],
      isTakenDown: json['isTakenDown'],
    );
  }

  @override
  String toString() {
    return 'PMSDetailSong{id: $id, type: $type, basicSong: $basicSong, biliResource: $biliResource, name: $name, singers: $singers, cover: $cover, payPlay: $payPlay, isTakenDown: $isTakenDown}';
  }
}
