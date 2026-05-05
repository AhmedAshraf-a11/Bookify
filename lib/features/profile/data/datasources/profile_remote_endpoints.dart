import '../../../../core/constants/api_endpoints.dart';

class ProfileRemoteEndpoints {
  const ProfileRemoteEndpoints._();

  static Uri getProfile() => ApiEndpoints.getProfileUri();
  static Uri updateProfile() => ApiEndpoints.updateProfileUri();
  static Uri deleteProfile() => ApiEndpoints.deleteProfileUri();
}
