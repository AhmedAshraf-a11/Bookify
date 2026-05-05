import '../../../../core/constants/api_endpoints.dart';

class FavoritesRemoteEndpoints {
  const FavoritesRemoteEndpoints._();

  static Uri addToFavorites(String bookId) => ApiEndpoints.addToFavoritesUri(bookId);
  static Uri removeFromFavorites(String bookId) =>
      ApiEndpoints.removeFromFavoritesUri(bookId);
}
