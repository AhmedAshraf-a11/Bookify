import '../../../../core/network/api_client.dart';
import '../datasources/notes_remote_endpoints.dart';
import '../models/notes_models.dart';

class NotesRemoteRepository {
  const NotesRemoteRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<AddNoteResponseModel> addNote(
    String bookId,
    AddNoteRequestModel request,
  ) async {
    final json = await _apiClient.post(
      NotesRemoteEndpoints.addNote(bookId),
      body: request.toJson(),
    );
    return AddNoteResponseModel.fromJson(json);
  }

  Future<UpdateNoteResponseModel> updateNote(
    String noteId,
    UpdateNoteRequestModel request,
  ) async {
    final json = await _apiClient.patch(
      NotesRemoteEndpoints.updateNote(noteId),
      body: request.toJson(),
    );
    return UpdateNoteResponseModel.fromJson(json);
  }

  Future<DeleteNoteResponseModel> deleteNote(String noteId) async {
    final json = await _apiClient.delete(
      NotesRemoteEndpoints.deleteNote(noteId),
    );
    return DeleteNoteResponseModel.fromJson(json);
  }
}
