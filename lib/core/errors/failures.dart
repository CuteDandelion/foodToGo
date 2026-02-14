import 'package:equatable/equatable.dart';

/// Base failure class for error handling
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server/Network failures
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// Cache/Storage failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});

  factory AuthFailure.userNotFound() =>
      const AuthFailure('User not found', code: 'USER_NOT_FOUND');

  factory AuthFailure.invalidCredentials() =>
      const AuthFailure('Invalid credentials', code: 'INVALID_CREDENTIALS');

  factory AuthFailure.invalidToken() =>
      const AuthFailure('Invalid token', code: 'INVALID_TOKEN');

  factory AuthFailure.sessionExpired() =>
      const AuthFailure('Session expired', code: 'SESSION_EXPIRED');

  factory AuthFailure.unknown(String error) =>
      AuthFailure('Authentication error: $error', code: 'AUTH_ERROR');
}

/// Validation failures
class ValidationFailure extends Failure {
  final Map<String, String>? errors;

  const ValidationFailure(super.message, {this.errors, super.code});

  @override
  List<Object?> get props => [...super.props, errors];
}

/// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code});
}
