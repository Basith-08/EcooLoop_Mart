import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_hybrid_repository.dart';
import '../core/services/firebase_auth_service.dart';
import '../state/auth_state.dart';

class AuthViewModel extends ChangeNotifier {
  final UserHybridRepository _repository;
  final FirebaseAuthService _firebaseAuth;
  AuthState _state = const AuthInitial();
  UserModel? _currentUser;

  AuthViewModel(this._repository, this._firebaseAuth);

  AuthState get state => _state;
  UserModel? get currentUser => _currentUser;
  bool get isFirebaseSignedIn => _firebaseAuth.isSignedIn;

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

  /// Register new user with Firebase Auth + Local SQLite
  Future<void> register(String name, String username, String password, {String? email}) async {
    try {
      _setState(const AuthLoading());

      // Validate inputs
      if (name.trim().isEmpty || username.trim().isEmpty || password.trim().isEmpty) {
        _setState(const AuthError('All fields are required'));
        return;
      }

      // Email is required for Firebase Auth
      if (email == null || email.trim().isEmpty) {
        _setState(const AuthError('Email is required for registration'));
        return;
      }

      // Check if username already exists
      final existingUser = await _repository.getUserByUsername(username);
      if (existingUser != null) {
        _setState(const AuthError('Username already exists'));
        return;
      }

      // 1. Create Firebase Auth account first
      try {
        await _firebaseAuth.registerWithEmailPassword(email, password);
      } on FirebaseAuthException catch (e) {
        _setState(AuthError(_firebaseAuth.getErrorMessage(e)));
        return;
      }

      // 2. Save to local SQLite
      final user = UserModel(
        name: name,
        username: username,
        password: password,
        email: email,
        role: 'warga', // Default role
      );

      final id = await _repository.register(user);
      final createdUser = user.copyWith(id: id);

      _currentUser = createdUser;
      _setState(Authenticated(createdUser));
    } catch (e) {
      // Rollback: If local save fails, delete Firebase account
      try {
        await _firebaseAuth.deleteAccount();
      } catch (_) {}

      _setState(AuthError(
        'Failed to register',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Logout current user (Firebase + Local)
  Future<void> logout() async {
    try {
      // Sign out from Firebase Auth
      await _firebaseAuth.signOut();

      // Clear local user
      _currentUser = null;
      _setState(const Unauthenticated(message: 'Logged out successfully'));
    } catch (e) {
      _setState(AuthError(
        'Failed to logout',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Check if user is authenticated (Firebase + Local)
  Future<void> checkAuth() async {
    try {
      _setState(const AuthLoading());

      // Check Firebase Auth state
      final firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser != null && firebaseUser.email != null) {
        // User is signed in with Firebase, try to load from local
        final localUser = await _repository.getUserByEmail(firebaseUser.email!);

        if (localUser != null) {
          _currentUser = localUser;
          _setState(Authenticated(localUser));
          return;
        }
      }

      // No Firebase user or local user not found
      _setState(const Unauthenticated());
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
