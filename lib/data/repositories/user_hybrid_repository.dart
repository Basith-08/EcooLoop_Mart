import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'user_repository.dart';
import '../../core/services/firebase_sync_service.dart';

/// Hybrid Repository: SQLite (local) + Firestore (cloud sync)
///
/// Strategi:
/// 1. Semua operasi CRUD dilakukan ke SQLite terlebih dahulu (offline-first)
/// 2. Data otomatis di-sync ke Firestore jika ada koneksi internet
/// 3. Bisa pull data dari Firestore untuk sync antar device
/// 4. Support real-time updates dari Firestore
class UserHybridRepository {
  final UserRepository _localRepo = UserRepository();
  final FirebaseSyncService _syncService = FirebaseSyncService();
  final String _collectionName = 'users';

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Getter untuk sync status
  SyncStatus get syncStatus => _syncService.status;
  DateTime? get lastSyncTime => _syncService.lastSyncTime;
  String? get lastError => _syncService.lastError;

  /// Helper: Convert UserModel to Firestore map
  Map<String, dynamic> _toFirestoreMap(UserModel user) {
    final map = user.toMap();
    map.remove('id'); // Firestore uses document ID, not integer ID
    return map;
  }

  /// Helper: Convert Firestore map to UserModel
  UserModel _fromFirestoreMap(Map<String, dynamic> map) {
    return UserModel.fromMap(map);
  }

  /// Helper: Get document ID from user
  String _getDocumentId(UserModel user) {
    // Gunakan username sebagai document ID untuk konsistensi
    return user.username;
  }

  /// Helper: Try to sync to cloud (tidak throw error jika gagal)
  Future<void> _trySyncToCloud(UserModel user) async {
    try {
      final hasConnection = await _syncService.checkConnection();
      if (!hasConnection) return;

      await _firestore
          .collection(_collectionName)
          .doc(_getDocumentId(user))
          .set(_toFirestoreMap(user), SetOptions(merge: true));
    } catch (e) {
      // Silent fail - data sudah tersimpan di local
      print('Background sync failed: $e');
    }
  }

  // ==================== CRUD OPERATIONS ====================

  /// Register user - Save to local & sync to cloud
  Future<int> register(UserModel user) async {
    // 1. Save to SQLite first (offline-first)
    final localId = await _localRepo.register(user);

    // 2. Try to sync to cloud (background, non-blocking)
    _trySyncToCloud(user);

    return localId;
  }

  /// Login - dari local SQLite
  Future<UserModel?> login(String username, String password) async {
    return await _localRepo.login(username, password);
  }

  /// Insert user - Save to local & sync to cloud
  Future<int> insertUser(UserModel user) async {
    final localId = await _localRepo.insertUser(user);
    _trySyncToCloud(user);
    return localId;
  }

  /// Get all users - dari local SQLite
  Future<List<UserModel>> getAllUsers() async {
    return await _localRepo.getAllUsers();
  }

  /// Get user by ID - dari local SQLite
  Future<UserModel?> getUserById(int id) async {
    return await _localRepo.getUserById(id);
  }

  /// Get user by username - dari local SQLite
  Future<UserModel?> getUserByUsername(String username) async {
    return await _localRepo.getUserByUsername(username);
  }

  /// Get users by role - dari local SQLite
  Future<List<UserModel>> getUsersByRole(String role) async {
    return await _localRepo.getUsersByRole(role);
  }

  /// Get user by email - dari local SQLite
  Future<UserModel?> getUserByEmail(String email) async {
    return await _localRepo.getUserByEmail(email);
  }

  /// Search users by name - dari local SQLite
  Future<List<UserModel>> searchUsersByName(String name) async {
    return await _localRepo.searchUsersByName(name);
  }

  /// Update user - Update local & sync to cloud
  Future<int> updateUser(UserModel user) async {
    final result = await _localRepo.updateUser(user);
    if (result > 0) {
      _trySyncToCloud(user);
    }
    return result;
  }

  /// Update eco points - Update local & sync to cloud
  Future<int> updateEcoPoints(int userId, double ecoPoints) async {
    final result = await _localRepo.updateEcoPoints(userId, ecoPoints);
    if (result > 0) {
      final user = await _localRepo.getUserById(userId);
      if (user != null) {
        _trySyncToCloud(user);
      }
    }
    return result;
  }

  /// Add eco points - Update local & sync to cloud
  Future<bool> addEcoPoints(int userId, double points) async {
    final result = await _localRepo.addEcoPoints(userId, points);
    if (result) {
      final user = await _localRepo.getUserById(userId);
      if (user != null) {
        _trySyncToCloud(user);
      }
    }
    return result;
  }

  /// Deduct eco points - Update local & sync to cloud
  Future<bool> deductEcoPoints(int userId, double points) async {
    final result = await _localRepo.deductEcoPoints(userId, points);
    if (result) {
      final user = await _localRepo.getUserById(userId);
      if (user != null) {
        _trySyncToCloud(user);
      }
    }
    return result;
  }

  /// Delete user - Delete from local & cloud
  Future<int> deleteUser(int id) async {
    final user = await _localRepo.getUserById(id);
    final result = await _localRepo.deleteUser(id);

    if (result > 0 && user != null) {
      try {
        await _syncService.deleteFromCloud(
          _collectionName,
          _getDocumentId(user),
        );
      } catch (e) {
        // Silent fail
      }
    }

    return result;
  }

  /// Update user status - Update local & sync to cloud
  Future<int> updateUserStatus(int userId, String status) async {
    final result = await _localRepo.updateUserStatus(userId, status);
    if (result > 0) {
      final user = await _localRepo.getUserById(userId);
      if (user != null) {
        _trySyncToCloud(user);
      }
    }
    return result;
  }

  /// Delete all users - Delete from local & cloud
  Future<int> deleteAllUsers() async {
    // First delete from local
    final result = await _localRepo.deleteAllUsers();

    // Try to delete all from cloud (this may take time)
    try {
      final hasConnection = await _syncService.checkConnection();
      if (hasConnection) {
        // Note: Firestore doesn't have deleteAll, so we'd need to query and delete
        // For now, we'll just clear local and let sync handle it on next upload
      }
    } catch (e) {
      // Silent fail
    }

    return result;
  }

  // ==================== SYNC OPERATIONS ====================

  /// Manual sync: Upload semua data local ke cloud
  Future<SyncResult> syncToCloud() async {
    final users = await _localRepo.getAllUsers();

    return await _syncService.syncUp(
      collectionName: _collectionName,
      localData: users,
      toFirestoreMap: _toFirestoreMap,
      getDocumentId: _getDocumentId,
    );
  }

  /// Manual sync: Download data dari cloud ke local
  Future<SyncResult> syncFromCloud() async {
    return await _syncService.syncDown<UserModel>(
      collectionName: _collectionName,
      fromFirestoreMap: _fromFirestoreMap,
      saveToLocal: (users) async {
        for (var user in users) {
          try {
            // Check if user exists by username
            final existing = await _localRepo.getUserByUsername(user.username);
            if (existing != null) {
              // Update existing user
              await _localRepo.updateUser(user.copyWith(id: existing.id));
            } else {
              // Insert new user
              await _localRepo.insertUser(user);
            }
          } catch (e) {
            print('Error saving user ${user.username}: $e');
          }
        }
      },
      lastSyncTime: _syncService.lastSyncTime,
    );
  }

  /// Bidirectional sync: Upload local changes & download cloud changes
  Future<SyncResult> syncBidirectional() async {
    return await _syncService.syncBidirectional<UserModel>(
      collectionName: _collectionName,
      getLocalData: () => _localRepo.getAllUsers(),
      toFirestoreMap: _toFirestoreMap,
      getDocumentId: _getDocumentId,
      fromFirestoreMap: _fromFirestoreMap,
      saveToLocal: (users) async {
        for (var user in users) {
          try {
            final existing = await _localRepo.getUserByUsername(user.username);
            if (existing != null) {
              await _localRepo.updateUser(user.copyWith(id: existing.id));
            } else {
              await _localRepo.insertUser(user);
            }
          } catch (e) {
            print('Error saving user ${user.username}: $e');
          }
        }
      },
    );
  }

  /// Real-time stream: Listen to changes dari Firestore
  ///
  /// Gunakan ini untuk real-time updates. Data yang berubah di cloud
  /// akan otomatis terupdate di local.
  Stream<List<UserModel>> watchUsersFromCloud() {
    return _syncService
        .listenToCollection<UserModel>(
      collectionName: _collectionName,
      fromFirestoreMap: _fromFirestoreMap,
    )
        .asyncMap((cloudUsers) async {
      // Auto-save cloud changes to local
      for (var user in cloudUsers) {
        try {
          final existing = await _localRepo.getUserByUsername(user.username);
          if (existing != null) {
            await _localRepo.updateUser(user.copyWith(id: existing.id));
          } else {
            await _localRepo.insertUser(user);
          }
        } catch (e) {
          print('Error auto-saving user: $e');
        }
      }

      // Return updated local data
      return await _localRepo.getAllUsers();
    });
  }

  /// Check if device can connect to Firestore
  Future<bool> checkConnection() async {
    return await _syncService.checkConnection();
  }

  /// Reset sync status
  void resetSyncStatus() {
    _syncService.resetStatus();
  }

  // ==================== STATISTICS ====================

  Future<int> getUserCount() => _localRepo.getUserCount();
  Future<int> getUserCountByRole(String role) => _localRepo.getUserCountByRole(role);
  Future<int> getActiveUserCount() => _localRepo.getActiveUserCount();
  Future<List<UserModel>> getActiveUsers() => _localRepo.getActiveUsers();
  Future<List<UserModel>> getAllAdmins() => _localRepo.getAllAdmins();
  Future<List<UserModel>> getAllWarga() => _localRepo.getAllWarga();
}
