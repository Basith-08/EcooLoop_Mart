import 'package:flutter/foundation.dart';
import '../core/services/firebase_sync_service.dart';
import '../data/repositories/user_hybrid_repository.dart';

/// ViewModel untuk mengelola synchronization antara local dan cloud
///
/// Gunakan ini di UI untuk:
/// - Show sync status
/// - Manual sync trigger
/// - Monitor sync progress
class SyncViewModel extends ChangeNotifier {
  final UserHybridRepository _userRepo = UserHybridRepository();

  bool _isSyncing = false;
  String? _errorMessage;
  String? _successMessage;
  DateTime? _lastSyncTime;
  int? _lastSyncedItems;

  // Getters
  bool get isSyncing => _isSyncing;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  DateTime? get lastSyncTime => _lastSyncTime;
  int? get lastSyncedItems => _lastSyncedItems;
  bool get hasError => _errorMessage != null;
  bool get hasSuccess => _successMessage != null;

  // Get sync status dari repository
  SyncStatus get syncStatus => _userRepo.syncStatus;

  /// Check internet connection
  Future<bool> checkConnection() async {
    try {
      return await _userRepo.checkConnection();
    } catch (e) {
      return false;
    }
  }

  /// Sync dari local ke cloud (Upload)
  Future<void> syncToCloud() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Check connection first
      final hasConnection = await checkConnection();
      if (!hasConnection) {
        throw Exception('Tidak ada koneksi internet');
      }

      final result = await _userRepo.syncToCloud();

      if (result.isSuccess) {
        _successMessage = result.message ?? 'Data berhasil di-upload ke cloud';
        _lastSyncTime = result.timestamp;
        _lastSyncedItems = result.itemsSynced;
      } else {
        _errorMessage = result.message ?? 'Gagal upload ke cloud';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Sync dari cloud ke local (Download)
  Future<void> syncFromCloud() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Check connection first
      final hasConnection = await checkConnection();
      if (!hasConnection) {
        throw Exception('Tidak ada koneksi internet');
      }

      final result = await _userRepo.syncFromCloud();

      if (result.isSuccess) {
        _successMessage = result.message ?? 'Data berhasil di-download dari cloud';
        _lastSyncTime = result.timestamp;
        _lastSyncedItems = result.itemsSynced;
      } else {
        _errorMessage = result.message ?? 'Gagal download dari cloud';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Bidirectional sync (Upload & Download)
  Future<void> syncBidirectional() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Check connection first
      final hasConnection = await checkConnection();
      if (!hasConnection) {
        throw Exception('Tidak ada koneksi internet');
      }

      final result = await _userRepo.syncBidirectional();

      if (result.isSuccess) {
        _successMessage = result.message ?? 'Sync berhasil';
        _lastSyncTime = result.timestamp;
        _lastSyncedItems = result.itemsSynced;
      } else {
        _errorMessage = result.message ?? 'Sync gagal';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Clear messages
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Reset sync status
  void resetStatus() {
    _isSyncing = false;
    _errorMessage = null;
    _successMessage = null;
    _userRepo.resetSyncStatus();
    notifyListeners();
  }

  /// Get sync status display text
  String getSyncStatusText() {
    switch (syncStatus) {
      case SyncStatus.idle:
        return 'Siap untuk sync';
      case SyncStatus.syncing:
        return 'Sedang sync...';
      case SyncStatus.success:
        if (_lastSyncTime != null) {
          final diff = DateTime.now().difference(_lastSyncTime!);
          if (diff.inMinutes < 1) {
            return 'Sync ${diff.inSeconds} detik yang lalu';
          } else if (diff.inHours < 1) {
            return 'Sync ${diff.inMinutes} menit yang lalu';
          } else if (diff.inDays < 1) {
            return 'Sync ${diff.inHours} jam yang lalu';
          } else {
            return 'Sync ${diff.inDays} hari yang lalu';
          }
        }
        return 'Sync berhasil';
      case SyncStatus.error:
        return 'Sync gagal';
      case SyncStatus.conflict:
        return 'Konflik data';
    }
  }
}
