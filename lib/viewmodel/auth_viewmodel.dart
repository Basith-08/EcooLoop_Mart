import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';
import '../state/auth_state.dart';

class AuthViewModel extends ChangeNotifier {
  final UserRepository _repository;
  AuthState _state = const AuthInitial();
  UserModel? _currentUser;

  AuthViewModel(this._repository);

  AuthState get state => _state;
  UserModel? get currentUser => _currentUser;

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Login user with username and password
  Future<void> login(String username, String password) async {
    try {
      _setState(const AuthLoading());

      // Validate inputs
      if (username.trim().isEmpty || password.trim().isEmpty) {
        _setState(const AuthError('Username and password are required'));
        return;
      }

      final user = await _repository.login(username, password);

      if (user == null) {
        _setState(const AuthError('Invalid username or password'));
      } else {
        _currentUser = user;
        _setState(Authenticated(user));
      }
    } catch (e) {
      final message = e.toString();
      if (message.toLowerCase().contains('inactive')) {
        _setState(const AuthError('Akun tidak aktif'));
        return;
      }

      _setState(AuthError(
        'Failed to login',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Register new user
  Future<void> register(String name, String username, String password) async {
    try {
      _setState(const AuthLoading());

      // Validate inputs
      if (name.trim().isEmpty || username.trim().isEmpty || password.trim().isEmpty) {
        _setState(const AuthError('All fields are required'));
        return;
      }

      // Check if username already exists
      final existingUser = await _repository.getUserByUsername(username);
      if (existingUser != null) {
        _setState(const AuthError('Username already exists'));
        return;
      }

      final user = UserModel(
        name: name,
        username: username,
        password: password,
        role: 'warga', // Default role
      );

      final id = await _repository.register(user);
      final createdUser = user.copyWith(id: id);

      _currentUser = createdUser;
      _setState(Authenticated(createdUser));
    } catch (e) {
      _setState(AuthError(
        'Failed to register',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      _currentUser = null;
      _setState(const Unauthenticated(message: 'Logged out successfully'));
    } catch (e) {
      _setState(AuthError(
        'Failed to logout',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Check if user is authenticated (load from stored session)
  Future<void> checkAuth() async {
    try {
      _setState(const AuthLoading());

      // In a real app, you would check for stored session/token here
      // For now, we'll just set to unauthenticated if no current user
      if (_currentUser != null) {
        _setState(Authenticated(_currentUser!));
      } else {
        _setState(const Unauthenticated());
      }
    } catch (e) {
      _setState(AuthError(
        'Failed to check authentication',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Reset state to initial
  void resetState() {
    _setState(const AuthInitial());
  }
}
