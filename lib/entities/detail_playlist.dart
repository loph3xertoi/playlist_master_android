import 'package:playlistmaster/entities/song.dart';

class DetailPlaylist {
  String name;
  String? description;
  String coverImage;
  int songsCount;
  int dirId;
  String tid;
  List<Song> songs;

  DetailPlaylist({
    required this.name,
    this.description = 'A description for your playlist.',
    required this.coverImage,
    required this.songsCount,
    required this.dirId,
    required this.tid,
    required this.songs,
  });
}
