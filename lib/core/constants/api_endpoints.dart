class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'BOOKIFY_BASE_URL',
    defaultValue: 'http://13.219.191.61',
  );

  static Uri uri(String path, {Map<String, dynamic>? queryParameters}) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final cleanedQuery = <String, String>{};
    queryParameters?.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        cleanedQuery[key] = value.toString();
      }
    });

    return Uri.parse(
      '$baseUrl$normalizedPath',
    ).replace(queryParameters: cleanedQuery.isEmpty ? null : cleanedQuery);
  }
}

class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String signUp = '/auth/signup';
  static const String signIn = '/auth/signin';
  static const String logout = '/auth/logout';

  // User profile
  static const String getProfile = '/users/profile';
  static const String updateProfile = '/users/update-profile';
  static const String deleteProfile = '/users/delete-profile';

  // Books
  static const String addBook = '/books/add-book';
  static const String getBooksByCategory = '/books';

  // Favorites
  static const String addToFavoritesBase = '/favorites/add-to-favorites';
  static const String removeFromFavoritesBase =
      '/favorites/remove-from-favorites';

  // Reading progress
  static const String startReadingBase = '/progress/create-progress';
  static const String updateReadingProgressBase = '/progress/update-progress';

  // Home dashboard
  static const String homeTotalProgress = '/home/total-progress';
  static const String homeFavorites = '/home/favorites';
  static const String homeCurrentlyReading = '/home/currently-reading';

  // Notes
  static const String addNoteBase = '/note/add-note';
  static const String updateNoteBase = '/note/update-note';
  static const String deleteNoteBase = '/note/delete-note';

  // Dynamic path builders
  static String editBook(String bookId) => '/books/edit-book/$bookId';
  static String getBook(String bookId) => '/books/$bookId';
  static String deleteBook(String bookId) => '/books/$bookId';
  static String addToFavorites(String bookId) => '$addToFavoritesBase/$bookId';
  static String removeFromFavorites(String bookId) =>
      '$removeFromFavoritesBase/$bookId';
  static String startReading(String bookId) => '$startReadingBase/$bookId';
  static String updateReadingProgress(String bookId) =>
      '$updateReadingProgressBase/$bookId';
  static String addNote(String bookId) => '$addNoteBase/$bookId';
  static String updateNote(String noteId) => '$updateNoteBase/$noteId';
  static String deleteNote(String noteId) => '$deleteNoteBase/$noteId';

  // Dynamic URI builders
  static Uri signUpUri() => ApiConfig.uri(signUp);
  static Uri signInUri() => ApiConfig.uri(signIn);
  static Uri logoutUri({String? flag}) =>
      ApiConfig.uri(logout, queryParameters: {'flag': flag});

  static Uri getProfileUri() => ApiConfig.uri(getProfile);
  static Uri updateProfileUri() => ApiConfig.uri(updateProfile);
  static Uri deleteProfileUri() => ApiConfig.uri(deleteProfile);

  static Uri addBookUri() => ApiConfig.uri(addBook);
  static Uri editBookUri(String bookId) => ApiConfig.uri(editBook(bookId));
  static Uri getBookUri(String bookId) => ApiConfig.uri(getBook(bookId));
  static Uri deleteBookUri(String bookId) => ApiConfig.uri(deleteBook(bookId));
  static Uri getBooksByCategoryUri({String? category, int? page, int? limit}) =>
      ApiConfig.uri(
        getBooksByCategory,
        queryParameters: {
          'category': category,
          if (page != null) 'page': page.toString(),
          if (limit != null) 'limit': limit.toString(),
        },
      );

  static Uri addToFavoritesUri(String bookId) =>
      ApiConfig.uri(addToFavorites(bookId));
  static Uri removeFromFavoritesUri(String bookId) =>
      ApiConfig.uri(removeFromFavorites(bookId));

  static Uri startReadingUri(String bookId) =>
      ApiConfig.uri(startReading(bookId));
  static Uri updateReadingProgressUri(String bookId) =>
      ApiConfig.uri(updateReadingProgress(bookId));

  static Uri homeTotalProgressUri() => ApiConfig.uri(homeTotalProgress);
  static Uri homeFavoritesUri() => ApiConfig.uri(homeFavorites);
  static Uri homeCurrentlyReadingUri() => ApiConfig.uri(homeCurrentlyReading);

  static Uri addNoteUri(String bookId) => ApiConfig.uri(addNote(bookId));
  static Uri updateNoteUri(String noteId) => ApiConfig.uri(updateNote(noteId));
  static Uri deleteNoteUri(String noteId) => ApiConfig.uri(deleteNote(noteId));
}
