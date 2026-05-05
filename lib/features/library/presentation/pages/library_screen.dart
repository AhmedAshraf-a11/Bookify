import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/app_auth_session.dart';
import '../../../../shared/widgets/book_card.dart';
import '../cubit/library_cubit.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/delete_confirmation_dialog.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  static const List<String> _categories = [
    'All',
    'sports',
    'religion',
    'horror',
    'eduction',
    'other',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LibraryCubit(authSession: appAuthSession)
            ..loadLibraryBooks(category: null),
      child: const _LibraryView(),
    );
  }
}

class _LibraryView extends StatefulWidget {
  const _LibraryView();

  @override
  State<_LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<_LibraryView> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategory;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final libraryCubit = context.read<LibraryCubit>();
      final state = libraryCubit.state;
      if (state is LibraryLoaded && state.hasMore) {
        _currentPage++;
        libraryCubit.loadMoreLibraryBooks(
          category: _selectedCategory,
          page: _currentPage,
          limit: 10,
        );
      }
    }
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category;
      _currentPage = 1;
    });
    context.read<LibraryCubit>().loadLibraryBooks(
      category: category,
      page: 1,
      limit: 10,
    );
  }

  void _showDeleteConfirmation(BuildContext context, String bookId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(
          onConfirmed: () {
            // Note: We need to implement delete functionality in LibraryCubit
            // For now, we'll just show a snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Delete functionality needs to be implemented'),
                backgroundColor: Colors.orange,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go(AppRoutePaths.home),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Library',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 18),
              // Category Filter
              CategoryFilterChips(
                categories: LibraryScreen._categories,
                selectedCategory: _selectedCategory,
                onCategoryChanged: _onCategoryChanged,
              ),
              const SizedBox(height: 18),
              Expanded(
                child: BlocBuilder<LibraryCubit, LibraryState>(
                  builder: (context, state) {
                    if (state is LibraryLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is LibraryError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              state.message,
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<LibraryCubit>().loadLibraryBooks(
                                  category: _selectedCategory,
                                  page: 1,
                                  limit: 10,
                                );
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (state is LibraryLoaded) {
                      if (state.books.isEmpty) {
                        return const Center(
                          child: Text(
                            'No books found',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          await context
                              .read<LibraryCubit>()
                              .refreshLibraryBooks(category: _selectedCategory);
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: state.books.length,
                          itemBuilder: (context, index) {
                            final book = state.books[index];
                            return BookCard(
                              title: book.title,
                              author: book.createdBy,
                              pages: book.totalPages,
                              description: book.description,
                              onDetailsPressed: () => context.push(
                                '${AppRoutePaths.home}/book-details/${book.id}',
                              ),
                              onEditPressed: () => context.push(
                                '${AppRoutePaths.library}/edit-book/${book.id}',
                              ),
                              onDeletePressed: () {
                                _showDeleteConfirmation(context, book.id);
                              },
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
