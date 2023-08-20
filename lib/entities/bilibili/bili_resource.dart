// ignore_for_file: public_member_api_docs, sort_constructors_first
/// Resource for bilibili, such as video, audio and so on.
class BiliResource {
  BiliResource(this.id, this.bvid, this.type, this.title, this.cover, this.page,
      this.duration, this.upperName, this.playCount, this.danmakuCount);

  /// The id of this resource.
  final int id;

  /// The bvid of this resource.
  final String bvid;

  /// The type of this resource, 2 for video, 12 for music, 21 for videos, 24 for official resources.
  final int type;

  /// The title of this resource.
  final String title;

  /// The cover of this resource.
  final String cover;

  /// The page of this resource, has multiple resources if greater than 1.
  int page;

  /// The duration of this resource.
  final int duration;

  /// The upper's name of this resource.
  final String upperName;

  /// Play count of this resource.
  final int playCount;

  /// Danmaku count of this resource.
  final int danmakuCount;

  factory BiliResource.fromJson(Map<String, dynamic> json) {
    return BiliResource(
      json['id'],
      json['bvid'],
      json['type'],
      json['title'],
      json['cover'],
      json['page'],
      json['duration'],
      json['upperName'],
      json['playCount'],
      json['danmakuCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bvid': bvid,
      'type': type,
      'title': title,
      'cover': cover,
      'page': page,
      'duration': duration,
      'upperName': upperName,
      'playCount': playCount,
      'danmakuCount': danmakuCount,
    };
  }

  @override
  String toString() {
    return 'BiliResource{id: $id, bvid: $bvid, type: $type, title: $title, cover: $cover, page: $page, duration: $duration, upperName: $upperName, playCount: $playCount, danmakuCount: $danmakuCount}';
  }
}
