import 'package:flutter/cupertino.dart';
import 'package:playlistmaster/entities/qq_music/qqmusic_singer.dart';

import '../basic/basic_video.dart';
import 'ncm_singer.dart';

/// Detail video of ncm.
@immutable
class NCMDetailVideo extends BasicVideo {
  const NCMDetailVideo(
      this.id,
      this.desc,
      this.playCount,
      this.subCount,
      this.shareCount,
      this.commentCount,
      this.duration,
      this.publishTime,
      this.rates,
      this.links,
      {required super.name,
      required super.cover,
      required super.singers});

  /// The id of the mv, may be mvid or vid.
  final String id;

  /// Description of the mv.
  final String desc;

  /// Viewed times of the mv.
  final int playCount;

  /// Subscribed count of the video.
  final int subCount;

  /// Shared count of the video.
  final int shareCount;

  /// Commented count of the video.
  final int commentCount;

  /// The duration the mv.
  final int duration;

  /// The published date of the mv.
  final String publishTime;

  /// The bite rate as key and the size of the mv as value.
  final Map<String, int> rates;

  /// The links of the mv, the key is resolution and the value is the url.
  final Map<String, String> links;

  factory NCMDetailVideo.fromJson(Map<String, dynamic> json) {
    List<dynamic> singersJson = json['singers'];
    List<NCMSinger> singers = singersJson
        .map<NCMSinger>((singer) => NCMSinger.fromJson(singer))
        .toList();
    Map<String, dynamic> ratesJson = json['rates'];
    Map<String, dynamic> linksJson = json['links'];
    Map<String, int> rates = ratesJson.map((k, v) => MapEntry(k, v as int));
    Map<String, String> links =
        linksJson.map((k, v) => MapEntry(k, v as String));
    return NCMDetailVideo(
      json['id'],
      json['desc'],
      json['playCount'],
      json['subCount'],
      json['shareCount'],
      json['commentCount'],
      json['duration'],
      json['publishTime'],
      rates,
      links,
      name: json['name'],
      cover: json['cover'],
      singers: singers,
    );
  }

  @override
  String toString() {
    return 'NCMDetailVideo{name: $name, cover: $cover, singers: $singers, id: $id, desc: $desc, playCount: $playCount, subCount: $subCount, shareCount: $shareCount, commentCount: $commentCount, duration: $duration, publishTime: $publishTime, rates: $rates, links: $links}';
  }
}
