// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/foundation.dart';

/// Sub page entity in resource of bilibili.
@immutable
class BiliSubpageOfResource {
  BiliSubpageOfResource(this.cid, this.page, this.partName, this.duration,
      this.width, this.height);

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

  // /// The first frame of this part of resource.
  // final String firstFrame;

  factory BiliSubpageOfResource.fromJson(Map<String, dynamic> json) {
    return BiliSubpageOfResource(
      json['cid'],
      json['page'],
      json['partName'],
      json['duration'],
      json['width'],
      json['height'],
      // json['firstFrame'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cid': cid,
      'page': page,
      'partName': partName,
      'duration': duration,
      'width': width,
      'height': height,
      // 'firstFrame': firstFrame,
    };
  }

  @override
  String toString() {
    return 'BiliSubpageOfResource{cid: $cid, page: $page, partName: $partName, duration: $duration, width: $width, height: $height}';
  }
}
