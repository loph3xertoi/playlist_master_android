import 'package:flutter/foundation.dart';
import 'package:playlistmaster/entities/basic/basic_singer.dart';

@immutable
class BasicVideo {
  const BasicVideo({
    required this.name,
    required this.cover,
    required this.singers,
  });

  final String name;
  final String cover;
  final List<BasicSinger> singers;
}
