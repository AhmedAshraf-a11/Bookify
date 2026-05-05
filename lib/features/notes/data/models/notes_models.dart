class NoteModel {
  const NoteModel({
    required this.id,
    required this.userId,
    this.title,
    required this.content,
    this.bookId,
    this.page,
  });

  final String id;
  final String userId;
  final String? title;
  final String content;
  final String? bookId;
  final int? page;

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: (json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      title: json['title']?.toString(),
      content: (json['content'] ?? '').toString(),
      bookId: json['bookId']?.toString(),
      page: _asNullableInt(json['page']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      if (title != null) 'title': title,
      'content': content,
      'bookId': bookId,
      'page': page,
    };
  }
}

class AddNoteRequestModel {
  const AddNoteRequestModel({required this.content});

  final String content;

  Map<String, dynamic> toJson() {
    return {'content': content};
  }
}

class AddNoteResponseModel {
  const AddNoteResponseModel({required this.message, required this.note});

  final String message;
  final NoteModel note;

  factory AddNoteResponseModel.fromJson(Map<String, dynamic> json) {
    return AddNoteResponseModel(
      message: (json['message'] ?? '').toString(),
      note: NoteModel.fromJson((json['data'] as Map<String, dynamic>?) ?? {}),
    );
  }
}

class GetGeneralNotesResponseModel {
  const GetGeneralNotesResponseModel({
    required this.message,
    required this.notes,
  });

  final String message;
  final List<NoteModel> notes;

  factory GetGeneralNotesResponseModel.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List?) ?? const [];
    return GetGeneralNotesResponseModel(
      message: (json['message'] ?? '').toString(),
      notes: list
          .whereType<Map<String, dynamic>>()
          .map(NoteModel.fromJson)
          .toList(),
    );
  }
}

class GetBookNotesResponseModel {
  const GetBookNotesResponseModel({required this.message, required this.notes});

  final String message;
  final List<NoteModel> notes;

  factory GetBookNotesResponseModel.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List?) ?? const [];
    return GetBookNotesResponseModel(
      message: (json['message'] ?? '').toString(),
      notes: list
          .whereType<Map<String, dynamic>>()
          .map(NoteModel.fromJson)
          .toList(),
    );
  }
}

class UpdateNoteRequestModel {
  const UpdateNoteRequestModel({this.content});

  final String? content;

  Map<String, dynamic> toJson() {
    return {if (content != null && content!.isNotEmpty) 'content': content};
  }
}

class UpdateNoteResponseModel {
  const UpdateNoteResponseModel({required this.message, required this.note});

  final String message;
  final NoteModel note;

  factory UpdateNoteResponseModel.fromJson(Map<String, dynamic> json) {
    return UpdateNoteResponseModel(
      message: (json['message'] ?? '').toString(),
      note: NoteModel.fromJson((json['data'] as Map<String, dynamic>?) ?? {}),
    );
  }
}

class DeleteNoteResponseModel {
  const DeleteNoteResponseModel({required this.message});

  final String message;

  factory DeleteNoteResponseModel.fromJson(Map<String, dynamic> json) {
    return DeleteNoteResponseModel(message: (json['message'] ?? '').toString());
  }
}

int? _asNullableInt(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  return int.tryParse(value.toString());
}
