import 'package:playlistmaster/entities/singer.dart';

/// Basic video entity.
class Video {
  String name;
  List<Singer> singers;
  String coverPic;
  int pubdate;
  String vid;
  List<String> videoLinks;
  int duration;
  int playCnt;
  String desc;

  Video({
    required this.name,
    required this.singers,
    required this.coverPic,
    required this.pubdate,
    required this.vid,
    this.videoLinks = const [''],
    required this.duration,
    required this.playCnt,
    required this.desc,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    List<dynamic> singersJson = json['singers'];
    List<Singer> singers =
        singersJson.map((singerJson) => Singer.fromJson(singerJson)).toList();
    return Video(
      name: json['name'],
      singers: singers,
      coverPic: json['coverPic'],
      pubdate: json['pubdate'],
      vid: json['vid'],
      duration: json['duration'],
      playCnt: json['playCnt'],
      desc: json['desc'],
    );
  }
}