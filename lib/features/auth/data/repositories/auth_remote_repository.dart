import '../../../../core/network/api_client.dart';
import '../../../../core/network/auth_session.dart';
import '../datasources/auth_remote_endpoints.dart';
import '../models/auth_models.dart';

class AuthRemoteRepository {
  AuthRemoteRepository({
    required ApiClient apiClient,
    required AuthSession session,
  })  : _apiClient = apiClient,
        _session = session;

  final ApiClient _apiClient;
  final AuthSession _session;

  Future<SignUpResponseModel> signUp(SignUpRequestModel request) async {
    final json = await _apiClient.post(
      AuthRemoteEndpoints.signUp(),
      body: request.toJson(),
      requiresAuth: false,
    );
    return SignUpResponseModel.fromJson(json);
  }

  Future<SignInResponseModel> signIn(SignInRequestModel request) async {
    final json = await _apiClient.post(
      AuthRemoteEndpoints.signIn(),
      body: request.toJson(),
      requiresAuth: false,
    );
    final response = SignInResponseModel.fromJson(json);
    await _session.setAccessToken(response.accessToken);
    return response;
  }

  Future<LogoutResponseModel> logout({String? flag}) async {
    final json = await _apiClient.post(
      AuthRemoteEndpoints.logout(flag: flag),
    );
    final response = LogoutResponseModel.fromJson(json);
    await _session.clear();
    return response;
  }
}
