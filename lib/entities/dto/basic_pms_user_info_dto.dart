/// DTO for basic pms user info.
class BasicPMSUserInfoDTO<T> {
  BasicPMSUserInfoDTO(
      this.id, this.name, this.role, this.email, this.phone, this.loginType);

  /// The id of pms user.
  final int id;

  /// User's name.
  final String name;

  /// User's role, include ROLE_USER, ROLE_ADMIN.
  final String role;

  /// User's email.
  String? email;

  /// User's phone number.
  final String? phone;

  /// Login type: 0 for email & password, 1 for GitHub, 2 for Google.
  final int loginType;

  factory BasicPMSUserInfoDTO.fromJson(Map<String, dynamic> json) {
    return BasicPMSUserInfoDTO(
      json['id'],
      json['name'],
      json['role'],
      json['email'],
      json['phone'],
      json['loginType'],
    );
  }
}
