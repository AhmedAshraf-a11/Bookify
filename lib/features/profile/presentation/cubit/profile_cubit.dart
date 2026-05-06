import 'package:bloc/bloc.dart';
import 'package:bookify/core/utils/app_repositories.dart';
import 'package:bookify/features/profile/data/repositories/profile_remote_repository.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/profile_models.dart';

// States
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final GetProfileResponseModel profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdated extends ProfileState {
  final UpdateProfileResponseModel response;

  const ProfileUpdated(this.response);

  @override
  List<Object?> get props => [response];
}

class ProfileDeleted extends ProfileState {
  final DeleteProfileResponseModel response;

  const ProfileDeleted(this.response);

  @override
  List<Object?> get props => [response];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(ProfileRemoteRepository profileRemoteRepository) : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());

    try {
      final response = await profileRemoteRepository.getProfile();

      emit(ProfileLoaded(response));
    } catch (e) {
      emit(ProfileError('Failed to load profile. Please try again.'));
    }
  }

  Future<void> updateProfile(UpdateProfileRequestModel request) async {
    emit(ProfileLoading());

    try {
      final response = await profileRemoteRepository.updateProfile(request);

      emit(ProfileUpdated(response));

      // Reload profile after update
      await loadProfile();
    } catch (e) {
      emit(ProfileError('Failed to update profile. Please try again.'));
    }
  }

  Future<void> deleteProfile() async {
    emit(ProfileLoading());

    try {
      final response = await profileRemoteRepository.deleteProfile();

      emit(ProfileDeleted(response));
    } catch (e) {
      emit(ProfileError('Failed to delete profile. Please try again.'));
    }
  }
}
