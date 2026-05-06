import 'package:bookify/features/profile/data/repositories/profile_remote_repository.dart';

import '../network/api_client.dart';
import 'app_auth_session.dart';

import '../../features/auth/data/repositories/auth_remote_repository.dart';
import '../../features/books/data/repositories/books_remote_repository.dart';
import '../../features/favorites/data/repositories/favorites_remote_repository.dart';
import '../../features/home/data/repo/home_remote_repository.dart';
import '../../features/notes/data/repo/notes_remote_repository.dart';
import '../../features/progress/data/repositories/progress_remote_repository.dart';

final ApiClient apiClient = ApiClient(session: appAuthSession);

// Auth
final AuthRemoteRepository authRemoteRepository = AuthRemoteRepository(
  apiClient: apiClient,
  session: appAuthSession,
);

// Books / Home / Favorites
final BooksRemoteRepository booksRemoteRepository = BooksRemoteRepository(
  apiClient: apiClient,
);
final HomeRemoteRepository homeRemoteRepository = HomeRemoteRepository(
  apiClient: apiClient,
);
final FavoritesRemoteRepository favoritesRemoteRepository =
    FavoritesRemoteRepository(apiClient: apiClient);

// Notes
final NotesRemoteRepository notesRemoteRepository = NotesRemoteRepository(
  apiClient: apiClient,
);

// Progress (reading progress)
final ProgressRemoteRepository progressRemoteRepository =
    ProgressRemoteRepository(apiClient: apiClient);

final ProfileRemoteRepository profileRemoteRepository = ProfileRemoteRepository(
  apiClient: apiClient,
);