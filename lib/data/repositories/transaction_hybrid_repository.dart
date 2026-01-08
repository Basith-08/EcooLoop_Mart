import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import 'transaction_repository.dart';
import '../../core/services/firebase_sync_service.dart';

/// Hybrid Repository: SQLite (local) + Firestore (cloud sync) for Transactions
///
/// Strategy:
/// 1. All CRUD operations are performed on SQLite first (offline-first)
/// 2. Data is automatically synced to Firestore when internet is available
/// 3. Can pull data from Firestore to sync across devices
/// 4. Supports real-time updates from Firestore
class TransactionHybridRepository {
  final TransactionRepository _localRepo = TransactionRepository();
  final FirebaseSyncService _syncService = FirebaseSyncService();
  final String _collectionName = 'transactions';

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Getters for sync status
  SyncStatus get syncStatus => _syncService.status;
  DateTime? get lastSyncTime => _syncService.lastSyncTime;
  String? get lastError => _syncService.lastError;

  /// Helper: Convert TransactionModel to Firestore map
  Map<String, dynamic> _toFirestoreMap(TransactionModel transaction) {
    final map = transaction.toMap();
    map.remove('id'); // Firestore uses document ID
    return map;
  }

  /// Helper: Convert Firestore map to TransactionModel
  TransactionModel _fromFirestoreMap(Map<String, dynamic> map) {
    return TransactionModel.fromMap(map);
  }

  /// Helper: Get document ID from transaction (use transaction ID as string)
  String _getDocumentId(TransactionModel transaction) {
    return transaction.id?.toString() ??
           DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Helper: Try to sync to cloud (silent fail if no connection)
  Future<void> _trySyncToCloud(TransactionModel transaction) async {
    try {
      final hasConnection = await _syncService.checkConnection();
      if (!hasConnection) return;

      await _firestore
          .collection(_collectionName)
          .doc(_getDocumentId(transaction))
          .set(_toFirestoreMap(transaction), SetOptions(merge: true));
    } catch (e) {
      // Silent fail - data is already saved locally
      print('Background sync failed: $e');
    }
  }

  // ==================== CRUD OPERATIONS ====================

  /// Insert transaction - Save to local & sync to cloud
  Future<int> insertTransaction(TransactionModel transaction) async {
    // 1. Save to SQLite first (offline-first)
    final localId = await _localRepo.insertTransaction(transaction);

    // 2. Try to sync to cloud (background, non-blocking)
    final transactionWithId = transaction.copyWith(id: localId);
    _trySyncToCloud(transactionWithId);

    return localId;
  }

  /// Get all transactions - from local SQLite
  Future<List<TransactionModel>> getAllTransactions() async {
    return await _localRepo.getAllTransactions();
  }

  /// Get transactions by user ID - from local SQLite
  Future<List<TransactionModel>> getTransactionsByUserId(int userId) async {
    return await _localRepo.getTransactionsByUserId(userId);
  }

  /// Get transactions by type - from local SQLite
  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    return await _localRepo.getTransactionsByType(type);
  }

  /// Get recent transactions - from local SQLite
  Future<List<TransactionModel>> getRecentTransactions({int limit = 10}) async {
    return await _localRepo.getRecentTransactions(limit: limit);
  }

  /// Get transaction by ID - from local SQLite
  Future<TransactionModel?> getTransactionById(int id) async {
    return await _localRepo.getTransactionById(id);
  }

  /// Get user deposit transactions - from local SQLite
  Future<List<TransactionModel>> getUserDepositTransactions(int userId) async {
    return await _localRepo.getTransactionsByUserIdAndType(userId, 'deposit');
  }

  /// Get user purchase transactions - from local SQLite
  Future<List<TransactionModel>> getUserPurchaseTransactions(int userId) async {
    return await _localRepo.getTransactionsByUserIdAndType(userId, 'purchase');
  }

  /// Get transactions by date range - from local SQLite
  Future<List<TransactionModel>> getTransactionsByDateRange(
      DateTime startDate, DateTime endDate) async {
    return await _localRepo.getTransactionsByDateRange(startDate, endDate);
  }

  /// Get transactions by status - from local SQLite
  Future<List<TransactionModel>> getTransactionsByStatus(String status) async {
    return await _localRepo.getTransactionsByStatus(status);
  }

  /// Get total points earned (deposit) - from local SQLite
  Future<double> getTotalPointsEarned(int userId) async {
    return await _localRepo.getTotalPointsEarned(userId);
  }

  /// Get total points spent (purchase) - from local SQLite
  Future<double> getTotalPointsSpent(int userId) async {
    return await _localRepo.getTotalPointsSpent(userId);
  }

  /// Update transaction - Update local & sync to cloud
  Future<int> updateTransaction(TransactionModel transaction) async {
    final result = await _localRepo.updateTransaction(transaction);
    if (result > 0) {
      _trySyncToCloud(transaction);
    }
    return result;
  }

  /// Update transaction status - Update local & sync to cloud
  Future<int> updateTransactionStatus(int id, String status) async {
    final result = await _localRepo.updateTransactionStatus(id, status);
    if (result > 0) {
      final transaction = await _localRepo.getTransactionById(id);
      if (transaction != null) {
        _trySyncToCloud(transaction);
      }
    }
    return result;
  }

  /// Delete transaction - Delete from local & cloud
  Future<int> deleteTransaction(int id) async {
    final transaction = await _localRepo.getTransactionById(id);
    final result = await _localRepo.deleteTransaction(id);

    if (result > 0 && transaction != null) {
      try {
        await _syncService.deleteFromCloud(
          _collectionName,
          _getDocumentId(transaction),
        );
      } catch (e) {
        // Silent fail
      }
    }

    return result;
  }

  /// Get total deposit points - from local SQLite
  Future<double> getTotalDepositPoints(int userId) async {
    return await _localRepo.getTotalPointsEarned(userId);
  }

  /// Get total purchase points - from local SQLite
  Future<double> getTotalPurchasePoints(int userId) async {
    return await _localRepo.getTotalPointsSpent(userId);
  }

  /// Get transaction count - from local SQLite
  Future<int> getTransactionCount() async {
    return await _localRepo.getTransactionCount();
  }

  /// Get transaction count by user - from local SQLite
  Future<int> getTransactionCountByUserId(int userId) async {
    final transactions = await _localRepo.getTransactionsByUserId(userId);
    return transactions.length;
  }

  // ==================== SYNC OPERATIONS ====================

  /// Manual sync: Upload all local data to cloud
  Future<SyncResult> syncToCloud() async {
    final transactions = await _localRepo.getAllTransactions();

    return await _syncService.syncUp(
      collectionName: _collectionName,
      localData: transactions,
      toFirestoreMap: _toFirestoreMap,
      getDocumentId: _getDocumentId,
    );
  }

  /// Manual sync: Download data from cloud to local
  Future<SyncResult> syncFromCloud() async {
    return await _syncService.syncDown<TransactionModel>(
      collectionName: _collectionName,
      fromFirestoreMap: _fromFirestoreMap,
      saveToLocal: (transactions) async {
        for (var transaction in transactions) {
          try {
            // Check if transaction exists by ID
            if (transaction.id != null) {
              final existing = await _localRepo.getTransactionById(transaction.id!);
              if (existing != null) {
                // Update existing transaction
                await _localRepo.updateTransaction(transaction);
              } else {
                // Insert new transaction
                await _localRepo.insertTransaction(transaction);
              }
            } else {
              await _localRepo.insertTransaction(transaction);
            }
          } catch (e) {
            print('Error saving transaction: $e');
          }
        }
      },
      lastSyncTime: _syncService.lastSyncTime,
    );
  }

  /// Bidirectional sync: Upload local changes & download cloud changes
  Future<SyncResult> syncBidirectional() async {
    return await _syncService.syncBidirectional<TransactionModel>(
      collectionName: _collectionName,
      getLocalData: () => _localRepo.getAllTransactions(),
      toFirestoreMap: _toFirestoreMap,
      getDocumentId: _getDocumentId,
      fromFirestoreMap: _fromFirestoreMap,
      saveToLocal: (transactions) async {
        for (var transaction in transactions) {
          try {
            if (transaction.id != null) {
              final existing = await _localRepo.getTransactionById(transaction.id!);
              if (existing != null) {
                await _localRepo.updateTransaction(transaction);
              } else {
                await _localRepo.insertTransaction(transaction);
              }
            } else {
              await _localRepo.insertTransaction(transaction);
            }
          } catch (e) {
            print('Error saving transaction: $e');
          }
        }
      },
    );
  }

  /// Real-time stream: Listen to changes from Firestore
  ///
  /// Use this for real-time updates. Data that changes in the cloud
  /// will be automatically updated locally.
  Stream<List<TransactionModel>> watchTransactionsFromCloud() {
    return _syncService
        .listenToCollection<TransactionModel>(
      collectionName: _collectionName,
      fromFirestoreMap: _fromFirestoreMap,
    )
        .asyncMap((cloudTransactions) async {
      // Auto-save cloud changes to local
      for (var transaction in cloudTransactions) {
        try {
          if (transaction.id != null) {
            final existing = await _localRepo.getTransactionById(transaction.id!);
            if (existing != null) {
              await _localRepo.updateTransaction(transaction);
            } else {
              await _localRepo.insertTransaction(transaction);
            }
          } else {
            await _localRepo.insertTransaction(transaction);
          }
        } catch (e) {
          print('Error auto-saving transaction: $e');
        }
      }

      // Return updated local data
      return await _localRepo.getAllTransactions();
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
