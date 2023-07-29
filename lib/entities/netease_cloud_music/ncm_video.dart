import 'package:flutter/foundation.dart';

import '../basic/basic_video.dart';
import 'ncm_singer.dart';

/// Video for ncm.
@immutable
class NCMVideo extends BasicVideo {
  const NCMVideo(this.id, this.playCount, this.duration, this.publishTime,
      {required super.name, required super.cover, required super.singers});

  /// The id of the mv, may be mvid or vid.
  final String id;

  /// Viewed times of the video.
  final int playCount;

  /// The duration of the mv.
  final int duration;

  /// The published time of the mv.
  final String publishTime;

  factory NCMVideo.fromJson(Map<String, dynamic> json) {
    List<dynamic> singersJson = json['singers'];
    List<NCMSinger> singers = singersJson
        .map<NCMSinger>((singer) => NCMSinger.fromJson(singer))
        .toList();
    return NCMVideo(
      json['id'],
      json['playCount'],
      json['duration'],
      json['publishTime'],
      name: json['name'],
      cover: json['cover'],
      singers: singers,
    );
  }

  @override
  String toString() {
    return 'NCMVideo{name: $name, id: $id, playCount: $playCount, duration: $duration, publishTime: $publishTime, cover: $cover, singers: $singers}';
  }
}
