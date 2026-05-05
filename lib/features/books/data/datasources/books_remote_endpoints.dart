import '../../../../core/constants/api_endpoints.dart';

class BooksRemoteEndpoints {
  const BooksRemoteEndpoints._();

  static Uri addBook() => ApiEndpoints.addBookUri();
  static Uri editBook(String bookId) => ApiEndpoints.editBookUri(bookId);
  static Uri getBook(String bookId) => ApiEndpoints.getBookUri(bookId);
  static Uri deleteBook(String bookId) => ApiEndpoints.deleteBookUri(bookId);
  static Uri getBooksByCategory({String? category, int? page, int? limit}) =>
      ApiEndpoints.getBooksByCategoryUri(
        category: category,
        page: page,
        limit: limit,
      );
}
