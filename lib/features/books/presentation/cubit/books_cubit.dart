import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/books_models.dart';
import '../../data/repositories/books_remote_repository.dart';

// Events
abstract class BooksEvent extends Equatable {
  const BooksEvent();

  @override
  List<Object?> get props => [];
}

class LoadBooksByCategory extends BooksEvent {
  final String? category;
  final int page;
  final int limit;

  const LoadBooksByCategory({this.category, this.page = 1, this.limit = 10});

  @override
  List<Object?> get props => [category, page, limit];
}

class AddBookRequested extends BooksEvent {
  final AddBookRequestModel request;
  final String? imagePath;
  final String? pdfPath;

  const AddBookRequested({required this.request, this.imagePath, this.pdfPath});

  @override
  List<Object?> get props => [request, imagePath, pdfPath];
}

class EditBookRequested extends BooksEvent {
  final String bookId;
  final EditBookRequestModel request;

  const EditBookRequested({required this.bookId, required this.request});

  @override
  List<Object?> get props => [bookId, request];
}

class DeleteBookRequested extends BooksEvent {
  final String bookId;

  const DeleteBookRequested({required this.bookId});

  @override
  List<Object?> get props => [bookId];
}

class GetBookRequested extends BooksEvent {
  final String bookId;

  const GetBookRequested({required this.bookId});

  @override
  List<Object?> get props => [bookId];
}

// States
abstract class BooksState extends Equatable {
  const BooksState();

  @override
  List<Object?> get props => [];
}

class BooksInitial extends BooksState {}

class BooksLoading extends BooksState {}

class BooksLoaded extends BooksState {
  final List<BookModel> books;
  final bool hasMore;

  const BooksLoaded({required this.books, this.hasMore = true});

  @override
  List<Object?> get props => [books, hasMore];

  BooksLoaded copyWith({List<BookModel>? books, bool? hasMore}) {
    return BooksLoaded(
      books: books ?? this.books,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class BookDetailLoaded extends BooksState {
  final GetBookResponseModel bookDetail;

  const BookDetailLoaded(this.bookDetail);

  @override
  List<Object?> get props => [bookDetail];
}

class BookAdded extends BooksState {
  final AddBookResponseModel response;

  const BookAdded(this.response);

  @override
  List<Object?> get props => [response];
}

class BookEdited extends BooksState {
  final EditBookResponseModel response;

  const BookEdited(this.response);

  @override
  List<Object?> get props => [response];
}

class BookDeleted extends BooksState {
  final DeleteBookResponseModel response;

  const BookDeleted(this.response);

  @override
  List<Object?> get props => [response];
}

class BooksError extends BooksState {
  final String message;

  const BooksError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class BooksCubit extends Cubit<BooksState> {
  final BooksRemoteRepository booksRemoteRepository;

  BooksCubit({required this.booksRemoteRepository}) : super(BooksInitial());

  Future<void> loadBooks({int page = 1, int limit = 10}) async {
    emit(BooksLoading());

    try {
      final response = await booksRemoteRepository.getBooksByCategory(
        category: null,
        page: page,
        limit: limit,
      );

      emit(
        BooksLoaded(
          books: response.books,
          hasMore: response.books.length == limit,
        ),
      );
    } catch (e) {
      emit(BooksError('Failed to load books. Please try again.'));
    }
  }

  Future<void> loadBooksByCategory({
    String? category,
    int page = 1,
    int limit = 10,
  }) async {
    emit(BooksLoading());

    try {
      final response = await booksRemoteRepository.getBooksByCategory(
        category: category,
        page: page,
        limit: limit,
      );

      emit(
        BooksLoaded(
          books: response.books,
          hasMore: response.books.length == limit,
        ),
      );
    } catch (e) {
      emit(BooksError('Failed to load books. Please try again.'));
    }
  }

  Future<void> addBook(
    AddBookRequestModel request, {
    String? imagePath,
    String? pdfPath,
  }) async {
    emit(BooksLoading());

    try {
      final response = await booksRemoteRepository.addBook(
        request,
        imagePath: imagePath,
        pdfPath: pdfPath,
      );

      emit(BookAdded(response));
    } catch (e) {
      emit(BooksError('Failed to add book. Please try again.'));
    }
  }

  Future<void> editBook(String bookId, EditBookRequestModel request) async {
    emit(BooksLoading());

    try {
      final response = await booksRemoteRepository.editBook(bookId, request);

      emit(BookEdited(response));
    } catch (e) {
      emit(BooksError('Failed to edit book. Please try again.'));
    }
  }

  Future<void> deleteBook(String bookId) async {
    emit(BooksLoading());

    try {
      final response = await booksRemoteRepository.deleteBook(bookId);

      emit(BookDeleted(response));
    } catch (e) {
      emit(BooksError('Failed to delete book. Please try again.'));
    }
  }

  Future<void> getBook(String bookId) async {
    emit(BooksLoading());

    try {
      final response = await booksRemoteRepository.getBook(bookId);

      emit(BookDetailLoaded(response));
    } catch (e) {
      emit(BooksError('Failed to load book details. Please try again.'));
    }
  }
}
