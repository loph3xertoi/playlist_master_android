// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../basic/basic_library.dart';
import 'bili_resource.dart';

/// Detail fav list for bilibili.
class BiliDetailFavList extends BasicLibrary {
  BiliDetailFavList(
      this.id,
      this.fid,
      this.mid,
      this.upperName,
      this.upperHeadPic,
      this.viewCount,
      this.collectedCount,
      this.likeCount,
      this.shareCount,
      this.danmakuCount,
      this.createdTime,
      this.modifiedTime,
      this.intro,
      this.hasMore,
      this.resources,
      this.type,
      {required super.name,
      required super.cover,
      required super.itemCount});

  /// The id of this fav list.
  final int id;

  /// The fid of the fav list.
  final int fid;

  /// The mid of the user.
  final int mid;

  /// The upper's name of this fav list.
  final String upperName;

  /// The upper's head pic.
  final String upperHeadPic;

  /// The view count of this fav list.
  final int viewCount;

  /// The collected count of this fav list.
  final int collectedCount;

  /// The like count of this fav list.
  final int likeCount;

  /// The share count of this fav list.
  final int shareCount;

  /// The danmaku count of this fav list.
  final int danmakuCount;

  /// The created time of this fav list.
  final int createdTime;

  /// The modified time of this fav list.
  final int modifiedTime;

  /// The introduction of this fav list.
  final String intro;

  /// Whether there has more resources in this fav list.
  final bool hasMore;

  /// The paged resources in this fav list.
  final List<BiliResource> resources;

  /// The type of this fav list, 0 for created fav list, 1 for collected fav list.
  final int type;

  factory BiliDetailFavList.fromJson(Map<String, dynamic> json) {
    List<dynamic> resourcesJson = json['resources'];
    List<BiliResource> resources = resourcesJson
        .map((resourceJson) => BiliResource.fromJson(resourceJson))
        .toList();
    return BiliDetailFavList(
      json['id'],
      json['fid'],
      json['mid'],
      json['upperName'],
      json['upperHeadPic'],
      json['viewCount'],
      json['collectedCount'],
      json['likeCount'],
      json['shareCount'],
      json['danmakuCount'] ?? 0,
      json['createdTime'],
      json['modifiedTime'],
      json['intro'],
      json['hasMore'],
      resources,
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
      'upperHeadPic': upperHeadPic,
      'viewCount': viewCount,
      'collectedCount': collectedCount,
      'likeCount': likeCount,
      'shareCount': shareCount,
      'danmakuCount': danmakuCount,
      'createdTime': createdTime,
      'modifiedTime': modifiedTime,
      'intro': intro,
      'hasMore': hasMore,
      'resources': resources,
      'type': type,
      'cover': cover,
      'itemCount': itemCount,
    };
  }

  @override
  String toString() {
    return 'BiliDetailFavList{id: $id, fid: $fid, mid: $mid, upperName: $upperName, upperHeadPic: $upperHeadPic, viewCount: $viewCount, collectedCount: $collectedCount, likeCount: $likeCount, shareCount: $shareCount, danmakuCount: $danmakuCount, createdTime: $createdTime, modifiedTime: $modifiedTime, intro: $intro, hasMore: $hasMore, resources: $resources, type: $type, name: $name, cover: $cover, itemCount: $itemCount}';
  }
}
