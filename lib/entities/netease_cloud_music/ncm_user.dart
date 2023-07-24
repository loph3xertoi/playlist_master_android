// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';

import '../basic/basic_user.dart';

/// User for ncm.
@immutable
class NCMUser extends BasicUser {
  const NCMUser(
      this.id,
      this.level,
      this.listenSongs,
      this.follows,
      this.fans,
      this.playlistCount,
      this.createTime,
      this.vipType,
      this.redVipLevel,
      this.redVipExpireTime,
      this.redVipLevelIcon,
      this.redVipDynamicIconUrl,
      this.redVipDynamicIconUrl2,
      this.musicPackageVipLevel,
      this.musicPackageVipExpireTime,
      this.musicPackageVipLevelIcon,
      this.redPlusVipLevel,
      this.redPlusVipExpireTime,
      this.redPlusVipLevelIcon,
      this.signature,
      this.birthday,
      this.gender,
      this.province,
      this.city,
      this.lastLoginTime,
      this.lastLoginIP,
      {required super.name,
      required super.headPic,
      required super.bgPic});

  /// User id for netease cloud music.
  final int id;

  /// Your netease cloud music level.
  final int level;

  /// Total listened songs' number.
  final int listenSongs;

  /// The number of people you are following.
  final int follows;

  /// The number of your fans.
  final int fans;

  /// The count of all your playlists.
  final int playlistCount;

  /// User creating time.
  final int createTime;

  /// User vip type, 0 means no vip.
  final int vipType;

  /// Your red vip level.
  final int redVipLevel;

  /// Expire time of your red vip.
  final int redVipExpireTime;

  /// The icon corresponding to your red vip level.
  final String redVipLevelIcon;

  /// Dynamic icon for your red vip.
  final String redVipDynamicIconUrl;

  /// Dynamic icon2 for your red vip.
  final String redVipDynamicIconUrl2;

  /// Your music package vip level.
  final int musicPackageVipLevel;

  /// Expire time of your music package vip.
  final int musicPackageVipExpireTime;

  /// The icon corresponding to your music package vip level.
  final String musicPackageVipLevelIcon;

  /// Your red plus vip level.
  final int redPlusVipLevel;

  /// Expire time of your red plus vip.
  final int redPlusVipExpireTime;

  /// The icon corresponding to your red plus vip level.
  final String redPlusVipLevelIcon;

  /// Your signature.
  final String signature;

  /// Your birthday.
  final int birthday;

  /// Your gender, secret :0, male: 1, female: 2.
  final int gender;

  /// Province region code.
  final int province;

  /// City region code.
  final int city;

  /// Last login time.
  final int lastLoginTime;

  /// Last login IP.
  final String lastLoginIP;

  factory NCMUser.fromJson(Map<String, dynamic> json) {
    return NCMUser(
      json['id'],
      json['level'],
      json['listenSongs'],
      json['follows'],
      json['fans'],
      json['playlistCount'],
      json['createTime'],
      json['vipType'],
      json['redVipLevel'],
      json['redVipExpireTime'],
      json['redVipLevelIcon'],
      json['redVipDynamicIconUrl'],
      json['redVipDynamicIconUrl2'],
      json['musicPackageVipLevel'],
      json['musicPackageVipExpireTime'],
      json['musicPackageVipLevelIcon'],
      json['redPlusVipLevel'],
      json['redPlusVipExpireTime'],
      json['redPlusVipLevelIcon'],
      json['signature'],
      json['birthday'],
      json['gender'],
      json['province'],
      json['city'],
      json['lastLoginTime'],
      json['lastLoginIP'],
      name: json['name'],
      headPic: json['headPic'],
      bgPic: json['bgPic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'headPic': headPic,
      'bgPic': bgPic,
      'id': id,
      'level': level,
      'listenSongs': listenSongs,
      'follows': follows,
      'fans': fans,
      'playlistCount': playlistCount,
      'createTime': createTime,
      'vipType': vipType,
      'redVipLevel': redVipLevel,
      'redVipExpireTime': redVipExpireTime,
      'redVipLevelIcon': redVipLevelIcon,
      'redVipDynamicIconUrl': redVipDynamicIconUrl,
      'redVipDynamicIconUrl2': redVipDynamicIconUrl2,
      'musicPackageVipLevel': musicPackageVipLevel,
      'musicPackageVipExpireTime': musicPackageVipExpireTime,
      'musicPackageVipLevelIcon': musicPackageVipLevelIcon,
      'redPlusVipLevel': redPlusVipLevel,
      'redPlusVipExpireTime': redPlusVipExpireTime,
      'redPlusVipLevelIcon': redPlusVipLevelIcon,
      'signature': signature,
      'birthday': birthday,
      'gender': gender,
      'province': province,
      'city': city,
      'lastLoginTime': lastLoginTime,
      'lastLoginIP': lastLoginIP
    };
  }

  @override
  String toString() {
    return 'NCMUser{name: $name, headPic: $headPic, bgPic: $bgPic, id: $id, level: $level, listenSongs: $listenSongs, follows: $follows, fans: $fans, playlistCount: $playlistCount, craeteTime: $createTime, vipType: $vipType, redVipLevel: $redVipLevel, redVipExpireTime: $redVipExpireTime, redVipLevelIcon: $redVipLevelIcon, redVipDynamicIconUrl: $redVipDynamicIconUrl, redVipDynamicIconUrl2: $redVipDynamicIconUrl2, musicPackageVipLevel: $musicPackageVipLevel, musicPackageVipExpireTime: $musicPackageVipExpireTime, musicPackageVipLevelIcon: $musicPackageVipLevelIcon, redPlusVipLevel: $redPlusVipLevel, redPlusVipExpireTime: $redPlusVipExpireTime, redPlusVipLevelIcon: $redPlusVipLevelIcon, signature: $signature, birthday: $birthday, gender: $gender, province: $province, city: $city, lastLoginTime: $lastLoginTime, lastLoginIP: $lastLoginIP}';
  }
}
