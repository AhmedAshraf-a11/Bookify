import '../../../../core/constants/api_endpoints.dart';

class ProgressRemoteEndpoints {
  const ProgressRemoteEndpoints._();

  static Uri createProgress(String bookId) => ApiEndpoints.startReadingUri(bookId);
  static Uri updateProgress(String bookId) =>
      ApiEndpoints.updateReadingProgressUri(bookId);
}
