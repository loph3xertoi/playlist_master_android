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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mid': mid,
      'name': name,
      'headPic': headPic,
    };
  }

  factory QQMusicSinger.fromJson(Map<String, dynamic> json) {
    return QQMusicSinger(
      json['id'],
      json['mid'],
      name: json['name'],
      headPic: json['headPic'],
    );
  }

  @override
  String toString() {
    return 'QQMusicSinger{id: $id, mid: $mid, name: $name, headPic: $headPic}';
  }
}
