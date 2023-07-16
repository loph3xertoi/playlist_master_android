import 'package:flutter/foundation.dart';

import '../basic/basic_singer.dart';

/// Singer for qq music.
@immutable
class QQMusicSinger extends BasicSinger {
  const QQMusicSinger(
    this.id,
    this.mid, {
    required super.name,
    required super.headPic,
  });

  /// Singer's id.
  final int id;

  /// Mid of the singer.
  final String mid;

  factory QQMusicSinger.fromJson(Map<String, dynamic> json) {
    return QQMusicSinger(
      json['id'],
      json['mid'],
      name: json['name'],
      headPic: json['headPic'],
    );
  }
}