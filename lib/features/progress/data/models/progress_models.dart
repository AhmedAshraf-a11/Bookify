class ReadingProgressModel {
  const ReadingProgressModel({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.currentPage,
    required this.status,
  });

  final String id;
  final String userId;
  final String bookId;
  final int currentPage;
  final String status;

  factory ReadingProgressModel.fromJson(Map<String, dynamic> json) {
    return ReadingProgressModel(
      id: (json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      bookId: (json['bookId'] ?? '').toString(),
      currentPage: _asInt(json['currentPage']),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class CreateProgressResponseModel {
  const CreateProgressResponseModel({
    required this.message,
    required this.progress,
  });

  final String message;
  final ReadingProgressModel progress;

  factory CreateProgressResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateProgressResponseModel(
      message: (json['message'] ?? '').toString(),
      progress:
          ReadingProgressModel.fromJson((json['data'] as Map<String, dynamic>?) ?? {}),
    );
  }
}

class UpdateProgressRequestModel {
  const UpdateProgressRequestModel({
    required this.currentPage,
  });

  final int currentPage;

  Map<String, dynamic> toJson() {
    return {'currentPage': currentPage};
  }
}

class ProgressBookModel {
  const ProgressBookModel({
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

  factory ProgressBookModel.fromJson(Map<String, dynamic> json) {
    final image = (json['image'] as Map<String, dynamic>?) ?? {};
    final pdf = (json['pdf'] as Map<String, dynamic>?) ?? {};
    return ProgressBookModel(
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

class DetailedReadingProgressModel {
  const DetailedReadingProgressModel({
    required this.id,
    required this.userId,
    required this.book,
    required this.currentPage,
    required this.status,
  });

  final String id;
  final String userId;
  final ProgressBookModel book;
  final int currentPage;
  final String status;

  factory DetailedReadingProgressModel.fromJson(Map<String, dynamic> json) {
    return DetailedReadingProgressModel(
      id: (json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      book: ProgressBookModel.fromJson((json['bookId'] as Map<String, dynamic>?) ?? {}),
      currentPage: _asInt(json['currentPage']),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class UpdateProgressResponseModel {
  const UpdateProgressResponseModel({
    required this.message,
    required this.progress,
    required this.percentage,
  });

  final String message;
  final DetailedReadingProgressModel progress;
  final int percentage;

  factory UpdateProgressResponseModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? {};
    return UpdateProgressResponseModel(
      message: (json['message'] ?? '').toString(),
      progress: DetailedReadingProgressModel.fromJson(
        (data['progress'] as Map<String, dynamic>?) ?? {},
      ),
      percentage: _asInt(data['percentage']),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
