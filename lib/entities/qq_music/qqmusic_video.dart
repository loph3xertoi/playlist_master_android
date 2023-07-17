import 'package:flutter/foundation.dart';
import 'package:playlistmaster/entities/qq_music/qqmusic_singer.dart';

import '../basic/basic_video.dart';

/// Video for qq music.
@immutable
class QQMusicVideo extends BasicVideo {
  const QQMusicVideo(
    this.vid,
    this.playCnt, {
    required super.name,
    required super.cover,
    required super.singers,
  });

  /// The vid of the mv.
  final String vid;

  /// Viewed times of the video.
  final int playCnt;

  factory QQMusicVideo.fromJson(Map<String, dynamic> json) {
    List<dynamic> singersJson = json['singers'];
    List<QQMusicSinger> singers = singersJson
        .map<QQMusicSinger>((singer) => QQMusicSinger.fromJson(singer))
        .toList();
    return QQMusicVideo(
      json['vid'],
      json['playCnt'],
      name: json['name'],
      cover: json['cover'],
      singers: singers,
    );
  }

  @override
  String toString() {
    return 'QQMusicVideo{vid: $vid, playCnt: $playCnt, name: $name, cover: $cover, singers: $singers}';
  }
}
