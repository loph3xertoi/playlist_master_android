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

  factory DetailPlaylist.fromJson(Map<String, dynamic> json) {
    List<dynamic> songsJson = json['songs'];
    List<Song> songs =
        songsJson.map((songJson) => Song.fromJson(songJson)).toList();
    return DetailPlaylist(
      name: json['name'],
      description: json['desc'],
      coverImage: json['coverImage'],
      songsCount: json['songCount'],
      listenNum: json['listenNum'],
      dirId: json['dirId'],
      tid: json['tid'],
      songs: songs,
    );
  }
}
