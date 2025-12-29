import '../data/models/user_model.dart';

/// Base class for all auth states
abstract class AuthState {
  const AuthState();
}

/// Initial state when no authentication action has been performed
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state while performing authentication operations
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Success state when user is authenticated
class Authenticated extends AuthState {
  final UserModel user;

  const Authenticated(this.user);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Authenticated && other.user == user;
  }

  @override
  int get hashCode => user.hashCode;
}

/// Error state when authentication fails
class AuthError extends AuthState {
  final String message;
  final Exception? exception;

  const AuthError(this.message, {this.exception});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthError &&
           other.message == message &&
           other.exception == exception;
  }

  @override
  int get hashCode => message.hashCode ^ exception.hashCode;
}

/// State when user is not authenticated
class Unauthenticated extends AuthState {
  final String message;

  const Unauthenticated({this.message = 'User not authenticated'});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Unauthenticated && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}
