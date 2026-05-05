import '../../../../core/network/api_client.dart';
import '../datasources/profile_remote_endpoints.dart';
import '../models/profile_models.dart';

class ProfileRemoteRepository {
  const ProfileRemoteRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<GetProfileResponseModel> getProfile() async {
    final json = await _apiClient.get(ProfileRemoteEndpoints.getProfile());
    return GetProfileResponseModel.fromJson(json);
  }

  Future<UpdateProfileResponseModel> updateProfile(
    UpdateProfileRequestModel request,
  ) async {
    final json = await _apiClient.patch(
      ProfileRemoteEndpoints.updateProfile(),
      body: request.toJson(),
    );
    return UpdateProfileResponseModel.fromJson(json);
  }

  Future<DeleteProfileResponseModel> deleteProfile() async {
    final json = await _apiClient.delete(ProfileRemoteEndpoints.deleteProfile());
    return DeleteProfileResponseModel.fromJson(json);
  }
}
