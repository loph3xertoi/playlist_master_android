// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/foundation.dart';

/// Sub page entity in resource of bilibili.
@immutable
class BiliSubpageOfResource {
  BiliSubpageOfResource(this.bvid, this.cid, this.page, this.partName,
      this.duration, this.width, this.height);

  /// The bvid of this resource, same as the parent resource's bvid.
  final String bvid;

  /// The cid of this resource.
  final int cid;

  /// The page number of this resource.
  final int page;

  /// The name of this part of resource.
  final String partName;

  /// The duration of this part of resource.
  final int duration;

  /// The width of this part of resource.
  final int width;

  /// The height of this part of resource.
  final int height;

  factory BiliSubpageOfResource.fromJson(Map<String, dynamic> json) {
    return BiliSubpageOfResource(
      json['bvid'],
      json['cid'],
      json['page'],
      json['partName'],
      json['duration'],
      json['width'],
      json['height'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bvid': bvid,
      'cid': cid,
      'page': page,
      'partName': partName,
      'duration': duration,
      'width': width,
      'height': height,
    };
  }

  @override
  String toString() {
    return 'BiliSubpageOfResource{bvid: $bvid, cid: $cid, page: $page, partName: $partName, duration: $duration, width: $width, height: $height}';
  }
}
