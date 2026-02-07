import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/constants.dart';
import '../../../../core/storage/storage_manager.dart';
import '../../../../shared/services/mock_data_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String studentId;
  final String password;
  final bool rememberMe;

  const AuthLoginRequested({
    required this.studentId,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [studentId, password, rememberMe];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String userId;
  final UserRole role;

  const AuthAuthenticated({
    required this.userId,
    required this.role,
  });

  @override
  List<Object?> get props => [userId, role];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final MockDataService _mockDataService;
  final StorageManager _storage;

  AuthBloc({
    MockDataService? mockDataService,
    StorageManager? storage,
  })  : _mockDataService = mockDataService ?? MockDataService(),
        _storage = storage ?? StorageManager(),
        super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = _mockDataService.getUserByStudentId(event.studentId);

      if (user == null) {
        emit(const AuthError('User not found'));
        return;
      }

      if (!_mockDataService.verifyPassword(event.password, user.passwordHash)) {
        emit(const AuthError('Invalid password'));
        return;
      }

      // Store session
      await _storage.prefs.setString(AppConstants.storageKeyUserId, user.id);
      await _storage.prefs.setString(AppConstants.storageKeyToken, 'mock_token_${user.id}');

      emit(AuthAuthenticated(
        userId: user.id,
        role: user.role,
      ));
    } catch (e) {
      emit(AuthError('Login failed: $e'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _storage.prefs.remove(AppConstants.storageKeyUserId);
    await _storage.prefs.remove(AppConstants.storageKeyToken);
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final userId = await _storage.prefs.getString(AppConstants.storageKeyUserId);

      if (userId != null) {
        final user = _mockDataService.getUserById(userId);
        if (user != null) {
          emit(AuthAuthenticated(
            userId: user.id,
            role: user.role,
          ));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }
}
