import 'package:flutter/cupertino.dart';
import 'package:playlistmaster/entities/qq_music/qqmusic_singer.dart';

import '../basic/basic_video.dart';

/// Detail video of qq music.
@immutable
class QQMusicDetailVideo extends BasicVideo {
  const QQMusicDetailVideo(
    this.pubDate,
    this.vid,
    this.duration,
    this.playCnt,
    this.desc,
    this.links, {
    required super.name,
    required super.cover,
    required super.singers,
  });

  /// The published date of the mv.
  final int pubDate;

  /// The vid of the mv.
  final String vid;

  /// The duration the mv.
  final int duration;

  /// Viewed times of the mv.
  final int playCnt;

  /// Description of the mv.
  final String desc;

  /// The links of the mv.
  final List<String> links;

  factory QQMusicDetailVideo.fromJson(Map<String, dynamic> json) {
    List<dynamic> linksJson = json['links'];
    List<dynamic> singersJson = json['singers'];
    List<String> links =
        linksJson.map<String>((link) => link.toString()).toList();
    List<QQMusicSinger> singers = singersJson
        .map<QQMusicSinger>((singer) => QQMusicSinger.fromJson(singer))
        .toList();
    return QQMusicDetailVideo(
      json['pubDate'],
      json['vid'],
      json['duration'],
      json['playCnt'],
      json['desc'],
      links,
      name: json['name'],
      cover: json['cover'],
      singers: singers,
    );
  }
}