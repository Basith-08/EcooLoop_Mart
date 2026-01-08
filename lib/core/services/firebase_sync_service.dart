import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Sync status untuk tracking proses sinkronisasi
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
  conflict,
}

/// Result dari operasi sync
class SyncResult {
  final SyncStatus status;
  final String? message;
  final int? itemsSynced;
  final DateTime timestamp;

  SyncResult({
    required this.status,
    this.message,
    this.itemsSynced,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isSuccess => status == SyncStatus.success;
  bool get hasError => status == SyncStatus.error;
}

/// Service untuk menangani sinkronisasi antara SQLite (local) dan Firestore (cloud)
///
/// Strategi Sync:
/// - SQLite sebagai primary database (offline-first)
/// - Firestore untuk backup dan sync antar device
/// - Last-write-wins untuk conflict resolution
/// - Timestamp-based sync
class FirebaseSyncService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SyncStatus _status = SyncStatus.idle;
  String? _lastError;
  DateTime? _lastSyncTime;

  SyncStatus get status => _status;
  String? get lastError => _lastError;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get isSyncing => _status == SyncStatus.syncing;

  /// Update sync status dan notify listeners
  void _updateStatus(SyncStatus status, {String? error}) {
    _status = status;
    _lastError = error;
    if (status == SyncStatus.success) {
      _lastSyncTime = DateTime.now();
    }
    notifyListeners();
  }

  /// Sync data dari SQLite ke Firestore (Upload)
  ///
  /// [collectionName] - nama collection di Firestore
  /// [localData] - list data dari SQLite
  /// [toFirestoreMap] - function untuk convert local model ke Firestore map
  /// [getDocumentId] - function untuk get document ID dari local model
  Future<SyncResult> syncUp<T>({
    required String collectionName,
    required List<T> localData,
    required Map<String, dynamic> Function(T) toFirestoreMap,
    required String Function(T) getDocumentId,
  }) async {
    try {
      _updateStatus(SyncStatus.syncing);

      final batch = _firestore.batch();
      int count = 0;

      for (var item in localData) {
        final docId = getDocumentId(item);
        final docRef = _firestore.collection(collectionName).doc(docId);
        final data = toFirestoreMap(item);

        // Add sync timestamp
        data['synced_at'] = FieldValue.serverTimestamp();

        batch.set(docRef, data, SetOptions(merge: true));
        count++;
      }

      await batch.commit();

      _updateStatus(SyncStatus.success);
      return SyncResult(
        status: SyncStatus.success,
        message: 'Successfully synced $count items to cloud',
        itemsSynced: count,
      );
    } catch (e) {
      _updateStatus(SyncStatus.error, error: e.toString());
      return SyncResult(
        status: SyncStatus.error,
        message: 'Failed to sync to cloud: $e',
      );
    }
  }

  /// Sync data dari Firestore ke SQLite (Download)
  ///
  /// [collectionName] - nama collection di Firestore
  /// [fromFirestoreMap] - function untuk convert Firestore map ke local model
  /// [saveToLocal] - function untuk save ke SQLite
  /// [lastSyncTime] - timestamp terakhir sync (untuk incremental sync)
  Future<SyncResult> syncDown<T>({
    required String collectionName,
    required T Function(Map<String, dynamic>) fromFirestoreMap,
    required Future<void> Function(List<T>) saveToLocal,
    DateTime? lastSyncTime,
  }) async {
    try {
      _updateStatus(SyncStatus.syncing);

      Query query = _firestore.collection(collectionName);

      // Incremental sync: hanya ambil data yang berubah setelah lastSyncTime
      if (lastSyncTime != null) {
        query = query.where('synced_at', isGreaterThan: Timestamp.fromDate(lastSyncTime));
      }

      final querySnapshot = await query.get();
      final items = <T>[];

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        // Note: Tidak menambahkan doc.id karena ID di SQLite adalah auto-increment integer
        // sedangkan doc.id di Firestore adalah string. Repository akan handle ID mapping.
        items.add(fromFirestoreMap(data));
      }

      // Save to local SQLite
      if (items.isNotEmpty) {
        await saveToLocal(items);
      }

      _updateStatus(SyncStatus.success);
      return SyncResult(
        status: SyncStatus.success,
        message: 'Successfully synced ${items.length} items from cloud',
        itemsSynced: items.length,
      );
    } catch (e) {
      _updateStatus(SyncStatus.error, error: e.toString());
      return SyncResult(
        status: SyncStatus.error,
        message: 'Failed to sync from cloud: $e',
      );
    }
  }

  /// Bidirectional sync (Upload & Download)
  Future<SyncResult> syncBidirectional<T>({
    required String collectionName,
    required Future<List<T>> Function() getLocalData,
    required Map<String, dynamic> Function(T) toFirestoreMap,
    required String Function(T) getDocumentId,
    required T Function(Map<String, dynamic>) fromFirestoreMap,
    required Future<void> Function(List<T>) saveToLocal,
  }) async {
    try {
      _updateStatus(SyncStatus.syncing);

      // 1. Sync Up: Upload local changes to cloud
      final localData = await getLocalData();
      final uploadResult = await syncUp(
        collectionName: collectionName,
        localData: localData,
        toFirestoreMap: toFirestoreMap,
        getDocumentId: getDocumentId,
      );

      if (!uploadResult.isSuccess) {
        return uploadResult;
      }

      // 2. Sync Down: Download cloud changes to local
      final downloadResult = await syncDown(
        collectionName: collectionName,
        fromFirestoreMap: fromFirestoreMap,
        saveToLocal: saveToLocal,
        lastSyncTime: _lastSyncTime,
      );

      if (!downloadResult.isSuccess) {
        return downloadResult;
      }

      _updateStatus(SyncStatus.success);
      return SyncResult(
        status: SyncStatus.success,
        message: 'Bidirectional sync completed successfully',
        itemsSynced: (uploadResult.itemsSynced ?? 0) + (downloadResult.itemsSynced ?? 0),
      );
    } catch (e) {
      _updateStatus(SyncStatus.error, error: e.toString());
      return SyncResult(
        status: SyncStatus.error,
        message: 'Bidirectional sync failed: $e',
      );
    }
  }

  /// Real-time listener untuk auto-sync dari cloud ke local
  ///
  /// Returns a StreamSubscription yang bisa di-cancel
  Stream<List<T>> listenToCollection<T>({
    required String collectionName,
    required T Function(Map<String, dynamic>) fromFirestoreMap,
  }) {
    return _firestore
        .collection(collectionName)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Note: Tidak menambahkan doc.id karena ID di SQLite adalah auto-increment integer
        // sedangkan doc.id di Firestore adalah string. Repository akan handle ID mapping.
        return fromFirestoreMap(data);
      }).toList();
    });
  }

  /// Delete data dari Firestore
  Future<SyncResult> deleteFromCloud(String collectionName, String docId) async {
    try {
      await _firestore.collection(collectionName).doc(docId).delete();
      return SyncResult(
        status: SyncStatus.success,
        message: 'Item deleted from cloud',
      );
    } catch (e) {
      return SyncResult(
        status: SyncStatus.error,
        message: 'Failed to delete from cloud: $e',
      );
    }
  }

  /// Check koneksi internet dan Firestore availability
  Future<bool> checkConnection() async {
    try {
      await _firestore
          .collection('_health_check')
          .limit(1)
          .get(const GetOptions(source: Source.server));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reset sync status
  void resetStatus() {
    _updateStatus(SyncStatus.idle);
    _lastError = null;
  }
}
