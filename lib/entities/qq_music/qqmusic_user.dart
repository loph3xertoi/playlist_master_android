// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';

import '../basic/basic_user.dart';

/// User for qq music.
@immutable
class QQMusicUser extends BasicUser {
  const QQMusicUser(
    this.qqNumber,
    this.lvPic,
    this.listenPic,
    this.visitorNum,
    this.fansNum,
    this.followNum,
    this.friendsNum, {
    required super.name,
    required super.headPic,
    required super.bgPic,
  });

  /// The qq number of user.
  final String qqNumber;

  /// The icon for your qq music vip.
  final String lvPic;

  /// The icon of your listen level.
  final String listenPic;

  /// The number of people visited your homepage.
  final int visitorNum;

  /// The number of your qq music fans.
  final int fansNum;

  /// The number of people you are following.
  final int followNum;

  /// The number of qq friends.
  final int friendsNum;

  factory QQMusicUser.fromJson(Map<String, dynamic> json) {
    return QQMusicUser(
      json['qqNumber'].toString(),
      json['lvPic'],
      json['listenPic'],
      json['visitorNum'],
      json['fansNum'],
      json['followNum'],
      json['friendsNum'],
      name: json['name'],
      headPic: json['headPic'],
      bgPic: json['bgPic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'qqNumber': qqNumber,
      'headPic': headPic,
      'bgPic': bgPic,
      'lvPic': lvPic,
      'listenPic': listenPic,
      'visitorNum': visitorNum,
      'fansNum': fansNum,
      'followNum': followNum,
      'friendsNum': friendsNum
    };
  }

  @override
  String toString() {
    return 'QQMusicUser{name: $name, qqNumber: $qqNumber, headPic: $headPic, bgPic: $bgPic, lvPic: $lvPic, listenPic: $listenPic, visitorNum: $visitorNum, fansNum: $fansNum, followNum: $followNum, friendsNum: $friendsNum}';
  }

//   @override
//   String toString() {
//     String str = '''
// QQMusicUser{
//   name: $name,
//   headPic: $headPic,
//   bgPic: $bgPic,
//   lvPic: $lvPic,
//   listenPic: $listenPic,
//   visitorNum: $visitorNum,
//   fansNum: $fansNum,
//   followNum: $followNum,
//   friendsNum: $friendsNum
// }
//     ''';
//     return str;
//   }
}
