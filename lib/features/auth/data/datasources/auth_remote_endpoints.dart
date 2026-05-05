import '../../../../core/constants/api_endpoints.dart';

class AuthRemoteEndpoints {
  const AuthRemoteEndpoints._();

  static Uri signUp() => ApiEndpoints.signUpUri();
  static Uri signIn() => ApiEndpoints.signInUri();
  static Uri logout({String? flag}) => ApiEndpoints.logoutUri(flag: flag);
}
