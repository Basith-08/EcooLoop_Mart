import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/waste_rate_model.dart';
import 'waste_rate_repository.dart';
import '../../core/services/firebase_sync_service.dart';

/// Hybrid Repository: SQLite (local) + Firestore (cloud sync) for WasteRates
///
/// Strategy:
/// 1. All CRUD operations are performed on SQLite first (offline-first)
/// 2. Data is automatically synced to Firestore when internet is available
/// 3. Can pull data from Firestore to sync across devices
/// 4. Supports real-time updates from Firestore
class WasteRateHybridRepository {
  final WasteRateRepository _localRepo = WasteRateRepository();
  final FirebaseSyncService _syncService = FirebaseSyncService();
  final String _collectionName = 'waste_rates';

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Getters for sync status
  SyncStatus get syncStatus => _syncService.status;
  DateTime? get lastSyncTime => _syncService.lastSyncTime;
  String? get lastError => _syncService.lastError;

  /// Helper: Convert WasteRateModel to Firestore map
  Map<String, dynamic> _toFirestoreMap(WasteRateModel wasteRate) {
    final map = wasteRate.toMap();
    map.remove('id'); // Firestore uses document ID
    // Convert is_active from int to bool for Firestore
    map['is_active'] = wasteRate.isActive;
    return map;
  }

  /// Helper: Convert Firestore map to WasteRateModel
  WasteRateModel _fromFirestoreMap(Map<String, dynamic> map) {
    // Convert is_active from bool to int for SQLite compatibility
    if (map['is_active'] is bool) {
      map['is_active'] = map['is_active'] ? 1 : 0;
    }
    return WasteRateModel.fromMap(map);
  }

  /// Helper: Get document ID from wasteRate (use wasteRate ID as string)
  String _getDocumentId(WasteRateModel wasteRate) {
    return wasteRate.id?.toString() ??
           DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Helper: Try to sync to cloud (silent fail if no connection)
  Future<void> _trySyncToCloud(WasteRateModel wasteRate) async {
    try {
      final hasConnection = await _syncService.checkConnection();
      if (!hasConnection) return;

      await _firestore
          .collection(_collectionName)
          .doc(_getDocumentId(wasteRate))
          .set(_toFirestoreMap(wasteRate), SetOptions(merge: true));
    } catch (e) {
      // Silent fail - data is already saved locally
      print('Background sync failed: $e');
    }
  }

  // ==================== CRUD OPERATIONS ====================

  /// Upsert waste rate (insert or update) - Save to local & sync to cloud
  Future<int> upsertWasteRate(WasteRateModel wasteRate) async {
    // 1. Save to SQLite first (offline-first)
    final localId = await _localRepo.upsertWasteRate(wasteRate);

    // 2. Try to sync to cloud (background, non-blocking)
    final wasteRateWithId = wasteRate.copyWith(id: localId);
    _trySyncToCloud(wasteRateWithId);

    return localId;
  }

  /// Get active waste rates - from local SQLite
  Future<List<WasteRateModel>> getActiveWasteRates() async {
    return await _localRepo.getActiveWasteRates();
  }

  /// Get waste rate by ID - from local SQLite
  Future<WasteRateModel?> getWasteRateById(int id) async {
    return await _localRepo.getWasteRateById(id);
  }

  /// Get waste rate by name - from local SQLite
  Future<WasteRateModel?> getWasteRateByName(String name) async {
    return await _localRepo.getWasteRateByName(name);
  }

  // ==================== SYNC OPERATIONS ====================

  /// Manual sync: Upload all local data to cloud
  Future<SyncResult> syncToCloud() async {
    final wasteRates = await _localRepo.getActiveWasteRates();

    return await _syncService.syncUp(
      collectionName: _collectionName,
      localData: wasteRates,
      toFirestoreMap: _toFirestoreMap,
      getDocumentId: _getDocumentId,
    );
  }

  /// Manual sync: Download data from cloud to local
  Future<SyncResult> syncFromCloud() async {
    return await _syncService.syncDown<WasteRateModel>(
      collectionName: _collectionName,
      fromFirestoreMap: _fromFirestoreMap,
      saveToLocal: (wasteRates) async {
        for (var wasteRate in wasteRates) {
          try {
            // Upsert (insert or update)
            await _localRepo.upsertWasteRate(wasteRate);
          } catch (e) {
            print('Error saving waste rate ${wasteRate.name}: $e');
          }
        }
      },
      lastSyncTime: _syncService.lastSyncTime,
    );
  }

  /// Bidirectional sync: Upload local changes & download cloud changes
  Future<SyncResult> syncBidirectional() async {
    return await _syncService.syncBidirectional<WasteRateModel>(
      collectionName: _collectionName,
      getLocalData: () => _localRepo.getActiveWasteRates(),
      toFirestoreMap: _toFirestoreMap,
      getDocumentId: _getDocumentId,
      fromFirestoreMap: _fromFirestoreMap,
      saveToLocal: (wasteRates) async {
        for (var wasteRate in wasteRates) {
          try {
            // Upsert (insert or update)
            await _localRepo.upsertWasteRate(wasteRate);
          } catch (e) {
            print('Error saving waste rate ${wasteRate.name}: $e');
          }
        }
      },
    );
  }

  /// Real-time stream: Listen to changes from Firestore
  ///
  /// Use this for real-time updates. Data that changes in the cloud
  /// will be automatically updated locally.
  Stream<List<WasteRateModel>> watchWasteRatesFromCloud() {
    return _syncService
        .listenToCollection<WasteRateModel>(
      collectionName: _collectionName,
      fromFirestoreMap: _fromFirestoreMap,
    )
        .asyncMap((cloudWasteRates) async {
      // Auto-save cloud changes to local
      for (var wasteRate in cloudWasteRates) {
        try {
          // Upsert (insert or update)
          await _localRepo.upsertWasteRate(wasteRate);
        } catch (e) {
          print('Error auto-saving waste rate: $e');
        }
      }

      // Return updated local data
      return await _localRepo.getActiveWasteRates();
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
