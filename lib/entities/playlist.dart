class Playlist {
  String name;
  String coverImage;
  String? description;
  int songsCount;
  int listenNum;
  int dirId;
  String tid;

  Playlist({
    required this.name,
    required this.coverImage,
    this.description = 'A description for your playlist.',
    required this.songsCount,
    required this.listenNum,
    required this.dirId,
    required this.tid,
  });
}
