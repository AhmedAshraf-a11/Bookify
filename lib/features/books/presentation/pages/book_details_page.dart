import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../notes/data/models/notes_models.dart';
import '../../../notes/presentation/cubit/notes_cubit.dart';
import '../cubit/books_cubit.dart';
import '../widgets/book_info_card.dart';
import '../widgets/notes_section.dart';

class BookDetailsPage extends StatelessWidget {
  const BookDetailsPage({required this.bookId, super.key});

  final String bookId;

  @override
  Widget build(BuildContext context) {
    return _BookDetailsView(bookId: bookId);
  }
}

class _BookDetailsView extends StatefulWidget {
  const _BookDetailsView({required this.bookId});

  final String bookId;

  @override
  State<_BookDetailsView> createState() => _BookDetailsViewState();
}

class _BookDetailsViewState extends State<_BookDetailsView> {
  final _noteFormKey = GlobalKey<FormState>();
  final _noteContentController = TextEditingController();
  bool _initialLoadComplete = false;
  bool _notesLoaded = false;

  @override
  void initState() {
    super.initState();
    // Load book details when page is initialized
    // Notes will be loaded only when user interacts with them
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksCubit>().getBook(widget.bookId);
    });
  }

  void _loadNotesIfNeeded() {
    if (!_notesLoaded && mounted) {
      _notesLoaded = true;
      context.read<NotesCubit>().loadBookNotes(widget.bookId);
    }
  }

  @override
  void dispose() {
    _noteContentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<FavoritesCubit, FavoritesState>(
          listener: (context, state) {
            if (state is FavoritesError) {
              print('DEBUG: FavoritesCubit error: ${state.message}');
              if (_initialLoadComplete) {
                ErrorHandler.showErrorSnackBar(context, state.message);
              }
            }
          },
        ),
        BlocListener<NotesCubit, NotesState>(
          listener: (context, state) {
            if (state is NotesError) {
              print('DEBUG: NotesCubit error: ${state.message}');
              if (_initialLoadComplete) {
                ErrorHandler.showErrorSnackBar(context, state.message);
              }
            } else if (state is NoteAdded && _initialLoadComplete) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note added successfully')),
              );
            }
          },
        ),
        BlocListener<BooksCubit, BooksState>(
          listener: (context, state) {
            if (state is BookDetailLoaded) {
              _initialLoadComplete = true;
            } else if (state is BooksError) {
              print('DEBUG: BooksCubit error: ${state.message}');
              // Don't show snackbar for initial loading errors
              if (_initialLoadComplete) {
                ErrorHandler.showErrorSnackBar(context, state.message);
              }
            }
          },
        ),
      ],
      child: BlocBuilder<BooksCubit, BooksState>(
        builder: (context, booksState) {
          if (booksState is BooksLoading) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (booksState is BooksError) {
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: _ErrorCard(
                message: booksState.message,
                onRetry: () => context.read<BooksCubit>().getBook(widget.bookId),
              ),
            );
          }

          if (booksState is! BookDetailLoaded) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final bookDetail = booksState.bookDetail;
          final notesState = context.watch<NotesCubit>().state;
          final favoritesState = context.watch<FavoritesCubit>().state;
          final isFavorite = context.watch<FavoritesCubit>().isFavorite(widget.bookId);
          
          List<NoteModel> notes = [];
          if (notesState is BookNotesLoaded) {
            notes = notesState.notes;
          }

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: () => context.push('${AppRoutePaths.library}/edit-book/${widget.bookId}'),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  BookInfoCard(
                    book: bookDetail.book,
                    progress: bookDetail.progressInfo,
                    isFavorite: isFavorite,
                    isFavoriteUpdating: favoritesState is FavoritesUpdating && favoritesState.updatingBookId == widget.bookId,
                    onFavoritePressed: () => isFavorite
                        ? context.read<FavoritesCubit>().removeFromFavorites(widget.bookId)
                        : context.read<FavoritesCubit>().addToFavorites(widget.bookId),
                    bookId: widget.bookId,
                  ),
                  const SizedBox(height: 24),
                  Builder(
                    builder: (context) {
                      _loadNotesIfNeeded();
                      return NotesSection(
                        notes: notes,
                        noteFormKey: _noteFormKey,
                        noteContentController: _noteContentController,
                        isSubmitting: notesState is NotesLoading,
                        onSubmitNote: () async {
                          if (_noteFormKey.currentState!.validate()) {
                            context.read<NotesCubit>().addNote(widget.bookId, AddNoteRequestModel(content: _noteContentController.text));
                            _noteContentController.clear();
                          }
                        },
                        onDeleteNote: (noteId) async {
                          context.read<NotesCubit>().deleteNote(noteId);
                        },
                        onUpdateNote: (noteId, content) async {
                          context.read<NotesCubit>().updateNote(noteId, UpdateNoteRequestModel(content: content));
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
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
      width: double.infinity,
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
