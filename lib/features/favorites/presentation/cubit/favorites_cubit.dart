import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../home/data/models/home_models.dart';
import '../../data/repositories/favorites_remote_repository.dart';
import '../../../home/data/repo/home_remote_repository.dart';

// States
abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<HomeFavoriteBookModel> favorites;
  final int count;

  const FavoritesLoaded({required this.favorites, required this.count});

  @override
  List<Object?> get props => [favorites, count];

  FavoritesLoaded copyWith({
    List<HomeFavoriteBookModel>? favorites,
    int? count,
  }) {
    return FavoritesLoaded(
      favorites: favorites ?? this.favorites,
      count: count ?? this.count,
    );
  }
}

class FavoritesUpdating extends FavoritesLoaded {
  final String updatingBookId;

  const FavoritesUpdating({
    required List<HomeFavoriteBookModel> favorites,
    required int count,
    required this.updatingBookId,
  }) : super(favorites: favorites, count: count);

  @override
  List<Object?> get props => [favorites, count, updatingBookId];
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRemoteRepository favoritesRemoteRepository;
  final HomeRemoteRepository homeRemoteRepository;

  FavoritesCubit({
    required this.favoritesRemoteRepository,
    required this.homeRemoteRepository,
  }) : super(FavoritesInitial());

  Future<void> loadFavorites() async {
    emit(FavoritesLoading());

    try {
      final response = await homeRemoteRepository.getFavorites();

      emit(
        FavoritesLoaded(
          favorites: response.data.favorites,
          count: response.data.favoritesCount,
        ),
      );
    } catch (e) {
      emit(FavoritesError('Failed to load favorites. Please try again.'));
    }
  }

  Future<void> addToFavorites(String bookId) async {
    if (state is! FavoritesLoaded) {
      await loadFavorites();
      return;
    }

    final currentState = state as FavoritesLoaded;

    // Show updating state
    emit(
      FavoritesUpdating(
        favorites: currentState.favorites,
        count: currentState.count,
        updatingBookId: bookId,
      ),
    );

    try {
      await favoritesRemoteRepository.addToFavorites(bookId);

      // Reload favorites after successful addition
      await loadFavorites();
    } catch (e) {
      emit(FavoritesError('Failed to add to favorites. Please try again.'));
      // Revert to previous state
      emit(currentState);
    }
  }

  Future<void> removeFromFavorites(String bookId) async {
    if (state is! FavoritesLoaded) {
      await loadFavorites();
      return;
    }

    final currentState = state as FavoritesLoaded;

    // Show updating state
    emit(
      FavoritesUpdating(
        favorites: currentState.favorites,
        count: currentState.count,
        updatingBookId: bookId,
      ),
    );

    try {
      await favoritesRemoteRepository.removeFromFavorites(bookId);

      // Reload favorites after successful removal
      await loadFavorites();
    } catch (e) {
      emit(
        FavoritesError('Failed to remove from favorites. Please try again.'),
      );
      // Revert to previous state
      emit(currentState);
    }
  }

  bool isFavorite(String bookId) {
    if (state is FavoritesLoaded) {
      final currentState = state as FavoritesLoaded;
      return currentState.favorites.any((book) => book.id == bookId);
    }
    return false;
  }
}
