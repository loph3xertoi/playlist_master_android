import '../basic/basic_library.dart';
import 'ncm_song.dart';

/// Detail playlist of ncm.
class NCMDetailPlaylist extends BasicLibrary {
  NCMDetailPlaylist(this.id, this.trackUpdateTime, this.updateTime,
      this.createTime, this.playCount, this.description, this.tags, this.songs,
      {required super.name, required super.cover, required super.itemCount});

  /// The id of this playlist.
  final int id;

  /// Last update time of the playlist's tracks.
  final int trackUpdateTime;

  /// Last update time of the playlist.
  final int updateTime;

  /// The creating time of the playlist.
  final int createTime;

  /// Playing count of this playlist.
  final int playCount;

  /// The description of your playlist.
  final String description;

  /// The tags of the playlist.
  final List<String> tags;

  /// The songs within this playlist.
  final List<NCMSong> songs;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cover': cover,
      'itemCount': itemCount,
      'id': id,
      'trackUpdateTime': trackUpdateTime,
      'updateTime': updateTime,
      'createTime': createTime,
      'playCount': playCount,
      'description': description,
      'tags': tags,
      'songs': songs
    };
  }

  factory NCMDetailPlaylist.fromJson(Map<String, dynamic> json) {
    int itemCount = json['itemCount'];
    List<NCMSong> songs = [];

    if (itemCount > 0) {
      List<dynamic> songsJson = json['songs'];
      songs = songsJson.map<NCMSong>((e) => NCMSong.fromJson(e)).toList();
    }

    List<String> tags = [];
    int tagsCount = json['tags'].length;
    if (tagsCount > 0) {
      List<dynamic> tagsJson = json['tags'];
      tags = tagsJson.map<String>((e) => e.toString()).toList();
    }
    return NCMDetailPlaylist(
      json['id'],
      json['trackUpdateTime'],
      json['updateTime'],
      json['createTime'],
      json['playCount'],
      json['description'],
      tags,
      songs,
      name: json['name'],
      cover: json['cover'],
      itemCount: itemCount,
    );
  }

  @override
  String toString() {
    return 'NCMDetailPlaylist{id: $id, trackUpdateTime: $trackUpdateTime, updateTime: $updateTime, createTime: $createTime, playCount: $playCount, description: $description, tags: $tags, songs: $songs, name: $name, cover: $cover, itemCount: $itemCount}';
  }
}
