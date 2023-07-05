/// QQMusicUser basic information.
class QQMusicUser {
  const QQMusicUser({
    required this.name,
    required this.headPic,
    required this.lvPic,
    required this.listenPic,
    required this.bgPic,
    required this.visitorNum,
    required this.fansNum,
    required this.followNum,
    required this.friendsNum,
  });

  final String name;
  final String headPic;
  final String lvPic;
  final String listenPic;
  final String bgPic;
  final int visitorNum;
  final int fansNum;
  final int followNum;
  final int friendsNum;

  factory QQMusicUser.fromJson(Map<String, dynamic> json) {
    return QQMusicUser(
      name: json['name'],
      headPic: json['headPic'],
      lvPic: json['lvPic'],
      listenPic: json['listenPic'],
      bgPic: json['bgPic'],
      visitorNum: json['visitorNum'],
      fansNum: json['fansNum'],
      followNum: json['followNum'],
      friendsNum: json['friendsNum'],
    );
  }
}
