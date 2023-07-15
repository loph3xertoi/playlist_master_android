import 'package:flutter/foundation.dart';

import '../basic/basic_user.dart';
import '../qq_music/qqmusic_user.dart';

/// User for pms.
@immutable
class PMSUser extends BasicUser {
  const PMSUser(
    this.id,
    this.subUsers, {
    required super.name,
    required super.headPic,
    required super.bgPic,
  });

  /// User id in playlist master server.
  final String id;

  /// All managed sub users in playlist master server.
  final Map<String, BasicUser> subUsers;

  factory PMSUser.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> subUsersJson = json['subUsers'];
    Map<String, BasicUser> subUsers = {};

    // TODO: implement other two platform.
    if (subUsersJson.containsKey('qqmusic')) {
      subUsers.putIfAbsent(
          'qqmusic', () => QQMusicUser.fromJson(subUsersJson['qqmusic']));
    }

    return PMSUser(
      json['id'],
      subUsers,
      name: json['name'],
      headPic: json['headPic'],
      bgPic: json['bgPic'],
    );
  }
}
