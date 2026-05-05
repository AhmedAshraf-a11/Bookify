import '../../../../core/constants/api_endpoints.dart';

class NotesRemoteEndpoints {
  const NotesRemoteEndpoints._();

  static Uri addNote(String bookId) => ApiEndpoints.addNoteUri(bookId);
  static Uri updateNote(String noteId) => ApiEndpoints.updateNoteUri(noteId);
  static Uri deleteNote(String noteId) => ApiEndpoints.deleteNoteUri(noteId);
}
