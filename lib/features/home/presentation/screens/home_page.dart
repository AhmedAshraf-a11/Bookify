import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/home_cubit.dart';
import '../../../books/presentation/cubit/books_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../widgets/progress_card.dart';
import '../widgets/want_to_read_section.dart';
import '../widgets/favorites_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..loadHomeData(),
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatelessWidget {
  const _HomePageContent();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<BooksCubit, BooksState>(
          listener: (context, state) {
            if (state is BookAdded ||
                state is BookEdited ||
                state is BookDeleted) {
              context.read<HomeCubit>().refreshHomeData();
            }
          },
        ),
        BlocListener<FavoritesCubit, FavoritesState>(
          listener: (context, state) {
            if (state is FavoritesLoaded) {
              context.read<HomeCubit>().refreshHomeData();
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return Column(
              children: [
                Container(
                  color: AppColors.primary,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Bookify',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  context.go(AppRoutePaths.profile);
                                },
                                icon: const Icon(
                                  Icons.people,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Good Evening, User\nkeep reading, you are doing great!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (state is HomeLoading)
                            const SizedBox(
                              height: 180,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            )
                          else if (state is HomeError)
                            _ErrorCard(
                              message: state.message,
                              onRetry: () =>
                                  context.read<HomeCubit>().loadHomeData(),
                            )
                          else if (state is HomeLoaded)
                            ProgressCard(
                              completed: state.totalProgress.completed,
                              totalFavorites:
                                  state.totalProgress.totalFavorites,
                              percentage: state.totalProgress.percentage,
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        if (state is HomeLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 24),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (state is HomeError)
                          _ErrorCard(
                            message: state.message,
                            onRetry: () =>
                                context.read<HomeCubit>().loadHomeData(),
                          )
                        else if (state is HomeLoaded)
                          Column(
                            children: [
                              WantToReadSection(
                                currentlyReading: state.currentlyReading,
                                onBookTap: (bookId) {
                                  context.push(
                                    '${AppRoutePaths.home}/book-details/$bookId',
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              FavoritesSection(
                                favorites: state.favorites,
                                onBookTap: (bookId) {
                                  context.push(
                                    '${AppRoutePaths.home}/book-details/$bookId',
                                  );
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Error: $message',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
