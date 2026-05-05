import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../../../../core/app_repositories.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../core/network/auth_session.dart';
import '../../../books/data/models/books_models.dart';

// Events
abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

class LoadLibraryBooks extends LibraryEvent {
  final String? category;
  final int page;
  final int limit;

  const LoadLibraryBooks({this.category, this.page = 1, this.limit = 10});

  @override
  List<Object?> get props => [category, page, limit];
}

class LoadMoreLibraryBooks extends LibraryEvent {
  final String? category;
  final int page;
  final int limit;

  const LoadMoreLibraryBooks({this.category, this.page = 1, this.limit = 10});

  @override
  List<Object?> get props => [category, page, limit];
}

class RefreshLibraryBooks extends LibraryEvent {
  final String? category;

  const RefreshLibraryBooks({this.category});

  @override
  List<Object?> get props => [category];
}

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
  LibraryCubit({required AuthSession authSession})
    : _authSession = authSession,
      super(LibraryInitial());

  final AuthSession _authSession;

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
      final categoryParam = category == 'All' ? null : category;

      if (kDebugMode) {
        print(
          'Loading library books: category=$categoryParam, page=$page, limit=$limit',
        );
      }

      final response = await booksRemoteRepository.getBooksByCategory(
        category: categoryParam,
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
        return 'Failed to load books. Please try again.';
    }
  }
}
