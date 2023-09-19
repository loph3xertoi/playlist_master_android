import '../entities/dto/basic_pms_user_info_dto.dart';
import '../entities/pms/pms_user.dart';

class UserInfo {
  /// Basic user info dto of current user.
  static BasicPMSUserInfoDTO? basicUser;

  /// Current pms user.
  static PMSUser? pmsUser;

  /// User id of current user.
  static String uid = '0';
}
