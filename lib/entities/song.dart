import 'package:playlistmaster/entities/singer.dart';

/// Basic song using for playlist detail page.
class Song {
  String name;
  String songId;
  String songMid;
  String mediaMid;
  String vid;
  List<String> videoLinks;
  String songLink;
  List<Singer> singers;
  String coverUri;
  bool isTakenDown;

  /// 0 for free, 1 for pay.
  int payPlay;

  Song({
    required this.name,
    required this.songId,
    required this.songMid,
    required this.mediaMid,
    required this.vid,
    this.videoLinks = const [''],
    this.songLink = '',
    required this.singers,
    required this.coverUri,
    this.isTakenDown = true,
    required this.payPlay,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    List<dynamic> singersJson = json['singers'];
    List<Singer> singers =
        singersJson.map((singerJson) => Singer.fromJson(singerJson)).toList();
    return Song(
      name: json['songName'],
      songId: json['songId'],
      songMid: json['songMid'],
      mediaMid: json['mediaMid'],
      vid: json['vid'],
      singers: singers,
      coverUri: json['coverUri'],
      payPlay: json['payPlay'],
    );
  }
}
