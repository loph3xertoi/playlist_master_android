// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';

import '../basic/basic_user.dart';

/// User for bilibili.
@immutable
class BilibiliUser extends BasicUser {
  const BilibiliUser(
      this.mid,
      this.gender,
      this.sign,
      this.level,
      this.currentLevelExp,
      this.nextLevelExp,
      this.coins,
      this.bcoin,
      this.following,
      this.follower,
      this.dynamicCount,
      this.moral,
      this.bindEmail,
      this.bindPhone,
      this.vipType,
      this.vipActive,
      this.vipExpireTime,
      this.vipIcon,
      this.pendantName,
      this.pendantExpireTime,
      this.pendantImage,
      this.dynamicPendantImage,
      this.nameplateName,
      this.nameplateImage,
      this.smallNameplateImage,
      this.nameplateCondition,
      this.birthday,
      this.wearingFansBadge,
      this.fansBadgeLevel,
      this.fansBadgeText,
      this.fansBadgeStartColor,
      this.fansBadgeEndColor,
      this.fansBadgeBorderColor,
      this.ip,
      this.country,
      this.province,
      this.city,
      this.isp,
      this.latitude,
      this.longitude,
      this.countryCode,
      {required super.name,
      required super.headPic,
      required super.bgPic});

  /// User id in bilibili.
  final int mid;

  /// Your gender, 0 represents secret, 1 represents male, 2 represents female.
  final int gender;

  /// Your sign.
  final String sign;

  /// Your account's level in bilibili.
  final int level;

  /// Current level exp.
  final int currentLevelExp;

  /// Next level exp, if your level is 6, this value will be string "--".
  final int nextLevelExp;

  /// Your coins' count.
  final int coins;

  /// Your bcoin's count.
  final int bcoin;

  /// Upper you are following.
  final int following;

  /// Your follower's count.
  final int follower;

  /// Your dynamic count,
  final int dynamicCount;

  /// Your moral in bilibili.
  final int moral;

  /// Whether bind email.
  final bool bindEmail;

  /// Whether bind phone.
  final bool bindPhone;

  /// Vip type, 0 means no vip, 1 means month vip, 2 means year vip.
  final int vipType;

  /// Vip state.
  final bool vipActive;

  /// Expire time of your vip.
  final int vipExpireTime;

  /// The icon corresponding to your vip level.
  final String vipIcon;

  /// The pendant name.
  final String pendantName;

  /// The expired time of pendant.
  final int pendantExpireTime;

  /// The pendant image.
  final String pendantImage;

  /// The dynamic pendant image.
  final String dynamicPendantImage;

  /// The name of nameplate.
  final String nameplateName;

  /// The image of nameplate.
  final String nameplateImage;

  /// The small image of nameplate.
  final String smallNameplateImage;

  /// The obtaining condition of nameplate.
  final String nameplateCondition;

  /// Your birthday.
  final String birthday;

  /// Whether wearing fans badge.
  final bool wearingFansBadge;

  /// The level of your fans badge.
  final int fansBadgeLevel;

  /// The text of your fans badge.
  final String fansBadgeText;

  /// The start color of your fans badge.
  final int fansBadgeStartColor;

  /// The end color of your fans badge.
  final int fansBadgeEndColor;

  /// The border color of your fans badge.
  final int fansBadgeBorderColor;

  /// The ip address.
  final String ip;

  /// Your country.
  final String country;

  /// Your province.
  final String province;

  /// Your city.
  final String city;

  /// Your ISP, 0 represents china mobile, 1 represents china telecom.
  final int isp;

  /// Your latitude.
  final double latitude;

  /// Your longitude.
  final double longitude;

  /// Your country code.
  final int countryCode;

  factory BilibiliUser.fromJson(Map<String, dynamic> json) {
    return BilibiliUser(
      json['mid'],
      json['gender'],
      json['sign'],
      json['level'],
      json['currentLevelExp'],
      json['nextLevelExp'],
      json['coins'],
      json['bcoin'],
      json['following'],
      json['follower'],
      json['dynamicCount'],
      json['moral'],
      json['bindEmail'],
      json['bindPhone'],
      json['vipType'],
      json['vipActive'],
      json['vipExpireTime'],
      json['vipIcon'],
      json['pendantName'],
      json['pendantExpireTime'],
      json['pendantImage'],
      json['dynamicPendantImage'],
      json['nameplateName'],
      json['nameplateImage'],
      json['smallNameplateImage'],
      json['nameplateCondition'],
      json['birthday'],
      json['wearingFansBadge'],
      json['fansBadgeLevel'],
      json['fansBadgeText'],
      json['fansBadgeStartColor'],
      json['fansBadgeEndColor'],
      json['fansBadgeBorderColor'],
      json['ip'],
      json['country'],
      json['province'],
      json['city'],
      json['isp'],
      json['latitude'],
      json['longitude'],
      json['countryCode'],
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
      'mid': mid,
      'gender': gender,
      'sign': sign,
      'level': level,
      'currentLevelExp': currentLevelExp,
      'nextLevelExp': nextLevelExp,
      'coins': coins,
      'bcoin': bcoin,
      'following': following,
      'follower': follower,
      'dynamicCount': dynamicCount,
      'moral': moral,
      'bindEmail': bindEmail,
      'bindPhone': bindPhone,
      'vipType': vipType,
      'vipActive': vipActive,
      'vipExpireTime': vipExpireTime,
      'vipIcon': vipIcon,
      'pendantName': pendantName,
      'pendantExpireTime': pendantExpireTime,
      'pendantImage': pendantImage,
      'dynamicPendantImage': dynamicPendantImage,
      'nameplateName': nameplateName,
      'nameplateImage': nameplateImage,
      'smallNameplateImage': smallNameplateImage,
      'nameplateCondition': nameplateCondition,
      'birthday': birthday,
      'wearingFansBadge': wearingFansBadge,
      'fansBadgeLevel': fansBadgeLevel,
      'fansBadgeText': fansBadgeText,
      'fansBadgeStartColor': fansBadgeStartColor,
      'fansBadgeEndColor': fansBadgeEndColor,
      'fansBadgeBorderColor': fansBadgeBorderColor,
      'ip': ip,
      'country': country,
      'province': province,
      'city': city,
      'isp': isp,
      'latitude': latitude,
      'longitude': longitude,
      'countryCode': countryCode
    };
  }

  @override
  String toString() {
    return 'BilibiliUser{name: $name, headPic: $headPic, bgPic: $bgPic, mid: $mid, gender: $gender, sign: $sign, level: $level, currentLevelExp: $currentLevelExp, nextLevelExp: $nextLevelExp, coins: $coins, bcoin: $bcoin, following: $following, follower: $follower, dynamicCount: $dynamicCount, moral: $moral, bindEmail: $bindEmail, bindPhone: $bindPhone, vipType: $vipType, vipActive: $vipActive, vipExpireTime: $vipExpireTime, vipIcon: $vipIcon, pendantName: $pendantName, pendantExpireTime: $pendantExpireTime, pendantImage: $pendantImage, dynamicPendantImage: $dynamicPendantImage, nameplateName: $nameplateName, nameplateImage: $nameplateImage, smallNameplateImage: $smallNameplateImage, nameplateCondition: $nameplateCondition, birthday: $birthday, wearingFansBadge: $wearingFansBadge, fansBadgeLevel: $fansBadgeLevel, fansBadgeText: $fansBadgeText, fansBadgeStartColor: $fansBadgeStartColor, fansBadgeEndColor: $fansBadgeEndColor, fansBadgeBorderColor: $fansBadgeBorderColor, ip: $ip, country: $country, province: $province, city: $city, isp: $isp, latitude: $latitude, longitude: $longitude, countryCode: $countryCode}';
  }
}
