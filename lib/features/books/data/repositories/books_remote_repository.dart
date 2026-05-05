import '../../../../core/network/api_client.dart';
import '../datasources/books_remote_endpoints.dart';
import '../models/books_models.dart';

class BooksRemoteRepository {
  const BooksRemoteRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<AddBookResponseModel> addBook(
    AddBookRequestModel request, {
    String? imagePath,
    String? pdfPath,
  }) async {
    final json = await _apiClient.postMultipart(
      BooksRemoteEndpoints.addBook(),
      fields: request.toJson(),
      imagePath: imagePath,
      pdfPath: pdfPath,
    );
    return AddBookResponseModel.fromJson(json);
  }

  Future<EditBookResponseModel> editBook(
    String bookId,
    EditBookRequestModel request,
  ) async {
    final json = await _apiClient.patch(
      BooksRemoteEndpoints.editBook(bookId),
      body: request.toJson(),
    );
    return EditBookResponseModel.fromJson(json);
  }

  Future<GetBookResponseModel> getBook(String bookId) async {
    final json = await _apiClient.get(BooksRemoteEndpoints.getBook(bookId));
    return GetBookResponseModel.fromJson(json);
  }

  Future<DeleteBookResponseModel> deleteBook(String bookId) async {
    final json = await _apiClient.delete(
      BooksRemoteEndpoints.deleteBook(bookId),
    );
    return DeleteBookResponseModel.fromJson(json);
  }

  Future<GetBooksByCategoryResponseModel> getBooksByCategory({
    String? category,
    int? page,
    int? limit,
  }) async {
    final json = await _apiClient.get(
      BooksRemoteEndpoints.getBooksByCategory(
        category: category,
        page: page,
        limit: limit,
      ),
    );
    return GetBooksByCategoryResponseModel.fromJson(json);
  }
}
