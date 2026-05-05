import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/sign_up_screen.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../app_auth_session.dart';
import '../../features/books/presentation/pages/edit_book_screen.dart';
import '../../features/home/presentation/screens/home_page.dart';
import '../../features/books/presentation/pages/book_details_page.dart';
import '../../features/books/presentation/pages/pdf_viewer_page.dart';
import '../../features/library/presentation/pages/library_screen.dart';
import '../../features/add_book/presentation/pages/add_book_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/progress/presentation/pages/reading_progress_page.dart';
import '../../shared/widgets/main_bottom_nav_shell.dart';

class AppRoutePaths {
  static const String root = '/';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String home = '/home';
  static const String library = '/library';
  static const String addBook = '/add-book';
  static const String profile = '/profile';
  static const String editBook = 'edit-book/:bookId';
  static const String readingProgress = 'reading-progress/:bookId';
  static const String pdfViewer = 'pdf-viewer';
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _libraryNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _addBookNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _profileNavigatorKey =
    GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutePaths.root,
  overridePlatformDefaultLocation: true,
  redirect: (context, state) {
    final String path = state.uri.path;
    final String? token = appAuthSession.accessToken;
    final bool isLoggedIn = token != null && token.isNotEmpty;

    final bool isAuthScreen =
        path == AppRoutePaths.login ||
        path == AppRoutePaths.signUp ||
        path == AppRoutePaths.splash;

    final bool isProtected =
        path.startsWith(AppRoutePaths.home) ||
        path.startsWith(AppRoutePaths.library) ||
        path.startsWith(AppRoutePaths.addBook) ||
        path.startsWith(AppRoutePaths.profile);

    // If not authenticated, don't allow entering protected screens.
    if (!isLoggedIn && isProtected) {
      return AppRoutePaths.login;
    }

    // If authenticated, don't keep user on auth screens.
    if (isLoggedIn && isAuthScreen) {
      return AppRoutePaths.home;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutePaths.root,
      redirect: (context, state) => AppRoutePaths.splash,
    ),
    GoRoute(
      path: AppRoutePaths.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.signUp,
      builder: (context, state) => const SignUpScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainBottomNavShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutePaths.home,
              builder: (context, state) => const HomePage(),
              routes: [
                GoRoute(
                  path: 'book-details/:bookId',
                  builder: (context, state) {
                    final bookId = state.pathParameters['bookId'];
                    return BookDetailsPage(bookId: bookId ?? '');
                  },
                ),
                GoRoute(
                  path: 'edit-book/:bookId',
                  builder: (context, state) {
                    final bookId = state.pathParameters['bookId'];
                    return EditBookScreen(bookId: bookId ?? '');
                  },
                ),
                GoRoute(
                  path: 'reading-progress/:bookId',
                  builder: (context, state) {
                    final bookId = state.pathParameters['bookId'] ?? '';
                    return ReadingProgressPage(bookId: bookId);
                  },
                ),
                GoRoute(
                  path: 'pdf-viewer',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>?;
                    return PdfViewerPage(
                      pdfUrl: extra?['pdfUrl'] as String? ?? '',
                      bookId: extra?['bookId'] as String?,
                      totalPages: extra?['totalPages'] as int?,
                      lastPage: extra?['lastPage'] as int?,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _libraryNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutePaths.library,
              builder: (context, state) => const LibraryScreen(),
              routes: [
                GoRoute(
                  path: 'book-details/:bookId',
                  builder: (context, state) {
                    final bookId = state.pathParameters['bookId'];
                    return BookDetailsPage(bookId: bookId ?? '');
                  },
                ),
                GoRoute(
                  path: 'edit-book/:bookId',
                  builder: (context, state) {
                    final bookId = state.pathParameters['bookId'];
                    return EditBookScreen(bookId: bookId ?? '');
                  },
                ),
                GoRoute(
                  path: 'pdf-viewer',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>?;
                    return PdfViewerPage(
                      pdfUrl: extra?['pdfUrl'] as String? ?? '',
                      bookId: extra?['bookId'] as String?,
                      totalPages: extra?['totalPages'] as int?,
                      lastPage: extra?['lastPage'] as int?,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _addBookNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutePaths.addBook,
              builder: (context, state) => const AddBookScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutePaths.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
