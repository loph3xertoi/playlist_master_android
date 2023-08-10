import 'package:flutter/foundation.dart';

import '../bilibili/bili_resource.dart';
import '../netease_cloud_music/ncm_song.dart';
import '../qq_music/qqmusic_song.dart';

/// DTO for paged data.
@immutable
class PagedDataDTO<T> {
  PagedDataDTO(this.count, this.list, this.hasMore);

  /// The total count of target data.
  final int count;

  /// The paged data.
  final List<T>? list;

  /// Whether there has more data.
  final bool hasMore;

  factory PagedDataDTO.fromJson(Map<String, dynamic> json) {
    List<dynamic> resourcesJson = json['list'];
    dynamic resources;
    if (T is QQMusicSong) {
      resources = resourcesJson
          .map<QQMusicSong>((e) => QQMusicSong.fromJson(e))
          .toList();
    } else if (T is NCMSong) {
      resources =
          resourcesJson.map<NCMSong>((e) => NCMSong.fromJson(e)).toList();
    } else if (T is BiliResource) {
      resources = resourcesJson
          .map<BiliResource>((e) => BiliResource.fromJson(e))
          .toList();
    } else {
      throw Exception('Invalid data type in paged data dto');
    }
    return PagedDataDTO(
      json['count'],
      resources,
      json['hasMore'],
    );
  }
}
