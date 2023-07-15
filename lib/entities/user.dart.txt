/// Basic user information on local playlist master server.
class User {
  const User({
    required this.name,
    required this.headPic,
    required this.bgPic,
    required this.numberOfPlatforms,
    this.userInfos,
  });

  final String name;
  final String headPic;
  final String bgPic;

  /// The number of music platforms managed by pm.
  final int numberOfPlatforms;

  /// User information of all managed platforms.
  final List<dynamic>? userInfos;

  // factory User.fromJson(Map<String, dynamic> json) {
  //   return User(
  //     name: json['name'],
  //     headPic: json['headPic'],
  //     bgPic: json['bgPic'],
  //   );
  // }
}
