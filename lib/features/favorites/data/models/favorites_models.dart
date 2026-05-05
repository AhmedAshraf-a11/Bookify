class FavoriteItemModel {
  const FavoriteItemModel({
    required this.id,
    required this.userId,
    required this.bookId,
  });

  final String id;
  final String userId;
  final String bookId;

  factory FavoriteItemModel.fromJson(Map<String, dynamic> json) {
    return FavoriteItemModel(
      id: (json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      bookId: (json['bookId'] ?? '').toString(),
    );
  }
}

class AddToFavoritesResponseModel {
  const AddToFavoritesResponseModel({
    required this.message,
    required this.favorite,
  });

  final String message;
  final FavoriteItemModel favorite;

  factory AddToFavoritesResponseModel.fromJson(Map<String, dynamic> json) {
    return AddToFavoritesResponseModel(
      message: (json['message'] ?? '').toString(),
      favorite: FavoriteItemModel.fromJson((json['data'] as Map<String, dynamic>?) ?? {}),
    );
  }
}

class RemoveFromFavoritesResponseModel {
  const RemoveFromFavoritesResponseModel({
    required this.message,
  });

  final String message;

  factory RemoveFromFavoritesResponseModel.fromJson(Map<String, dynamic> json) {
    return RemoveFromFavoritesResponseModel(
      message: (json['message'] ?? '').toString(),
    );
  }
}
