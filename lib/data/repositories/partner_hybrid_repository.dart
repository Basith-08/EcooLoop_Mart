import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/partner_model.dart';
import 'partner_repository.dart';
import '../../core/services/firebase_sync_service.dart';

/// Hybrid Repository: SQLite (local) + Firestore (cloud sync) for Partners
///
/// Strategy:
/// 1. All CRUD operations are performed on SQLite first (offline-first)
/// 2. Data is automatically synced to Firestore when internet is available
/// 3. Can pull data from Firestore to sync across devices
/// 4. Supports real-time updates from Firestore
class PartnerHybridRepository {
  final PartnerRepository _localRepo = PartnerRepository();
  final FirebaseSyncService _syncService = FirebaseSyncService();
  final String _collectionName = 'partners';

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Getters for sync status
  SyncStatus get syncStatus => _syncService.status;
  DateTime? get lastSyncTime => _syncService.lastSyncTime;
  String? get lastError => _syncService.lastError;

  /// Helper: Convert PartnerModel to Firestore map
  Map<String, dynamic> _toFirestoreMap(PartnerModel partner) {
    final map = partner.toMap();
    map.remove('id'); // Firestore uses document ID
    // Convert is_active from int to bool for Firestore
    map['is_active'] = partner.isActive;
    return map;
  }

  /// Helper: Convert Firestore map to PartnerModel
  PartnerModel _fromFirestoreMap(Map<String, dynamic> map) {
    // Convert is_active from bool to int for SQLite compatibility
    if (map['is_active'] is bool) {
      map['is_active'] = map['is_active'] ? 1 : 0;
    }
    return PartnerModel.fromMap(map);
  }

  /// Helper: Get document ID from partner (use partner ID as string)
  String _getDocumentId(PartnerModel partner) {
    return partner.id?.toString() ??
           DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Helper: Try to sync to cloud (silent fail if no connection)
  Future<void> _trySyncToCloud(PartnerModel partner) async {
    try {
      final hasConnection = await _syncService.checkConnection();
      if (!hasConnection) return;

      await _firestore
          .collection(_collectionName)
          .doc(_getDocumentId(partner))
          .set(_toFirestoreMap(partner), SetOptions(merge: true));
    } catch (e) {
      // Silent fail - data is already saved locally
      print('Background sync failed: $e');
    }
  }

  // ==================== CRUD OPERATIONS ====================

  /// Create partner - Save to local & sync to cloud
  Future<int> createPartner(PartnerModel partner) async {
    // 1. Save to SQLite first (offline-first)
    final localId = await _localRepo.createPartner(partner);

    // 2. Try to sync to cloud (background, non-blocking)
    final partnerWithId = partner.copyWith(id: localId);
    _trySyncToCloud(partnerWithId);

    return localId;
  }

  /// Get partner by ID - from local SQLite
  Future<PartnerModel?> getPartnerById(int id) async {
    return await _localRepo.getPartnerById(id);
  }

  /// Get partners by type - from local SQLite (returns active partners only)
  Future<List<PartnerModel>> getPartnersByType(String type) async {
    return await _localRepo.getPartnersByType(type);
  }

  /// Get pengrajin partners - from local SQLite
  Future<List<PartnerModel>> getPengrajinPartners() async {
    return await _localRepo.getPartnersByType('pengrajin');
  }

  /// Get grosir partners - from local SQLite
  Future<List<PartnerModel>> getGrosirPartners() async {
    return await _localRepo.getPartnersByType('grosir');
  }

  /// Update partner - Update local & sync to cloud
  Future<int> updatePartner(PartnerModel partner) async {
    final result = await _localRepo.updatePartner(partner);
    if (result > 0) {
      _trySyncToCloud(partner);
    }
    return result;
  }

  /// Set partner active status - Update local & sync to cloud
  Future<int> setPartnerActive(int id, bool isActive) async {
    final result = await _localRepo.setPartnerActive(id, isActive);
    if (result > 0) {
      final partner = await _localRepo.getPartnerById(id);
      if (partner != null) {
        _trySyncToCloud(partner);
      }
    }
    return result;
  }

  /// Get partner count by type - from local SQLite
  Future<int> getPartnerCountByType(String type) async {
    return await _localRepo.getPartnerCountByType(type);
  }

  // ==================== SYNC OPERATIONS ====================

  /// Manual sync: Upload all local data to cloud
  Future<SyncResult> syncToCloud() async {
    // Get all partners from both types
    final pengrajin = await _localRepo.getPartnersByType('pengrajin');
    final grosir = await _localRepo.getPartnersByType('grosir');
    final partners = [...pengrajin, ...grosir];

    return await _syncService.syncUp(
      collectionName: _collectionName,
      localData: partners,
      toFirestoreMap: _toFirestoreMap,
      getDocumentId: _getDocumentId,
    );
  }

  /// Manual sync: Download data from cloud to local
  Future<SyncResult> syncFromCloud() async {
    return await _syncService.syncDown<PartnerModel>(
      collectionName: _collectionName,
      fromFirestoreMap: _fromFirestoreMap,
      saveToLocal: (partners) async {
        for (var partner in partners) {
          try {
            // Check if partner exists by ID
            if (partner.id != null) {
              final existing = await _localRepo.getPartnerById(partner.id!);
              if (existing != null) {
                // Update existing partner
                await _localRepo.updatePartner(partner);
              } else {
                // Create new partner
                await _localRepo.createPartner(partner);
              }
            } else {
              await _localRepo.createPartner(partner);
            }
          } catch (e) {
            print('Error saving partner ${partner.name}: $e');
          }
        }
      },
      lastSyncTime: _syncService.lastSyncTime,
    );
  }

  /// Bidirectional sync: Upload local changes & download cloud changes
  Future<SyncResult> syncBidirectional() async {
    return await _syncService.syncBidirectional<PartnerModel>(
      collectionName: _collectionName,
      getLocalData: () async {
        final pengrajin = await _localRepo.getPartnersByType('pengrajin');
        final grosir = await _localRepo.getPartnersByType('grosir');
        return [...pengrajin, ...grosir];
      },
      toFirestoreMap: _toFirestoreMap,
      getDocumentId: _getDocumentId,
      fromFirestoreMap: _fromFirestoreMap,
      saveToLocal: (partners) async {
        for (var partner in partners) {
          try {
            if (partner.id != null) {
              final existing = await _localRepo.getPartnerById(partner.id!);
              if (existing != null) {
                await _localRepo.updatePartner(partner);
              } else {
                await _localRepo.createPartner(partner);
              }
            } else {
              await _localRepo.createPartner(partner);
            }
          } catch (e) {
            print('Error saving partner ${partner.name}: $e');
          }
        }
      },
    );
  }

  /// Real-time stream: Listen to changes from Firestore
  ///
  /// Use this for real-time updates. Data that changes in the cloud
  /// will be automatically updated locally.
  Stream<List<PartnerModel>> watchPartnersFromCloud() {
    return _syncService
        .listenToCollection<PartnerModel>(
      collectionName: _collectionName,
      fromFirestoreMap: _fromFirestoreMap,
    )
        .asyncMap((cloudPartners) async {
      // Auto-save cloud changes to local
      for (var partner in cloudPartners) {
        try {
          if (partner.id != null) {
            final existing = await _localRepo.getPartnerById(partner.id!);
            if (existing != null) {
              await _localRepo.updatePartner(partner);
            } else {
              await _localRepo.createPartner(partner);
            }
          } else {
            await _localRepo.createPartner(partner);
          }
        } catch (e) {
          print('Error auto-saving partner: $e');
        }
      }

      // Return updated local data
      final pengrajin = await _localRepo.getPartnersByType('pengrajin');
      final grosir = await _localRepo.getPartnersByType('grosir');
      return [...pengrajin, ...grosir];
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
