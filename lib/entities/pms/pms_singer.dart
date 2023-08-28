import 'package:flutter/foundation.dart';

import '../basic/basic_singer.dart';

/// Singer for pms.
@immutable
class PMSSinger extends BasicSinger {
  const PMSSinger(this.id, this.type,
      {required super.name, required super.headPic});

  /// Singer id in pms.
  final int id;

  /// Which platform this singer belongs to, 1: qqmusic, 2: ncm, 3: bilibili.
  final int type;

  factory PMSSinger.fromJson(Map<String, dynamic> json) {
    return PMSSinger(
      json['id'],
      json['type'],
      name: json['name'],
      headPic: json['headPic'],
    );
  }

  @override
  String toString() {
    return 'PMSSinger{id: $id, type: $type, name: $name, headPic: $headPic}';
  }
}
