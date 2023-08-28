import 'package:flutter/foundation.dart';

import '../basic/basic_user.dart';
import '../bilibili/bili_user.dart';
import '../netease_cloud_music/ncm_user.dart';
import '../qq_music/qqmusic_user.dart';

/// User for pms.
@immutable
class PMSUser extends BasicUser {
  const PMSUser(
    this.id,
    this.intro,
    this.subUsers, {
    required super.name,
    required super.headPic,
    required super.bgPic,
  });

  /// User id in playlist master server.
  final int id;

  /// Description of pms user.
  final String intro;

  /// All managed sub users in playlist master server.
  final Map<String, BasicUser> subUsers;

  factory PMSUser.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> subUsersJson = json['subUsers'];
    Map<String, BasicUser> subUsers = {};

    if (subUsersJson.containsKey('qqmusic')) {
      subUsers.putIfAbsent(
          'qqmusic', () => QQMusicUser.fromJson(subUsersJson['qqmusic']));
    }
    if (subUsersJson.containsKey('ncm')) {
      subUsers.putIfAbsent('ncm', () => NCMUser.fromJson(subUsersJson['ncm']));
    }
    if (subUsersJson.containsKey('bilibili')) {
      subUsers.putIfAbsent(
          'bilibili', () => BiliUser.fromJson(subUsersJson['bilibili']));
    }

    return PMSUser(
      json['id'],
      json['intro'],
      subUsers,
      name: json['name'],
      headPic: json['headPic'],
      bgPic: json['bgPic'],
    );
  }

  @override
  String toString() {
    return 'PMSUser{id: $id, intro: $intro, subUsers: $subUsers, name: $name, headPic: $headPic, bgPic: $bgPic}';
  }
}
