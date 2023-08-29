import 'package:flutter/foundation.dart';

import '../basic/basic_singer.dart';

/// Singer for ncm.
@immutable
class NCMSinger extends BasicSinger {
  const NCMSinger(
    this.id, {
    required super.name,
    required super.headPic,
  });

  /// Singer's id.
  final int id;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'headPic': headPic,
    };
  }

  factory NCMSinger.fromJson(Map<String, dynamic> json) {
    return NCMSinger(
      json['id'],
      name: json['name'],
      headPic: json['headPic'] ?? '',
    );
  }

  @override
  String toString() {
    return 'NCMSinger{id: $id, name: $name, headPic: $headPic}';
  }
}
