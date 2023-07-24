import '../basic/basic_library.dart';

/// Playlist for ncm.
class NCMPlaylist extends BasicLibrary {
  NCMPlaylist(
    this.id, {
    required super.name,
    required super.cover,
    required super.itemCount,
  });

  /// Playlist id for ncm.
  final int id;

  factory NCMPlaylist.fromJson(Map<String, dynamic> json) {
    return NCMPlaylist(
      json['id'],
      name: json['name'],
      cover: json['cover'],
      itemCount: json['itemCount'],
    );
  }

  @override
  String toString() {
    return 'NCMPlaylist{id: $id, name: $name, cover: $cover, itemCount: $itemCount}';
  }
}
