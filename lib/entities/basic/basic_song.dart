import 'package:flutter/foundation.dart';
import 'package:playlistmaster/entities/basic/basic_singer.dart';

@immutable
class BasicSong {
  const BasicSong({
    required this.name,
    required this.singers,
    required this.cover,
    required this.payPlay,
    required this.isTakenDown,
    this.songLink,
  });

  final String name;
  final List<BasicSinger> singers;
  final String cover;
  final int payPlay;
  final bool isTakenDown;
  final String? songLink;
}
