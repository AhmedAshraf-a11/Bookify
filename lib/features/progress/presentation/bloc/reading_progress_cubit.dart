import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/progress_models.dart';
import '../../data/repositories/progress_remote_repository.dart';

// States
abstract class ReadingProgressState extends Equatable {
  const ReadingProgressState();

  @override
  List<Object> get props => [];
}

class ReadingProgressInitial extends ReadingProgressState {
  const ReadingProgressInitial();
}

class ReadingProgressLoading extends ReadingProgressState {
  const ReadingProgressLoading();
}

class ReadingProgressCreated extends ReadingProgressState {
  const ReadingProgressCreated(this.progress);

  final ReadingProgressModel progress;

  @override
  List<Object> get props => [progress];
}

class ReadingProgressUpdated extends ReadingProgressState {
  const ReadingProgressUpdated(this.progress, this.percentage);

  final DetailedReadingProgressModel progress;
  final int percentage;

  @override
  List<Object> get props => [progress, percentage];
}

class ReadingProgressError extends ReadingProgressState {
  const ReadingProgressError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

// Cubit
class ReadingProgressCubit extends Cubit<ReadingProgressState> {
  ReadingProgressCubit({required ProgressRemoteRepository progressRepository})
    : _progressRepository = progressRepository,
      super(const ReadingProgressInitial());

  final ProgressRemoteRepository _progressRepository;

  Future<void> createReadingProgress(String bookId) async {
    emit(const ReadingProgressLoading());
    try {
      final response = await _progressRepository.createProgress(bookId);
      emit(ReadingProgressCreated(response.progress));
    } catch (e) {
      emit(ReadingProgressError(e.toString()));
    }
  }

  Future<void> updateReadingProgress(String bookId, UpdateProgressRequestModel request) async {
    emit(const ReadingProgressLoading());
    try {
      final response = await _progressRepository.updateProgress(
        bookId,
        request,
      );
      emit(ReadingProgressUpdated(response.progress, response.percentage));
    } catch (e) {
      emit(ReadingProgressError(e.toString()));
    }
  }
}
