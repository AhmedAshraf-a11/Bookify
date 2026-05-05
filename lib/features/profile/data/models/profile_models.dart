class ProfileUserModel {
  const ProfileUserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.bio,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? bio;

  factory ProfileUserModel.fromJson(Map<String, dynamic> json) {
    return ProfileUserModel(
      id: (json['_id'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      bio: json['bio']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'bio': bio,
    };
  }
}

class GetProfileResponseModel {
  const GetProfileResponseModel({
    required this.message,
    required this.user,
    required this.favoriteCount,
    required this.bookCount,
  });

  final String message;
  final ProfileUserModel user;
  final int favoriteCount;
  final int bookCount;

  factory GetProfileResponseModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? {};
    return GetProfileResponseModel(
      message: (json['message'] ?? '').toString(),
      user: ProfileUserModel.fromJson((data['user'] as Map<String, dynamic>?) ?? {}),
      favoriteCount: _asInt(data['favoriteCount']),
      bookCount: _asInt(data['bookCount']),
    );
  }
}

class UpdateProfileRequestModel {
  const UpdateProfileRequestModel({
    this.firstName,
    this.lastName,
    this.bio,
  });

  final String? firstName;
  final String? lastName;
  final String? bio;

  Map<String, dynamic> toJson() {
    return {
      if (firstName != null && firstName!.isNotEmpty) 'firstName': firstName,
      if (lastName != null && lastName!.isNotEmpty) 'lastName': lastName,
      if (bio != null && bio!.isNotEmpty) 'bio': bio,
    };
  }
}

class UpdateProfileResponseModel {
  const UpdateProfileResponseModel({
    required this.message,
    required this.user,
  });

  final String message;
  final ProfileUserModel user;

  factory UpdateProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponseModel(
      message: (json['message'] ?? '').toString(),
      user: ProfileUserModel.fromJson((json['data'] as Map<String, dynamic>?) ?? {}),
    );
  }
}

class DeleteProfileResponseModel {
  const DeleteProfileResponseModel({
    required this.message,
  });

  final String message;

  factory DeleteProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return DeleteProfileResponseModel(
      message: (json['message'] ?? '').toString(),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
