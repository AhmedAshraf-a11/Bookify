import '../../../../core/constants/api_endpoints.dart';

class HomeRemoteEndpoints {
  const HomeRemoteEndpoints._();

  static Uri totalProgress() => ApiEndpoints.homeTotalProgressUri();
  static Uri favorites() => ApiEndpoints.homeFavoritesUri();
  static Uri currentlyReading() => ApiEndpoints.homeCurrentlyReadingUri();
}
