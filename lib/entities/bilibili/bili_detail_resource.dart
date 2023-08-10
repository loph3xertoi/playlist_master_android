// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/foundation.dart';
import 'package:playlistmaster/entities/bilibili/bili_resource.dart';

import 'bili_subpage_of_resource.dart';

/// Detail resource for bilibili, such as video, audio and so on.
@immutable
class BiliDetailResource extends BiliResource {
  BiliDetailResource(
      super.id,
      super.bvid,
      super.type,
      super.title,
      super.cover,
      super.page,
      super.duration,
      super.upperName,
      super.playCount,
      super.danmakuCount,
      this.aid,
      this.cid,
      this.isSeasonResource,
      this.upperMid,
      this.upperHeadPic,
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
      this.episodes,
      this.links);

  /// The aid of this resource, for favorite resources.
  final int aid;

  /// The cid of this resource.
  final int cid;

  /// Whether this resource has episodes.
  final bool isSeasonResource;

  /// The upper's mid of this resource.
  final int upperMid;

  /// The upper's head picture of this resource.
  final String upperHeadPic;

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
  final List<BiliSubpageOfResource>? subpages;

  /// The episodes of this resource.
  final List<BiliDetailResource>? episodes;

  /// The links of this video, the key is "video" for video without sound and "audio" for audio only,
  /// The value is a map that the key is resource code and the value is the real link of
  /// corresponding audio or video, specific code see [video code](https://socialsisteryi.github.io/bilibili-API-collect/docs/bangumi/videostream_url.html#qn%E8%A7%86%E9%A2%91%E6%B8%85%E6%99%B0%E5%BA%A6%E6%A0%87%E8%AF%86).
  final Map<String, Map<String, String>>? links;

  factory BiliDetailResource.fromJson(Map<String, dynamic> json) {
    List<dynamic>? subpagesJson = json['subpages'];
    List<dynamic>? episodesJson = json['episodes'];
    List<BiliSubpageOfResource>? subpages;
    List<BiliDetailResource>? episodes;
    if (subpagesJson != null) {
      subpages =
          subpagesJson.map((e) => BiliSubpageOfResource.fromJson(e)).toList();
    }
    if (episodesJson != null) {
      episodes =
          episodesJson.map((e) => BiliDetailResource.fromJson(e)).toList();
    }
    Map<String, Map<String, String>> links = {};
    Map<String, dynamic>? linksJsonMap = json['links'];
    // This resource isn't single episode.
    if (linksJsonMap != null) {
      linksJsonMap.forEach((key, value) {
        links[key] = Map<String, String>.from(value);
      });
    }
    return BiliDetailResource(
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
      json['aid'],
      json['cid'],
      json['isSeasonResource'],
      json['upperMid'],
      json['upperHeadPic'],
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
      episodes,
      links,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bvid': bvid,
      'cid': cid,
      'type': type,
      'title': title,
      'cover': cover,
      'page': page,
      'isSeasonResource': isSeasonResource,
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
    return 'BiliDetailResource{id: $id, bvid: $bvid, cid: $cid, type: $type, title: $title, cover: $cover, page: $page, isSeasonResource: $isSeasonResource, duration: $duration, upperName: $upperName, upperMid: $upperMid, upperHeadPic: $upperHeadPic, playCount: $playCount, danmakuCount: $danmakuCount, collectedCount: $collectedCount, commentCount: $commentCount, coinsCount: $coinsCount, sharedCount: $sharedCount, likedCount: $likedCount, intro: $intro, publishedTime: $publishedTime, createdTime: $createdTime, dynamicLabels: $dynamicLabels, subpages: $subpages, links: $links}';
  }
}
