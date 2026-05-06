import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/app_repositories.dart';
import '../../data/models/home_models.dart';

// States
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final TotalProgressModel totalProgress;
  final List<CurrentlyReadingItemModel> currentlyReading;
  final List<HomeFavoriteBookModel> favorites;

  const HomeLoaded({
    required this.totalProgress,
    required this.currentlyReading,
    required this.favorites,
  });

  @override
  List<Object> get props => [totalProgress, currentlyReading, favorites];

  HomeLoaded copyWith({
    TotalProgressModel? totalProgress,
    List<CurrentlyReadingItemModel>? currentlyReading,
    List<HomeFavoriteBookModel>? favorites,
  }) {
    return HomeLoaded(
      totalProgress: totalProgress ?? this.totalProgress,
      currentlyReading: currentlyReading ?? this.currentlyReading,
      favorites: favorites ?? this.favorites,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}

// Cubit
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  Future<void> loadHomeData() async {
    emit(HomeLoading());

    try {
      final totalProgressResponse = await homeRemoteRepository
          .getTotalProgress();
      final currentlyReadingResponse = await homeRemoteRepository
          .getCurrentlyReading();
      final favoritesResponse = await homeRemoteRepository.getFavorites();

      emit(
        HomeLoaded(
          totalProgress: totalProgressResponse.progress,
          currentlyReading: currentlyReadingResponse.items,
          favorites: favoritesResponse.data.favorites,
        ),
      );
    } catch (e) {
      emit(
        HomeError(
          'Something went wrong while loading home. Please try again later.',
        ),
      );
    }
  }

  Future<void> refreshHomeData() async {
    if (state is HomeLoaded) {
      emit(HomeLoading());

      try {
        final totalProgressResponse = await homeRemoteRepository
            .getTotalProgress();
        final currentlyReadingResponse = await homeRemoteRepository
            .getCurrentlyReading();
        final favoritesResponse = await homeRemoteRepository.getFavorites();

        emit(
          HomeLoaded(
            totalProgress: totalProgressResponse.progress,
            currentlyReading: currentlyReadingResponse.items,
            favorites: favoritesResponse.data.favorites,
          ),
        );
      } catch (e) {
        emit(HomeError('Could not load your progress and books'));
      }
    } else {
      await loadHomeData();
    }
  }
}
