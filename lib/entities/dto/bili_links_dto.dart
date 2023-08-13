import 'package:flutter/material.dart';

/// DTO for bilibili resource's links object.
@immutable
class BiliLinksDTO {
  const BiliLinksDTO(this.video, this.audio, this.mpd);

  /// The video links of the resource, key is "resource code", see {@link <a
  /// href="https://socialsisteryi.github.io/bilibili-API-collect/docs/bangumi/videostream_url.html#qn%E8%A7%86%E9%A2%91%E6%B8%85%E6%99%B0%E5%BA%A6%E6%A0%87%E8%AF%86>Video
  /// code</a>} for more details, the value is the link of this video corresponding to the resource
  /// code in the key.
  final Map<String, String> video;

  /// The audio links of the resource, key is "resource code", see {@link <a
  /// href="https://socialsisteryi.github.io/bilibili-API-collect/docs/bangumi/videostream_url.html#qn%E8%A7%86%E9%A2%91%E6%B8%85%E6%99%B0%E5%BA%A6%E6%A0%87%E8%AF%86>Audio
  /// code</a>} for more details, the value is the link of this audio corresponding to the resource
  /// code in the key.
  final Map<String, String> audio;

  /// The mpd url for this resource.
  final String mpd;

  factory BiliLinksDTO.fromJson(Map<String, dynamic> json) {
    Map<String, String> video = Map<String, String>.from(json['video']);
    Map<String, String> audio = Map<String, String>.from(json['audio']);
    String mpd = json['mpd'];
    return BiliLinksDTO(video, audio, mpd);
  }

  @override
  String toString() {
    return 'video: $video, audio: $audio, mpd: $mpd';
  }
}
