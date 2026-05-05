import '../../../../core/network/api_client.dart';
import '../datasources/progress_remote_endpoints.dart';
import '../models/progress_models.dart';

class ProgressRemoteRepository {
  const ProgressRemoteRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<CreateProgressResponseModel> createProgress(String bookId) async {
    final json = await _apiClient.post(ProgressRemoteEndpoints.createProgress(bookId));
    return CreateProgressResponseModel.fromJson(json);
  }

  Future<UpdateProgressResponseModel> updateProgress(
    String bookId,
    UpdateProgressRequestModel request,
  ) async {
    final json = await _apiClient.patch(
      ProgressRemoteEndpoints.updateProgress(bookId),
      body: request.toJson(),
    );
    return UpdateProgressResponseModel.fromJson(json);
  }
}
