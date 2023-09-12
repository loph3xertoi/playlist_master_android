/// DTO for basic pms user info.
class BasicPMSUserInfoDTO<T> {
  BasicPMSUserInfoDTO(this.id, this.name, this.role, this.email, this.phone);

  /// The id of pms user.
  final int id;

  /// User's name.
  final String name;

  /// User's role.
  final String role;

  /// User's email.
  String? email;

  /// User's phone number.
  final String? phone;

  factory BasicPMSUserInfoDTO.fromJson(Map<String, dynamic> json) {
    return BasicPMSUserInfoDTO(
      json['id'],
      json['name'],
      json['role'],
      json['email'],
      json['phone'],
    );
  }
}
