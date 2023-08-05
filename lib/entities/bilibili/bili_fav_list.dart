// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../basic/basic_library.dart';

/// Fav list for bilibili.
class BiliFavList extends BasicLibrary {
  BiliFavList(
      this.id, this.fid, this.mid, this.upperName, this.viewCount, this.type,
      {required super.name, required super.cover, required super.itemCount});

  /// The id of this fav list.
  final int id;

  /// The fid of the fav list.
  final int fid;

  /// The mid of the user.
  final int mid;

  /// The upper's name of this fav list.
  final String upperName;

  /// The view count of this fav list.
  final int viewCount;

  /// The type of this fav list, 0 for created fav list, 1 for collected fav list.
  final int type;

  factory BiliFavList.fromJson(Map<String, dynamic> json) {
    return BiliFavList(
      json['id'],
      json['fid'],
      json['mid'],
      json['upperName'],
      json['viewCount'],
      json['type'],
      name: json['name'],
      cover: json['cover'],
      itemCount: json['itemCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fid': fid,
      'mid': mid,
      'name': name,
      'upperName': upperName,
      'viewCount': viewCount,
      'type': type,
      'cover': cover,
      'itemCount': itemCount,
    };
  }

  @override
  String toString() {
    return 'BiliFavList{id: $id, fid: $fid, mid: $mid, name: $name, upperName: $upperName, viewCount: $viewCount, type: $type, cover: $cover, itemCount: $itemCount}';
  }
}
