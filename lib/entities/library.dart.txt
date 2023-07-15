/// Basic playlist for playlists showing.
class Playlist {
  String name;
  String coverImage;
  int songsCount;
  int dirId;
  String tid;

  Playlist({
    required this.name,
    required this.coverImage,
    required this.songsCount,
    required this.dirId,
    required this.tid,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      name: json['name'],
      coverImage: json['coverImage'],
      songsCount: json['songCount'],
      dirId: json['dirId'],
      tid: json['tid'],
    );
  }
}
