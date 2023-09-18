/// DTO for basic pms user info.
class BasicPMSUserInfoDTO<T> {
  BasicPMSUserInfoDTO(
      this.id,
      this.name,
      this.role,
      this.email,
      this.phone,
      this.avatar,
      this.loginType,
      this.qqMusicId,
      this.qqMusicCookie,
      this.ncmId,
      this.ncmCookie,
      this.biliId,
      this.biliCookie);

  /// The id of pms user.
  final int id;

  /// User's name.
  String name;

  /// User's role, include ROLE_USER, ROLE_ADMIN.
  final String role;

  /// User's email.
  String? email;

  /// User's phone number.
  String? phone;

  /// User's avatar.
  String? avatar;

  /// Login type: 0 for email & password, 1 for GitHub, 2 for Google.
  final int loginType;

  /// User id in qqmusic.
  String? qqMusicId;

  /// User cookie in qqmusic
  String? qqMusicCookie;

  /// User id in ncm.
  String? ncmId;

  /// User cookie in ncm.
  String? ncmCookie;

  /// User id in bilibili.
  String? biliId;

  /// User cookie in bilibili.
  String? biliCookie;

  factory BasicPMSUserInfoDTO.fromJson(Map<String, dynamic> json) {
    return BasicPMSUserInfoDTO(
      json['id'],
      json['name'],
      json['role'],
      json['email'],
      json['phone'],
      json['avatar'],
      json['loginType'],
      json['qqMusicId'],
      json['qqMusicCookie'],
      json['ncmId'],
      json['ncmCookie'],
      json['biliId'],
      json['biliCookie'],
    );
  }
}
