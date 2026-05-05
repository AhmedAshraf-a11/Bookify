import '../../../../core/network/api_client.dart';
import '../datasources/home_remote_endpoints.dart';
import '../models/home_models.dart';

class HomeRemoteRepository {
  const HomeRemoteRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<GetTotalProgressResponseModel> getTotalProgress() async {
    final json = await _apiClient.get(HomeRemoteEndpoints.totalProgress());
    return GetTotalProgressResponseModel.fromJson(json);
  }

  Future<GetHomeFavoritesResponseModel> getFavorites() async {
    final json = await _apiClient.get(HomeRemoteEndpoints.favorites());
    return GetHomeFavoritesResponseModel.fromJson(json);
  }

  Future<GetCurrentlyReadingResponseModel> getCurrentlyReading() async {
    final json = await _apiClient.get(HomeRemoteEndpoints.currentlyReading());
    return GetCurrentlyReadingResponseModel.fromJson(json);
  }
}
