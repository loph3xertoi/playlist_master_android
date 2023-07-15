import 'package:flutter/foundation.dart';

@immutable
class BasicSinger {
  const BasicSinger({
    required this.name,
    required this.headPic,
  });

  final String name;
  final String headPic;
}
