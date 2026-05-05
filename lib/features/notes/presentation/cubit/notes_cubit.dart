import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/app_repositories.dart';
import '../../data/models/notes_models.dart';

// Events
abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

class LoadBookNotes extends NotesEvent {
  final String bookId;

  const LoadBookNotes(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

class AddNoteRequested extends NotesEvent {
  final String bookId;
  final AddNoteRequestModel request;

  const AddNoteRequested({required this.bookId, required this.request});

  @override
  List<Object?> get props => [bookId, request];
}

class UpdateNoteRequested extends NotesEvent {
  final String noteId;
  final UpdateNoteRequestModel request;

  const UpdateNoteRequested({required this.noteId, required this.request});

  @override
  List<Object?> get props => [noteId, request];
}

class DeleteNoteRequested extends NotesEvent {
  final String noteId;

  const DeleteNoteRequested(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

// States
abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class BookNotesLoaded extends NotesState {
  final List<NoteModel> notes;
  final String bookId;

  const BookNotesLoaded({required this.notes, required this.bookId});

  @override
  List<Object?> get props => [notes, bookId];

  BookNotesLoaded copyWith({List<NoteModel>? notes, String? bookId}) {
    return BookNotesLoaded(
      notes: notes ?? this.notes,
      bookId: bookId ?? this.bookId,
    );
  }
}

class NoteAdded extends NotesState {
  final AddNoteResponseModel response;

  const NoteAdded(this.response);

  @override
  List<Object?> get props => [response];
}

class NoteUpdated extends NotesState {
  final UpdateNoteResponseModel response;

  const NoteUpdated(this.response);

  @override
  List<Object?> get props => [response];
}

class NoteDeleted extends NotesState {
  final DeleteNoteResponseModel response;

  const NoteDeleted(this.response);

  @override
  List<Object?> get props => [response];
}

class NotesError extends NotesState {
  final String message;

  const NotesError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(NotesInitial());

  Future<void> loadBookNotes(String bookId) async {
    emit(NotesLoading());

    try {
      final response = await booksRemoteRepository.getBook(bookId);

      // Convert BookNoteModel to NoteModel for consistency
      final notes = response.notes
          .map(
            (bookNote) => NoteModel(
              id: bookNote.id,
              bookId: bookNote.bookId,
              userId: bookNote.userId,
              content: bookNote.content,
              title: bookNote.title,
              page: bookNote.page,
            ),
          )
          .toList();

      emit(BookNotesLoaded(notes: notes, bookId: bookId));
    } catch (e) {
      emit(NotesError('Failed to load book notes. Please try again.'));
    }
  }

  Future<void> addNote(String bookId, AddNoteRequestModel request) async {
    emit(NotesLoading());

    try {
      final response = await notesRemoteRepository.addNote(bookId, request);

      emit(NoteAdded(response));

      // Add the new note to existing notes
      if (state is BookNotesLoaded) {
        final currentState = state as BookNotesLoaded;
        final updatedNotes = [response.note, ...currentState.notes];
        emit(BookNotesLoaded(notes: updatedNotes, bookId: bookId));
      } else {
        // If no notes are currently loaded, load them from the server
        await loadBookNotes(bookId);
      }
    } catch (e) {
      emit(NotesError('Failed to add note. Please try again.'));
    }
  }

  Future<void> updateNote(String noteId, UpdateNoteRequestModel request) async {
    final currentBookId = state is BookNotesLoaded
        ? (state as BookNotesLoaded).bookId
        : null;
    emit(NotesLoading());

    try {
      final response = await notesRemoteRepository.updateNote(noteId, request);

      emit(NoteUpdated(response));

      // Update the note in the existing list
      if (state is BookNotesLoaded && currentBookId != null) {
        final currentState = state as BookNotesLoaded;
        final updatedNotes = currentState.notes
            .map((note) => note.id == noteId ? response.note : note)
            .toList();
        emit(BookNotesLoaded(notes: updatedNotes, bookId: currentBookId));
      } else if (currentBookId != null) {
        await loadBookNotes(currentBookId);
      }
    } catch (e) {
      emit(NotesError('Failed to update note. Please try again.'));
    }
  }

  Future<void> deleteNote(String noteId) async {
    final currentBookId = state is BookNotesLoaded
        ? (state as BookNotesLoaded).bookId
        : null;
    emit(NotesLoading());

    try {
      final response = await notesRemoteRepository.deleteNote(noteId);

      emit(NoteDeleted(response));

      // Remove the note from the existing list
      if (state is BookNotesLoaded && currentBookId != null) {
        final currentState = state as BookNotesLoaded;
        final updatedNotes = currentState.notes
            .where((note) => note.id != noteId)
            .toList();
        emit(BookNotesLoaded(notes: updatedNotes, bookId: currentBookId));
      } else if (currentBookId != null) {
        await loadBookNotes(currentBookId);
      }
    } catch (e) {
      emit(NotesError('Failed to delete note. Please try again.'));
    }
  }
}
