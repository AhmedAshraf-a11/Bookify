class TotalProgressModel {
  const TotalProgressModel({
    required this.completed,
    required this.totalFavorites,
    required this.percentage,
  });

  final int completed;
  final int totalFavorites;
  final int percentage;

  factory TotalProgressModel.fromJson(Map<String, dynamic> json) {
    return TotalProgressModel(
      completed: _asInt(json['completed']),
      totalFavorites: _asInt(json['totalFavorites']),
      percentage: _asInt(json['percentage']),
    );
  }
}

class GetTotalProgressResponseModel {
  const GetTotalProgressResponseModel({
    required this.message,
    required this.progress,
  });

  final String message;
  final TotalProgressModel progress;

  factory GetTotalProgressResponseModel.fromJson(Map<String, dynamic> json) {
    return GetTotalProgressResponseModel(
      message: (json['message'] ?? '').toString(),
      progress: TotalProgressModel.fromJson((json['data'] as Map<String, dynamic>?) ?? {}),
    );
  }
}

class HomeFavoriteBookModel {
  const HomeFavoriteBookModel({
    required this.id,
    required this.title,
    required this.description,
    required this.totalPages,
    required this.category,
    this.imageUrl,
    this.imagePublicId,
    this.pdfUrl,
    this.pdfPublicId,
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final int totalPages;
  final String category;
  final String? imageUrl;
  final String? imagePublicId;
  final String? pdfUrl;
  final String? pdfPublicId;
  final String? createdAt;

  factory HomeFavoriteBookModel.fromJson(Map<String, dynamic> json) {
    final image = (json['image'] as Map<String, dynamic>?) ?? {};
    final pdf = (json['pdf'] as Map<String, dynamic>?) ?? {};
    return HomeFavoriteBookModel(
      id: (json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      totalPages: _asInt(json['totalPages']),
      category: (json['category'] ?? '').toString(),
      imageUrl: image['secure_url']?.toString(),
      imagePublicId: image['public_id']?.toString(),
      pdfUrl: pdf['secure_url']?.toString(),
      pdfPublicId: pdf['public_id']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class HomeFavoritesDataModel {
  const HomeFavoritesDataModel({
    required this.favoritesCount,
    required this.favorites,
  });

  final int favoritesCount;
  final List<HomeFavoriteBookModel> favorites;

  factory HomeFavoritesDataModel.fromJson(Map<String, dynamic> json) {
    final list = (json['favorites'] as List?) ?? const [];
    return HomeFavoritesDataModel(
      favoritesCount: _asInt(json['favoritesCount']),
      favorites: list
          .whereType<Map<String, dynamic>>()
          .map(HomeFavoriteBookModel.fromJson)
          .toList(),
    );
  }
}

class GetHomeFavoritesResponseModel {
  const GetHomeFavoritesResponseModel({
    required this.message,
    required this.data,
  });

  final String message;
  final HomeFavoritesDataModel data;

  factory GetHomeFavoritesResponseModel.fromJson(Map<String, dynamic> json) {
    return GetHomeFavoritesResponseModel(
      message: (json['message'] ?? '').toString(),
      data: HomeFavoritesDataModel.fromJson((json['data'] as Map<String, dynamic>?) ?? {}),
    );
  }
}

class CurrentlyReadingItemModel {
  const CurrentlyReadingItemModel({
    required this.book,
    required this.pages,
    required this.percentage,
  });

  final HomeFavoriteBookModel book;
  final String pages;
  final int percentage;

  factory CurrentlyReadingItemModel.fromJson(Map<String, dynamic> json) {
    return CurrentlyReadingItemModel(
      book: HomeFavoriteBookModel.fromJson((json['book'] as Map<String, dynamic>?) ?? {}),
      pages: (json['pages'] ?? '').toString(),
      percentage: _asInt(json['percentage']),
    );
  }
}

class GetCurrentlyReadingResponseModel {
  const GetCurrentlyReadingResponseModel({
    required this.message,
    required this.items,
  });

  final String message;
  final List<CurrentlyReadingItemModel> items;

  factory GetCurrentlyReadingResponseModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as List?) ?? const [];
    return GetCurrentlyReadingResponseModel(
      message: (json['message'] ?? '').toString(),
      items: data
          .whereType<Map<String, dynamic>>()
          .map(CurrentlyReadingItemModel.fromJson)
          .toList(),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
