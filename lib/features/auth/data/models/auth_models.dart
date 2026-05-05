class AuthUserModel {
  const AuthUserModel({
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

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
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

class SignUpRequestModel {
  const SignUpRequestModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.bio,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String confirmPassword;
  final String? bio;

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      if (bio != null && bio!.isNotEmpty) 'bio': bio,
    };
  }
}

class SignUpResponseModel {
  const SignUpResponseModel({
    required this.message,
    required this.user,
  });

  final String message;
  final AuthUserModel user;

  factory SignUpResponseModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? {};
    final userJson = (data['user'] as Map<String, dynamic>?) ?? {};
    return SignUpResponseModel(
      message: (json['message'] ?? '').toString(),
      user: AuthUserModel.fromJson(userJson),
    );
  }
}

class SignInRequestModel {
  const SignInRequestModel({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class SignInResponseModel {
  const SignInResponseModel({
    required this.message,
    required this.accessToken,
  });

  final String message;
  final String accessToken;

  factory SignInResponseModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? {};
    return SignInResponseModel(
      message: (json['message'] ?? '').toString(),
      accessToken: (data['access_token'] ?? '').toString(),
    );
  }
}

class LogoutResponseModel {
  const LogoutResponseModel({
    required this.message,
  });

  final String message;

  factory LogoutResponseModel.fromJson(Map<String, dynamic> json) {
    return LogoutResponseModel(
      message: (json['message'] ?? '').toString(),
    );
  }
}
