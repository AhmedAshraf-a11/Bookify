import 'package:bloc/bloc.dart';
import 'package:bookify/core/app_repositories.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/app_auth_session.dart'; // Import for appAuthSession
import '../../data/models/auth_models.dart';
import '../../data/repositories/auth_remote_repository.dart';

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class SignUpLoading extends AuthState {}

class SignUpSuccess extends AuthState {
  final SignUpResponseModel response;

  const SignUpSuccess(this.response);

  @override
  List<Object> get props => [response];
}

class SignUpFailure extends AuthState {
  final String error;

  const SignUpFailure(this.error);

  @override
  List<Object> get props => [error];
}

class SignInLoading extends AuthState {}

class SignInSuccess extends AuthState {
  final SignInResponseModel response;

  const SignInSuccess(this.response);

  @override
  List<Object> get props => [response];
}

class SignInFailure extends AuthState {
  final String error;

  const SignInFailure(this.error);

  @override
  List<Object> get props => [error];
}

class AuthCubit extends Cubit<AuthState> {
  // Instantiate AuthRemoteRepository with its dependencies
  // We are using the globally available apiClient and appAuthSession.
  final AuthRemoteRepository _authRemoteRepository = AuthRemoteRepository(
    apiClient:
        apiClient, // Assuming apiClient is globally available from core/network/api_client.dart
    session:
        appAuthSession, // Assuming appAuthSession is globally available from core/app_auth_session.dart
  );

  AuthCubit() : super(AuthInitial());

  Future<void> signUp(
    String firstName,
    String lastName,
    String email,
    String password, {
    String? bio,
  }) async {
    emit(SignUpLoading());
    try {
      // Create the request model
      final requestModel = SignUpRequestModel(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        confirmPassword: password,
        bio: bio?.isEmpty == true ? null : bio,
      );

      // Call the repository to perform signup
      final response = await _authRemoteRepository.signUp(requestModel);

      // Emit success state with the response
      emit(SignUpSuccess(response));
    } catch (e) {
      // Emit failure state with the error message
      emit(SignUpFailure(e.toString()));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(SignInLoading());
    try {
      // Create the request model
      final requestModel = SignInRequestModel(email: email, password: password);

      // Call the repository to perform signin
      final response = await _authRemoteRepository.signIn(requestModel);

      // Emit success state with the response
      emit(SignInSuccess(response));
    } catch (e) {
      // Emit failure state with the error message
      emit(SignInFailure(e.toString()));
    }
  }
}
