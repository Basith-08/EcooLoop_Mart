import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';
import '../state/user_state.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _repository;
  UserState _state = const UserInitial();

  UserViewModel(this._repository);

  UserState get state => _state;

  void _setState(UserState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Load all users from database
  Future<void> loadUsers() async {
    try {
      _setState(const UserLoading());

      final users = await _repository.getAllUsers();

      if (users.isEmpty) {
        _setState(const UserEmpty());
      } else {
        _setState(UserLoaded(users));
      }
    } catch (e) {
      _setState(UserError(
        'Failed to load users',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Load user by ID
  Future<void> loadUserById(int id) async {
    try {
      _setState(const UserLoading());

      final user = await _repository.getUserById(id);

      if (user == null) {
        _setState(const UserError('User not found'));
      } else {
        _setState(UserDetailLoaded(user));
      }
    } catch (e) {
      _setState(UserError(
        'Failed to load user',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Load user by email
  Future<void> loadUserByEmail(String email) async {
    try {
      _setState(const UserLoading());

      final user = await _repository.getUserByEmail(email);

      if (user == null) {
        _setState(const UserError('User not found'));
      } else {
        _setState(UserDetailLoaded(user));
      }
    } catch (e) {
      _setState(UserError(
        'Failed to load user',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Create new user
  Future<void> createUser({
    required String name,
    required String username,
    required String password,
    String? phone,
    String? role,
  }) async {
    try {
      _setState(const UserLoading());

      final user = UserModel(
        name: name,
        username: username,
        password: password,
        phone: phone,
        role: role ?? 'warga',
      );

      final id = await _repository.insertUser(user);
      final createdUser = user.copyWith(id: id);

      _setState(UserCreated(createdUser));

      // Reload users to update the list
      await loadUsers();
    } catch (e) {
      _setState(UserError(
        'Failed to create user',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Update existing user
  Future<void> updateUser(UserModel user) async {
    try {
      _setState(const UserLoading());

      if (user.id == null) {
        _setState(const UserError('User ID is required for update'));
        return;
      }

      final rowsAffected = await _repository.updateUser(user);

      if (rowsAffected == 0) {
        _setState(const UserError('User not found or no changes made'));
      } else {
        _setState(UserUpdated(user));

        // Reload users to update the list
        await loadUsers();
      }
    } catch (e) {
      _setState(UserError(
        'Failed to update user',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Update user status (active / inactive)
  Future<void> updateUserStatus(int userId, String status) async {
    try {
      _setState(const UserLoading());

      final rowsAffected = await _repository.updateUserStatus(userId, status);

      if (rowsAffected == 0) {
        _setState(const UserError('User not found or status unchanged'));
      } else {
        final updatedUser = await _repository.getUserById(userId);
        if (updatedUser == null) {
          _setState(const UserError('User not found after update'));
        } else {
          _setState(UserUpdated(
            updatedUser,
            message: 'Status updated to $status',
          ));
        }

        // Reload users to update the list
        await loadUsers();
      }
    } catch (e) {
      _setState(UserError(
        'Failed to update user status',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Delete user by ID
  Future<void> deleteUser(int id) async {
    try {
      _setState(const UserLoading());

      final rowsAffected = await _repository.deleteUser(id);

      if (rowsAffected == 0) {
        _setState(const UserError('User not found'));
      } else {
        _setState(const UserDeleted());

        // Reload users to update the list
        await loadUsers();
      }
    } catch (e) {
      _setState(UserError(
        'Failed to delete user',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Delete all users
  Future<void> deleteAllUsers() async {
    try {
      _setState(const UserLoading());

      await _repository.deleteAllUsers();
      _setState(const UserDeleted(message: 'All users deleted successfully'));

      // Reload to show empty state
      await loadUsers();
    } catch (e) {
      _setState(UserError(
        'Failed to delete all users',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Search users by name
  Future<void> searchUsers(String name) async {
    try {
      _setState(const UserLoading());

      final users = await _repository.searchUsersByName(name);

      if (users.isEmpty) {
        _setState(const UserEmpty(message: 'No users found matching the search'));
      } else {
        _setState(UserLoaded(users));
      }
    } catch (e) {
      _setState(UserError(
        'Failed to search users',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Get user count
  Future<int> getUserCount() async {
    try {
      return await _repository.getUserCount();
    } catch (e) {
      return 0;
    }
  }

  /// Reset state to initial
  void resetState() {
    _setState(const UserInitial());
  }
}
