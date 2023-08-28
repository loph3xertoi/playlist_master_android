import '../basic/basic_library.dart';
import 'pms_song.dart';

/// Detail library for pms.
class PMSDetailLibrary extends BasicLibrary {
  PMSDetailLibrary(this.id, this.creatorId, this.intro, this.createTime,
      this.updateTime, this.songs,
      {required super.name, required super.cover, required super.itemCount});

  /// The id of this library in playlist master server.
  final int id;

  /// The creator's id of this playlist.
  final int creatorId;

  /// The introduction of this playlist.
  final String intro;

  /// Create time of this playlist.
  final int createTime;

  /// Update time of this playlist.
  final int updateTime;

  /// All songs in this playlist.
  final List<PMSSong> songs;

  factory PMSDetailLibrary.fromJson(Map<String, dynamic> json) {
    List<dynamic> songsJson = json['songs'];
    List<PMSSong> songs = songsJson
        .map<PMSSong>((songJson) => PMSSong.fromJson(songJson))
        .toList();
    return PMSDetailLibrary(
      json['id'],
      json['creatorId'],
      json['intro'],
      json['createTime'],
      json['updateTime'],
      songs,
      name: json['name'],
      cover: json['cover'],
      itemCount: json['itemCount'],
    );
  }

  @override
  String toString() {
    return 'PMSDetailLibrary{id: $id, creatorId: $creatorId, intro: $intro, createTime: $createTime, updateTime: $updateTime, songs: $songs, name: $name, cover: $cover, itemCount: $itemCount}';
  }
}
