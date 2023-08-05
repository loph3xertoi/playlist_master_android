// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/foundation.dart';

import 'bili_subpage_of_resource.dart';

/// Detail resource for bilibili, such as video, audio and so on.
@immutable
class BiliDetailResource {
  BiliDetailResource(
      this.id,
      this.bvid,
      this.cid,
      this.type,
      this.title,
      this.cover,
      this.page,
      this.duration,
      this.upperName,
      this.upperMid,
      this.upperHeadPic,
      this.playCount,
      this.danmakuCount,
      this.collectedCount,
      this.commentCount,
      this.coinsCount,
      this.sharedCount,
      this.likedCount,
      this.intro,
      this.publishedTime,
      this.createdTime,
      this.dynamicLabels,
      this.subpages,
      this.links);

  /// The id of this resource.
  final int id;

  /// The bvid of this resource.
  final String bvid;

  /// The cid of this resource.
  final int cid;

  /// The type of this resource, 2 for video, 12 for music, 21 for videos, 24 for official resources.
  final int type;

  /// The title of this resource.
  final String title;

  /// The cover of this resource.
  final String cover;

  /// The page of this resource, has multiple resources if greater than 1.
  final int page;

  /// The duration of this resource.
  final int duration;

  /// The upper's name of this resource.
  final String upperName;

  /// The upper's mid of this resource.
  final int upperMid;

  /// The upper's head picture of this resource.
  final String upperHeadPic;

  /// Play count of this resource.
  final int playCount;

  /// Danmaku count of this resource.
  final int danmakuCount;

  /// The collected count of this resource.
  final int collectedCount;

  /// The comment count.
  final int commentCount;

  /// The coins of this resource.
  final int coinsCount;

  /// Shared count of this resource.
  final int sharedCount;

  /// The liked count of this resource.
  final int likedCount;

  /// The introduction of this resource.
  final String intro;

  /// The published data of this resource.
  final int publishedTime;

  /// The created time of this resource.
  final int createdTime;

  /// The dynamic lables of this resource.
  final String dynamicLabels;

  /// The subpages of this resource.
  final List<BiliSubpageOfResource> subpages;

  /// The links of this video, the key is "video" for video without sound and "audio" for audio only,
  /// The value is a map that the key is resource code and the value is the real link of
  /// corresponding audio or video, specific code see [video code](https://socialsisteryi.github.io/bilibili-API-collect/docs/bangumi/videostream_url.html#qn%E8%A7%86%E9%A2%91%E6%B8%85%E6%99%B0%E5%BA%A6%E6%A0%87%E8%AF%86).
  final Map<String, Map<String, String>> links;

  factory BiliDetailResource.fromJson(Map<String, dynamic> json) {
    List<dynamic> subpagesJson = json['subpages'];
    List<BiliSubpageOfResource> subpages =
        subpagesJson.map((e) => BiliSubpageOfResource.fromJson(e)).toList();
    Map<String, dynamic> linksJsonMap = json['links'];
    Map<String, Map<String, String>> links = {};
    linksJsonMap.forEach((key, value) {
      links[key] = Map<String, String>.from(value);
    });
    return BiliDetailResource(
      json['id'],
      json['bvid'],
      json['cid'],
      json['type'],
      json['title'],
      json['cover'],
      json['page'],
      json['duration'],
      json['upperName'],
      json['upperMid'],
      json['upperHeadPic'],
      json['playCount'],
      json['danmakuCount'],
      json['collectedCount'],
      json['commentCount'],
      json['coinsCount'],
      json['sharedCount'],
      json['likedCount'],
      json['intro'],
      json['publishedTime'],
      json['createdTime'],
      json['dynamicLabels'],
      subpages,
      links,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bvid': bvid,
      'cid': cid,
      'type': type,
      'title': title,
      'cover': cover,
      'page': page,
      'duration': duration,
      'upperName': upperName,
      'upperMid': upperMid,
      'upperHeadPic': upperHeadPic,
      'playCount': playCount,
      'danmakuCount': danmakuCount,
      'collectedCount': collectedCount,
      'commentCount': commentCount,
      'coinsCount': coinsCount,
      'sharedCount': sharedCount,
      'likedCount': likedCount,
      'intro': intro,
      'publishedTime': publishedTime,
      'createdTime': createdTime,
      'dynamicLabels': dynamicLabels,
      'subpages': subpages,
      'links': links,
    };
  }

  @override
  String toString() {
    return 'BiliDetailResource{id: $id, bvid: $bvid, cid: $cid, type: $type, title: $title, cover: $cover, page: $page, duration: $duration, upperName: $upperName, upperMid: $upperMid, upperHeadPic: $upperHeadPic, playCount: $playCount, danmakuCount: $danmakuCount, collectedCount: $collectedCount, commentCount: $commentCount, coinsCount: $coinsCount, sharedCount: $sharedCount, likedCount: $likedCount, intro: $intro, publishedTime: $publishedTime, createdTime: $createdTime, dynamicLabels: $dynamicLabels, subpages: $subpages, links: $links}';
  }
}
