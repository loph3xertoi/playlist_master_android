import '../basic/basic_library.dart';

/// Library for pms.
class PMSLibrary extends BasicLibrary {
  PMSLibrary(this.id, this.creatorId,
      {required super.name, required super.cover, required super.itemCount});

  /// The id of this library in playlist master server.
  final int id;

  /// The creator's id of this playlist.
  final int creatorId;

  factory PMSLibrary.fromJson(Map<String, dynamic> json) {
    return PMSLibrary(
      json['id'],
      json['creatorId'],
      name: json['name'],
      cover: json['cover'],
      itemCount: json['itemCount'],
    );
  }

  @override
  String toString() {
    return 'PMSLibrary{id: $id, creatorId: $creatorId, name: $name, cover: $cover, itemCount: $itemCount}';
  }
}
