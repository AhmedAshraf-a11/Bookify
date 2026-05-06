import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/utils/app_auth_session.dart';
import 'core/utils/app_repositories.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/books/presentation/cubit/books_cubit.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/library/presentation/cubit/library_cubit.dart';
import 'features/notes/presentation/cubit/notes_cubit.dart';
import 'features/profile/data/repositories/profile_remote_repository.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appAuthSession.init();
  runApp(const BookifyApp());
}

class BookifyApp extends StatelessWidget {
  const BookifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => HomeCubit()),
        BlocProvider(
          create: (_) =>
              BooksCubit(booksRemoteRepository: booksRemoteRepository),
        ),
        BlocProvider(create: (_) => LibraryCubit(authSession: appAuthSession)),
        BlocProvider(
          create: (_) => FavoritesCubit(
            favoritesRemoteRepository: favoritesRemoteRepository,
            homeRemoteRepository: homeRemoteRepository,
          ),
        ),
        BlocProvider(create: (_) => NotesCubit()),
        BlocProvider(
          create: (_) => ProfileCubit(
            ProfileRemoteRepository(
              apiClient: ApiClient(session: appAuthSession),
            ),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Bookify',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
