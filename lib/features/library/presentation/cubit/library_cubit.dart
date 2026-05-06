import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/utils/app_repositories.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../core/network/auth_session.dart';
import '../../../books/data/models/books_models.dart';

// States
abstract class LibraryState extends Equatable {
  const LibraryState();

  @override
  List<Object?> get props => [];
}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibraryLoaded extends LibraryState {
  final List<BookModel> books;
  final bool hasMore;
  final String? currentCategory;

  const LibraryLoaded({
    required this.books,
    this.hasMore = true,
    this.currentCategory,
  });

  @override
  List<Object?> get props => [books, hasMore, currentCategory];

  LibraryLoaded copyWith({
    List<BookModel>? books,
    bool? hasMore,
    String? currentCategory,
  }) {
    return LibraryLoaded(
      books: books ?? this.books,
      hasMore: hasMore ?? this.hasMore,
      currentCategory: currentCategory ?? this.currentCategory,
    );
  }
}

class LibraryError extends LibraryState {
  final String message;

  const LibraryError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit({required AuthSession authSession, this.onFavoritesRefresh})
    : _authSession = authSession,
      super(LibraryInitial());

  final AuthSession _authSession;
  final VoidCallback? onFavoritesRefresh;

  Future<void> loadLibraryBooks({
    String? category,
    int page = 1,
    int limit = 10,
  }) async {
    // Check authentication first
    if (!_isAuthenticated()) {
      emit(const LibraryError('Authentication required. Please log in again.'));
      return;
    }

    emit(LibraryLoading());

    try {
      // Handle "All" category by calling getAllBooks method
      if (category == 'All' || category == null) {
        if (kDebugMode) {
          print('Loading all books: page=$page, limit=$limit');
        }
        final response = await booksRemoteRepository.getAllBooks();
        emit(
          LibraryLoaded(
            books: response.books,
            hasMore: response.books.length == limit,
            currentCategory: 'All',
          ),
        );
        // Refresh favorites after loading books
        onFavoritesRefresh?.call();
        return;
      }

      if (kDebugMode) {
        print(
          'Loading library books: category=$category, page=$page, limit=$limit',
        );
      }

      final response = await booksRemoteRepository.getBooksByCategory(
        category: category,
        page: page,
        limit: limit,
      );

      if (kDebugMode) {
        print('Successfully loaded ${response.books.length} books');
      }

      emit(
        LibraryLoaded(
          books: response.books,
          hasMore: response.books.length == limit,
          currentCategory: category,
        ),
      );
      // Refresh favorites after loading books
      onFavoritesRefresh?.call();
    } on ApiException catch (e) {
      if (kDebugMode) {
        print('API Error loading library books: ${e.toString()}');
      }

      String errorMessage = _getErrorMessage(e.statusCode);
      emit(LibraryError(errorMessage));
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error loading library books: $e');
      }
      emit(LibraryError('Failed to load library books. Please try again.'));
    }
  }

  Future<void> loadMoreLibraryBooks({
    String? category,
    int page = 1,
    int limit = 10,
  }) async {
    if (state is! LibraryLoaded) return;

    // Check authentication first
    if (!_isAuthenticated()) {
      emit(const LibraryError('Authentication required. Please log in again.'));
      return;
    }

    final currentState = state as LibraryLoaded;
    if (!currentState.hasMore) return;

    try {
      final categoryParam = category == 'All' ? null : category;

      if (kDebugMode) {
        print(
          'Loading more library books: category=$categoryParam, page=$page, limit=$limit',
        );
      }

      final response = await booksRemoteRepository.getBooksByCategory(
        category: categoryParam,
        page: page,
        limit: limit,
      );

      if (kDebugMode) {
        print('Successfully loaded ${response.books.length} more books');
      }

      emit(
        currentState.copyWith(
          books: [...currentState.books, ...response.books],
          hasMore: response.books.length == limit,
        ),
      );
    } on ApiException catch (e) {
      if (kDebugMode) {
        print('API Error loading more library books: ${e.toString()}');
      }

      String errorMessage = _getErrorMessage(e.statusCode);
      emit(LibraryError(errorMessage));
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error loading more library books: $e');
      }
      emit(LibraryError('Failed to load more books. Please try again.'));
    }
  }

  Future<void> refreshLibraryBooks({String? category}) async {
    // Check authentication first
    if (!_isAuthenticated()) {
      emit(const LibraryError('Authentication required. Please log in again.'));
      return;
    }

    // Emit loading state for RefreshIndicator
    emit(LibraryLoading());

    try {
      final categoryParam = category == 'All' ? null : category;

      if (kDebugMode) {
        print('Refreshing library books: category=$categoryParam');
      }

      final response = await booksRemoteRepository.getBooksByCategory(
        category: categoryParam,
        page: 1,
        limit: 10,
      );

      if (kDebugMode) {
        print('Successfully refreshed ${response.books.length} books');
      }

      emit(
        LibraryLoaded(
          books: response.books,
          hasMore: response.books.length == 10,
          currentCategory: category,
        ),
      );
      // Refresh favorites after refreshing books
      onFavoritesRefresh?.call();
    } on ApiException catch (e) {
      if (kDebugMode) {
        print('API Error refreshing library books: ${e.toString()}');
      }

      String errorMessage = _getErrorMessage(e.statusCode);
      emit(LibraryError(errorMessage));
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error refreshing library books: $e');
      }
      emit(LibraryError('Failed to refresh library books. Please try again.'));
    }
  }

  Future<void> deleteBook(String bookId) async {
    // Check authentication first
    if (!_isAuthenticated()) {
      emit(const LibraryError('Authentication required. Please log in again.'));
      return;
    }

    try {
      if (kDebugMode) {
        print('Deleting book: $bookId');
      }

      await booksRemoteRepository.deleteBook(bookId);

      if (kDebugMode) {
        print('Successfully deleted book: $bookId');
      }

      // Refresh the books list after successful deletion
      if (state is LibraryLoaded) {
        final currentState = state as LibraryLoaded;
        await refreshLibraryBooks(category: currentState.currentCategory);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print('API Error deleting book: ${e.toString()}');
      }

      String errorMessage = _getErrorMessage(e.statusCode);
      emit(LibraryError(errorMessage));
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error deleting book: $e');
      }
      emit(LibraryError('Failed to delete book. Please try again.'));
    }
  }

  bool _isAuthenticated() {
    final token = _authSession.accessToken;
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('Authentication check failed: No access token found');
      }
      return false;
    }
    return true;
  }

  String _getErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input and try again.';
      case 401:
        return 'Authentication required. Please log in again.';
      case 403:
        return 'Access forbidden. Your session may have expired.';
      case 404:
        return 'No books found.';
      case 500:
        return 'Server error. Please try again later.';
      case 0:
        return 'Network error. Please check your connection.';
      default:
        return 'Failed to load books (Error $statusCode). Please try again.';
    }
  }
}
