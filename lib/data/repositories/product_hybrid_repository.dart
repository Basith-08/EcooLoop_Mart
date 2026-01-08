import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import 'product_repository.dart';
import '../../core/services/firebase_sync_service.dart';

/// Hybrid Repository: SQLite (local) + Firestore (cloud sync) for Products
///
/// Strategy:
/// 1. All CRUD operations are performed on SQLite first (offline-first)
/// 2. Data is automatically synced to Firestore when internet is available
/// 3. Can pull data from Firestore to sync across devices
/// 4. Supports real-time updates from Firestore
class ProductHybridRepository {
  final ProductRepository _localRepo = ProductRepository();
  final FirebaseSyncService _syncService = FirebaseSyncService();
  final String _collectionName = 'products';

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Getters for sync status
  SyncStatus get syncStatus => _syncService.status;
  DateTime? get lastSyncTime => _syncService.lastSyncTime;
  String? get lastError => _syncService.lastError;

  /// Helper: Convert ProductModel to Firestore map
  Map<String, dynamic> _toFirestoreMap(ProductModel product) {
    final map = product.toMap();
    map.remove('id'); // Firestore uses document ID
    // Convert is_eco_friendly from int to bool for Firestore
    map['is_eco_friendly'] = product.isEcoFriendly;
    return map;
  }

  /// Helper: Convert Firestore map to ProductModel
  ProductModel _fromFirestoreMap(Map<String, dynamic> map) {
    // Convert is_eco_friendly from bool to int for SQLite compatibility
    if (map['is_eco_friendly'] is bool) {
      map['is_eco_friendly'] = map['is_eco_friendly'] ? 1 : 0;
    }
    return ProductModel.fromMap(map);
  }

  /// Helper: Get document ID from product (use product ID as string)
  String _getDocumentId(ProductModel product) {
    return product.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Helper: Try to sync to cloud (silent fail if no connection)
  Future<void> _trySyncToCloud(ProductModel product) async {
    try {
      final hasConnection = await _syncService.checkConnection();
      if (!hasConnection) return;

      await _firestore
          .collection(_collectionName)
          .doc(_getDocumentId(product))
          .set(_toFirestoreMap(product), SetOptions(merge: true));
    } catch (e) {
      // Silent fail - data is already saved locally
      print('Background sync failed: $e');
    }
  }

  // ==================== CRUD OPERATIONS ====================

  /// Insert product - Save to local & sync to cloud
  Future<int> insertProduct(ProductModel product) async {
    // 1. Save to SQLite first (offline-first)
    final localId = await _localRepo.insertProduct(product);

    // 2. Try to sync to cloud (background, non-blocking)
    final productWithId = product.copyWith(id: localId);
    _trySyncToCloud(productWithId);

    return localId;
  }

  /// Get all products - from local SQLite
  Future<List<ProductModel>> getAllProducts() async {
    return await _localRepo.getAllProducts();
  }

  /// Get available products - from local SQLite
  Future<List<ProductModel>> getAvailableProducts() async {
    return await _localRepo.getAvailableProducts();
  }

  /// Get product by ID - from local SQLite
  Future<ProductModel?> getProductById(int id) async {
    return await _localRepo.getProductById(id);
  }

  /// Get products by category - from local SQLite
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    return await _localRepo.getProductsByCategory(category);
  }

  /// Update product - Update local & sync to cloud
  Future<int> updateProduct(ProductModel product) async {
    final result = await _localRepo.updateProduct(product);
    if (result > 0) {
      _trySyncToCloud(product);
    }
    return result;
  }

  /// Update stock - Update local & sync to cloud
  Future<int> updateStock(int productId, int newStock) async {
    final result = await _localRepo.updateStock(productId, newStock);
    if (result > 0) {
      final product = await _localRepo.getProductById(productId);
      if (product != null) {
        _trySyncToCloud(product);
      }
    }
    return result;
  }

  /// Decrease stock - Update local & sync to cloud
  Future<bool> decreaseStock(int productId, int quantity) async {
    final result = await _localRepo.decreaseStock(productId, quantity);
    if (result) {
      final product = await _localRepo.getProductById(productId);
      if (product != null) {
        _trySyncToCloud(product);
      }
    }
    return result;
  }

  /// Increase stock - Update local & sync to cloud
  Future<bool> increaseStock(int productId, int quantity) async {
    final result = await _localRepo.increaseStock(productId, quantity);
    if (result) {
      final product = await _localRepo.getProductById(productId);
      if (product != null) {
        _trySyncToCloud(product);
      }
    }
    return result;
  }

  /// Delete product - Delete from local & cloud
  Future<int> deleteProduct(int id) async {
    final product = await _localRepo.getProductById(id);
    final result = await _localRepo.deleteProduct(id);

    if (result > 0 && product != null) {
      try {
        await _syncService.deleteFromCloud(
          _collectionName,
          _getDocumentId(product),
        );
      } catch (e) {
        // Silent fail
      }
    }

    return result;
  }

  /// Search products by name - from local SQLite
  Future<List<ProductModel>> searchProductsByName(String name) async {
    return await _localRepo.searchProductsByName(name);
  }

  /// Get product count - from local SQLite
  Future<int> getProductCount() async {
    return await _localRepo.getProductCount();
  }

  // ==================== SYNC OPERATIONS ====================

  /// Manual sync: Upload all local data to cloud
  Future<SyncResult> syncToCloud() async {
    final products = await _localRepo.getAllProducts();

    return await _syncService.syncUp(
      collectionName: _collectionName,
      localData: products,
      toFirestoreMap: _toFirestoreMap,
      getDocumentId: _getDocumentId,
    );
  }

  /// Manual sync: Download data from cloud to local
  Future<SyncResult> syncFromCloud() async {
    return await _syncService.syncDown<ProductModel>(
      collectionName: _collectionName,
      fromFirestoreMap: _fromFirestoreMap,
      saveToLocal: (products) async {
        for (var product in products) {
          try {
            // Check if product exists by ID
            if (product.id != null) {
              final existing = await _localRepo.getProductById(product.id!);
              if (existing != null) {
                // Update existing product
                await _localRepo.updateProduct(product);
              } else {
                // Insert new product
                await _localRepo.insertProduct(product);
              }
            } else {
              await _localRepo.insertProduct(product);
            }
          } catch (e) {
            print('Error saving product ${product.name}: $e');
          }
        }
      },
      lastSyncTime: _syncService.lastSyncTime,
    );
  }

  /// Bidirectional sync: Upload local changes & download cloud changes
  Future<SyncResult> syncBidirectional() async {
    return await _syncService.syncBidirectional<ProductModel>(
      collectionName: _collectionName,
      getLocalData: () => _localRepo.getAllProducts(),
      toFirestoreMap: _toFirestoreMap,
      getDocumentId: _getDocumentId,
      fromFirestoreMap: _fromFirestoreMap,
      saveToLocal: (products) async {
        for (var product in products) {
          try {
            if (product.id != null) {
              final existing = await _localRepo.getProductById(product.id!);
              if (existing != null) {
                await _localRepo.updateProduct(product);
              } else {
                await _localRepo.insertProduct(product);
              }
            } else {
              await _localRepo.insertProduct(product);
            }
          } catch (e) {
            print('Error saving product ${product.name}: $e');
          }
        }
      },
    );
  }

  /// Real-time stream: Listen to changes from Firestore
  ///
  /// Use this for real-time updates. Data that changes in the cloud
  /// will be automatically updated locally.
  Stream<List<ProductModel>> watchProductsFromCloud() {
    return _syncService
        .listenToCollection<ProductModel>(
      collectionName: _collectionName,
      fromFirestoreMap: _fromFirestoreMap,
    )
        .asyncMap((cloudProducts) async {
      // Auto-save cloud changes to local
      for (var product in cloudProducts) {
        try {
          if (product.id != null) {
            final existing = await _localRepo.getProductById(product.id!);
            if (existing != null) {
              await _localRepo.updateProduct(product);
            } else {
              await _localRepo.insertProduct(product);
            }
          } else {
            await _localRepo.insertProduct(product);
          }
        } catch (e) {
          print('Error auto-saving product: $e');
        }
      }

      // Return updated local data
      return await _localRepo.getAllProducts();
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
