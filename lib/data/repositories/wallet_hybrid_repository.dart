import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wallet_model.dart';
import 'wallet_repository.dart';
import '../../core/services/firebase_sync_service.dart';

/// Hybrid Repository: SQLite (local) + Firestore (cloud sync) for Wallets
///
/// Strategy:
/// 1. All CRUD operations are performed on SQLite first (offline-first)
/// 2. Data is automatically synced to Firestore when internet is available
/// 3. Can pull data from Firestore to sync across devices
/// 4. Supports real-time updates from Firestore
/// Each user has one wallet, using userId as document ID for sync
class WalletHybridRepository {
  final WalletRepository _localRepo = WalletRepository();
  final FirebaseSyncService _syncService = FirebaseSyncService();
  final String _collectionName = 'wallets';

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Getters for sync status
  SyncStatus get syncStatus => _syncService.status;
  DateTime? get lastSyncTime => _syncService.lastSyncTime;
  String? get lastError => _syncService.lastError;

  /// Helper: Convert WalletModel to Firestore map
  Map<String, dynamic> _toFirestoreMap(WalletModel wallet) {
    final map = wallet.toMap();
    map.remove('id'); // Firestore uses userId as document ID
    return map;
  }

  /// Helper: Convert Firestore map to WalletModel
  WalletModel _fromFirestoreMap(Map<String, dynamic> map) {
    return WalletModel.fromMap(map);
  }

  /// Helper: Get document ID from wallet (use userId as document ID)
  String _getDocumentId(WalletModel wallet) {
    return wallet.userId.toString();
  }

  /// Helper: Try to sync to cloud (silent fail if no connection)
  Future<void> _trySyncToCloud(WalletModel wallet) async {
    try {
      final hasConnection = await _syncService.checkConnection();
      if (!hasConnection) return;

      await _firestore
          .collection(_collectionName)
          .doc(_getDocumentId(wallet))
          .set(_toFirestoreMap(wallet), SetOptions(merge: true));
    } catch (e) {
      // Silent fail - data is already saved locally
      print('Background sync failed: $e');
    }
  }

  // ==================== CRUD OPERATIONS ====================

  /// Create wallet - Save to local & sync to cloud
  Future<int> createWallet(WalletModel wallet) async {
    // 1. Save to SQLite first (offline-first)
    final localId = await _localRepo.createWallet(wallet);

    // 2. Try to sync to cloud (background, non-blocking)
    final walletWithId = wallet.copyWith(id: localId);
    _trySyncToCloud(walletWithId);

    return localId;
  }

  /// Get wallet by user ID - from local SQLite
  Future<WalletModel?> getWalletByUserId(int userId) async {
    return await _localRepo.getWalletByUserId(userId);
  }

  /// Get or create wallet - from local SQLite
  Future<WalletModel> getOrCreateWallet(int userId) async {
    return await _localRepo.getOrCreateWallet(userId);
  }

  /// Get all wallets - from local SQLite
  Future<List<WalletModel>> getAllWallets() async {
    return await _localRepo.getAllWallets();
  }

  /// Update wallet - Update local & sync to cloud
  Future<int> updateWallet(WalletModel wallet) async {
    final result = await _localRepo.updateWallet(wallet);
    if (result > 0) {
      _trySyncToCloud(wallet);
    }
    return result;
  }

  /// Add points - Update local & sync to cloud
  Future<bool> addPoints(int userId, double points) async {
    final result = await _localRepo.addPoints(userId, points);
    if (result) {
      final wallet = await _localRepo.getWalletByUserId(userId);
      if (wallet != null) {
        _trySyncToCloud(wallet);
      }
    }
    return result;
  }

  /// Deduct points - Update local & sync to cloud
  Future<bool> deductPoints(int userId, double points) async {
    final result = await _localRepo.deductPoints(userId, points);
    if (result) {
      final wallet = await _localRepo.getWalletByUserId(userId);
      if (wallet != null) {
        _trySyncToCloud(wallet);
      }
    }
    return result;
  }

  /// Get balance - from local SQLite
  Future<double> getBalance(int userId) async {
    return await _localRepo.getBalance(userId);
  }

  /// Get rupiah value - from local SQLite
  Future<double> getRupiahValue(int userId) async {
    return await _localRepo.getRupiahValue(userId);
  }

  /// Delete wallet - Delete from local & cloud
  Future<int> deleteWallet(int userId) async {
    final wallet = await _localRepo.getWalletByUserId(userId);
    final result = await _localRepo.deleteWalletByUserId(userId);

    if (result > 0 && wallet != null) {
      try {
        await _syncService.deleteFromCloud(
          _collectionName,
          _getDocumentId(wallet),
        );
      } catch (e) {
        // Silent fail
      }
    }

    return result;
  }

  /// Check if wallet exists for user
  Future<bool> walletExists(int userId) async {
    return await _localRepo.walletExists(userId);
  }

  /// Get total eco points - from local SQLite
  Future<double> getTotalEcoPoints() async {
    return await _localRepo.getTotalEcoPoints();
  }

  /// Get wallet count - from local SQLite
  Future<int> getWalletCount() async {
    return await _localRepo.getWalletCount();
  }

  // ==================== SYNC OPERATIONS ====================

  /// Manual sync: Upload all local data to cloud
  Future<SyncResult> syncToCloud() async {
    final wallets = await _localRepo.getAllWallets();

    return await _syncService.syncUp(
      collectionName: _collectionName,
      localData: wallets,
      toFirestoreMap: _toFirestoreMap,
      getDocumentId: _getDocumentId,
    );
  }

  /// Manual sync: Download data from cloud to local
  Future<SyncResult> syncFromCloud() async {
    return await _syncService.syncDown<WalletModel>(
      collectionName: _collectionName,
      fromFirestoreMap: _fromFirestoreMap,
      saveToLocal: (wallets) async {
        for (var wallet in wallets) {
          try {
            // Check if wallet exists by userId
            final existing = await _localRepo.getWalletByUserId(wallet.userId);
            if (existing != null) {
              // Update existing wallet
              await _localRepo.updateWallet(wallet.copyWith(id: existing.id));
            } else {
              // Create new wallet
              await _localRepo.createWallet(wallet);
            }
          } catch (e) {
            print('Error saving wallet for user ${wallet.userId}: $e');
          }
        }
      },
      lastSyncTime: _syncService.lastSyncTime,
    );
  }

  /// Bidirectional sync: Upload local changes & download cloud changes
  Future<SyncResult> syncBidirectional() async {
    return await _syncService.syncBidirectional<WalletModel>(
      collectionName: _collectionName,
      getLocalData: () => _localRepo.getAllWallets(),
      toFirestoreMap: _toFirestoreMap,
      getDocumentId: _getDocumentId,
      fromFirestoreMap: _fromFirestoreMap,
      saveToLocal: (wallets) async {
        for (var wallet in wallets) {
          try {
            final existing = await _localRepo.getWalletByUserId(wallet.userId);
            if (existing != null) {
              await _localRepo.updateWallet(wallet.copyWith(id: existing.id));
            } else {
              await _localRepo.createWallet(wallet);
            }
          } catch (e) {
            print('Error saving wallet for user ${wallet.userId}: $e');
          }
        }
      },
    );
  }

  /// Real-time stream: Listen to changes from Firestore
  ///
  /// Use this for real-time updates. Data that changes in the cloud
  /// will be automatically updated locally.
  Stream<List<WalletModel>> watchWalletsFromCloud() {
    return _syncService
        .listenToCollection<WalletModel>(
      collectionName: _collectionName,
      fromFirestoreMap: _fromFirestoreMap,
    )
        .asyncMap((cloudWallets) async {
      // Auto-save cloud changes to local
      for (var wallet in cloudWallets) {
        try {
          final existing = await _localRepo.getWalletByUserId(wallet.userId);
          if (existing != null) {
            await _localRepo.updateWallet(wallet.copyWith(id: existing.id));
          } else {
            await _localRepo.createWallet(wallet);
          }
        } catch (e) {
          print('Error auto-saving wallet: $e');
        }
      }

      // Return updated local data
      return await _localRepo.getAllWallets();
    });
  }

  /// Real-time stream for specific user wallet
  Stream<WalletModel?> watchUserWalletFromCloud(int userId) {
    return _firestore
        .collection(_collectionName)
        .doc(userId.toString())
        .snapshots()
        .asyncMap((docSnapshot) async {
      if (!docSnapshot.exists) return null;

      final data = docSnapshot.data() as Map<String, dynamic>;
      final wallet = _fromFirestoreMap({...data, 'user_id': userId});

      // Auto-save to local
      try {
        final existing = await _localRepo.getWalletByUserId(userId);
        if (existing != null) {
          await _localRepo.updateWallet(wallet.copyWith(id: existing.id));
        } else {
          await _localRepo.createWallet(wallet);
        }
      } catch (e) {
        print('Error auto-saving wallet: $e');
      }

      return await _localRepo.getWalletByUserId(userId);
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
}
