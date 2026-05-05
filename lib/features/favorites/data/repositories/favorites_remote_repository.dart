import '../../../../core/network/api_client.dart';
import '../datasources/favorites_remote_endpoints.dart';
import '../models/favorites_models.dart';

class FavoritesRemoteRepository {
  const FavoritesRemoteRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<AddToFavoritesResponseModel> addToFavorites(String bookId) async {
    final json = await _apiClient.post(FavoritesRemoteEndpoints.addToFavorites(bookId));
    return AddToFavoritesResponseModel.fromJson(json);
  }

  Future<RemoveFromFavoritesResponseModel> removeFromFavorites(String bookId) async {
    final json = await _apiClient.delete(
      FavoritesRemoteEndpoints.removeFromFavorites(bookId),
    );
    return RemoveFromFavoritesResponseModel.fromJson(json);
  }
}
