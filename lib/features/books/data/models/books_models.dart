class MediaFileModel {
  const MediaFileModel({
    required this.secureUrl,
    required this.publicId,
  });

  final String secureUrl;
  final String publicId;

  factory MediaFileModel.fromJson(Map<String, dynamic> json) {
    return MediaFileModel(
      secureUrl: (json['secure_url'] ?? '').toString(),
      publicId: (json['public_id'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'secure_url': secureUrl,
      'public_id': publicId,
    };
  }
}

class BookModel {
  const BookModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.totalPages,
    required this.createdBy,
    this.image,
    this.pdf,
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final int totalPages;
  final String createdBy;
  final MediaFileModel? image;
  final MediaFileModel? pdf;
  final String? createdAt;

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: (json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      totalPages: _asInt(json['totalPages']),
      createdBy: (json['createdBy'] ?? '').toString(),
      image: json['image'] is Map<String, dynamic>
          ? MediaFileModel.fromJson(json['image'] as Map<String, dynamic>)
          : null,
      pdf: json['pdf'] is Map<String, dynamic>
          ? MediaFileModel.fromJson(json['pdf'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'category': category,
      'totalPages': totalPages,
      'createdBy': createdBy,
      'image': image?.toJson(),
      'pdf': pdf?.toJson(),
      'createdAt': createdAt,
    };
  }
}

class AddBookRequestModel {
  const AddBookRequestModel({
    required this.title,
    this.description,
    required this.category,
    this.totalPages,
  });

  final String title;
  final String? description;
  final String category;
  final int? totalPages;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null && description!.isNotEmpty) 'description': description,
      'category': category,
      if (totalPages != null) 'totalPages': totalPages,
    };
  }
}

class AddBookResponseModel {
  const AddBookResponseModel({
    required this.message,
    required this.book,
  });

  final String message;
  final BookModel book;

  factory AddBookResponseModel.fromJson(Map<String, dynamic> json) {
    return AddBookResponseModel(
      message: (json['message'] ?? '').toString(),
      book: BookModel.fromJson((json['data'] as Map<String, dynamic>?) ?? {}),
    );
  }
}

class EditBookRequestModel {
  const EditBookRequestModel({
    this.title,
    this.description,
    this.category,
    this.totalPages,
  });

  final String? title;
  final String? description;
  final String? category;
  final int? totalPages;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      if (totalPages != null) 'totalPages': totalPages,
    };
  }
}

class EditBookResponseModel {
  const EditBookResponseModel({
    required this.message,
    required this.book,
  });

  final String message;
  final BookModel book;

  factory EditBookResponseModel.fromJson(Map<String, dynamic> json) {
    return EditBookResponseModel(
      message: (json['message'] ?? '').toString(),
      book: BookModel.fromJson((json['data'] as Map<String, dynamic>?) ?? {}),
    );
  }
}

class BookNoteModel {
  const BookNoteModel({
    required this.id,
    required this.bookId,
    required this.userId,
    this.title,
    required this.content,
    this.page,
  });

  final String id;
  final String bookId;
  final String userId;
  final String? title;
  final String content;
  final int? page;

  factory BookNoteModel.fromJson(Map<String, dynamic> json) {
    return BookNoteModel(
      id: (json['_id'] ?? '').toString(),
      bookId: (json['bookId'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      title: json['title']?.toString(),
      content: (json['content'] ?? '').toString(),
      page: json['page'] is int ? json['page'] as int : int.tryParse(json['page']?.toString() ?? ''),
    );
  }
}

class BookProgressInfoModel {
  const BookProgressInfoModel({
    required this.percentage,
    required this.currentPage,
    required this.status,
  });

  final int percentage;
  final int currentPage;
  final String status;

  factory BookProgressInfoModel.fromJson(Map<String, dynamic> json) {
    return BookProgressInfoModel(
      percentage: _asInt(json['percentage']),
      currentPage: _asInt(json['currentPage']),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class GetBookResponseModel {
  const GetBookResponseModel({
    required this.message,
    required this.book,
    required this.notes,
    required this.progressInfo,
    required this.isFavorite,
  });

  final String message;
  final BookModel book;
  final List<BookNoteModel> notes;
  final BookProgressInfoModel? progressInfo;
  final bool isFavorite;

  factory GetBookResponseModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? {};
    final notesJson = (data['notes'] as List?) ?? const [];
    return GetBookResponseModel(
      message: (json['message'] ?? '').toString(),
      book: BookModel.fromJson((data['book'] as Map<String, dynamic>?) ?? {}),
      notes: notesJson
          .whereType<Map<String, dynamic>>()
          .map(BookNoteModel.fromJson)
          .toList(),
      progressInfo: data['progressInfo'] is Map<String, dynamic>
          ? BookProgressInfoModel.fromJson(
              data['progressInfo'] as Map<String, dynamic>,
            )
          : null,
      isFavorite: data['isFavorite'] == true,
    );
  }
}

class DeleteBookResponseModel {
  const DeleteBookResponseModel({
    required this.message,
  });

  final String message;

  factory DeleteBookResponseModel.fromJson(Map<String, dynamic> json) {
    return DeleteBookResponseModel(
      message: (json['message'] ?? '').toString(),
    );
  }
}

class GetBooksByCategoryResponseModel {
  const GetBooksByCategoryResponseModel({
    required this.message,
    required this.books,
  });

  final String message;
  final List<BookModel> books;

  factory GetBooksByCategoryResponseModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as List?) ?? const [];
    return GetBooksByCategoryResponseModel(
      message: (json['message'] ?? '').toString(),
      books: data.whereType<Map<String, dynamic>>().map(BookModel.fromJson).toList(),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
