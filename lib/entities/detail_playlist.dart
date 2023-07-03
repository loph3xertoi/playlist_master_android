import 'package:playlistmaster/entities/song.dart';

/// Detail playlist.
class DetailPlaylist {
  String name;
  String? description;
  String coverImage;
  int songsCount;
  int listenNum;
  int dirId;
  String tid;
  List<Song> songs;

  DetailPlaylist({
    required this.name,
    this.description = 'A description for your playlist.',
    required this.coverImage,
    required this.songsCount,
    required this.listenNum,
    required this.dirId,
    required this.tid,
    required this.songs,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'desc': description,
      'coverImage': coverImage,
      'songCount': songsCount,
      'listenNum': listenNum,
      'dirId': dirId,
      'tid': tid,
      'songs': songs,
    };
  }

  factory DetailPlaylist.fromJson(Map<String, dynamic> json) {
    int songsCount = json['songCount'];
    List<Song> songs;
    if (songsCount != 0) {
      List<dynamic> songsJson = json['songs'];
      songs = songsJson.map((songJson) => Song.fromJson(songJson)).toList();
    } else {
      songs = [];
    }
    return DetailPlaylist(
      name: json['name'],
      description: json['desc'],
      coverImage: json['coverImage'],
      songsCount: songsCount,
      listenNum: json['listenNum'],
      dirId: json['dirId'],
      tid: json['tid'],
      songs: songs,
    );
  }
}
