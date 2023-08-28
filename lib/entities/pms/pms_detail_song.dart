import 'package:flutter/foundation.dart';

import '../basic/basic_song.dart';
import 'pms_singer.dart';

/// Detail song for pms.
@immutable
class PMSDetailSong extends BasicSong {
  const PMSDetailSong(this.link,
      {required super.name,
      required super.singers,
      required super.cover,
      required super.payPlay,
      required super.isTakenDown});

  /// The link of this song.
  final String link;

  factory PMSDetailSong.fromJson(Map<String, dynamic> json) {
    List<dynamic> singersJson = json['singers'];
    List<PMSSinger> singers = singersJson
        .map<PMSSinger>((singer) => PMSSinger.fromJson(singer))
        .toList();
    return PMSDetailSong(
      json['link'],
      name: json['name'],
      singers: singers,
      cover: json['cover'],
      payPlay: json['payPlay'],
      isTakenDown: json['isTakenDown'],
    );
  }

  @override
  String toString() {
    return 'PMSDetailSong{link: $link, name: $name, singers: $singers, cover: $cover, payPlay: $payPlay, isTakenDown: $isTakenDown}';
  }
}
