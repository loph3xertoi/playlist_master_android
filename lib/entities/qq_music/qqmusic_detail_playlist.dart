import '../basic/basic_library.dart';
import 'qqmusic_song.dart';

/// Detail playlist of qq music.
class QQMusicDetailPlaylist extends BasicLibrary {
  QQMusicDetailPlaylist(
    this.playCount,
    this.dirId,
    this.tid,
    this.songs, {
    required super.name,
    required super.cover,
    required super.itemCount,
    this.description = 'A description for your library.',
  });

  /// The description of your playlist.
  final String description;

  /// Listen times of this playlist.
  final int playCount;

  /// The dirId(local dawid) of this playlist.
  final int dirId;

  /// The tid(global id) of this playlist.
  final String tid;

  /// All basic songs in this playlist.
  final List<QQMusicSong> songs;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cover': cover,
      'itemCount': itemCount,
      'desc': description,
      'listenNum': playCount,
      'dirId': dirId,
      'tid': tid,
      'songs': songs.map((song) => song.toJson()).toList(),
    };
  }

  factory QQMusicDetailPlaylist.fromJson(Map<String, dynamic> json) {
    int itemCount = json['itemCount'];
    List<QQMusicSong> songs = [];

    if (itemCount > 0) {
      List<dynamic> songsJson = json['songs'];
      songs =
          songsJson.map<QQMusicSong>((e) => QQMusicSong.fromJson(e)).toList();
    }

    return QQMusicDetailPlaylist(
      json['listenNum'],
      json['dirId'],
      json['tid'],
      songs,
      name: json['name'],
      cover: json['cover'],
      itemCount: itemCount,
      description: json['desc'],
    );
  }

  @override
  String toString() {
    return 'QQMusicDetailPlaylist{playCount: $playCount, dirId: $dirId, tid: $tid, songs: $songs, name: $name, cover: $cover, itemCount: $itemCount, description: $description}';
  }
}
