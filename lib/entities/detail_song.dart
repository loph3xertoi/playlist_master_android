import 'package:playlistmaster/entities/lyrics.dart';
import 'package:playlistmaster/entities/singer.dart';

/// Detail song for song player page.
class DetailSong {
  String name;
  String title;
  String albumName;
  String coverUri;
  List<Singer> singers;
  int payPlay;
  String songId;
  String songMid;
  String mediaMid;
  String vid;
  int duration;
  String description;
  String pubTime;
  Lyrics lyrics;
  List<int>? pmPlaylists;
  int size128;
  int size320;
  int sizeApe;
  int sizeFlac;
  bool? isTakenDown = false;

  DetailSong({
    required this.name,
    required this.title,
    required this.albumName,
    required this.coverUri,
    required this.singers,
    required this.payPlay,
    required this.songId,
    required this.songMid,
    required this.mediaMid,
    required this.vid,
    required this.duration,
    required this.description,
    required this.pubTime,
    required this.lyrics,
    required this.pmPlaylists,
    required this.size128,
    required this.size320,
    required this.sizeApe,
    required this.sizeFlac,
  });

  factory DetailSong.fromJson(Map<String, dynamic> json) {
    List<dynamic> singersJson = json['singers'];
    List<Singer> singers =
        singersJson.map((singerJson) => Singer.fromJson(singerJson)).toList();
    return DetailSong(
      name: json['songName'],
      title: json['subTitle'],
      albumName: json['albumName'],
      coverUri: json['coverUri'],
      singers: singers,
      payPlay: json['payPlay'],
      songId: json['songId'],
      songMid: json['songMid'],
      mediaMid: json['mediaMid'],
      vid: json['vid'],
      duration: json['duration'],
      description: json['songDesc'],
      pubTime: json['pubTime'],
      lyrics: Lyrics.fromJson(json['lyrics']),
      pmPlaylists: json['pmPlaylists'],
      size128: json['size128'],
      size320: json['size320'],
      sizeApe: json['sizeApe'],
      sizeFlac: json['sizeFlac'],
    );
  }
}
