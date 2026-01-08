import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wallet_model.dart';

/// Wallet repository using Firebase Firestore for cloud-based data storage
/// Each user has one wallet, using userId as document ID
class WalletFirestoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'wallets';

  // Get collection reference
  CollectionReference get _walletsCollection =>
      _firestore.collection(collectionName);

  // Convert Firestore document to WalletModel
  WalletModel _documentToWallet(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WalletModel.fromMap({
      ...data,
      'id': int.tryParse(doc.id) ?? 0,
    });
  }

  // Create - Insert or create wallet for user
  Future<String> createWallet(WalletModel wallet) async {
    try {
      // Use userId as document ID for easy lookup
      final docId = wallet.userId.toString();

      await _walletsCollection.doc(docId).set({
        'user_id': wallet.userId,
        'eco_points': wallet.ecoPoints,
        'rupiah_value': wallet.rupiahValue,
        'updated_at': FieldValue.serverTimestamp(),
        'created_at': FieldValue.serverTimestamp(),
      });

      return docId;
    } catch (e) {
      throw Exception('Failed to create wallet: $e');
    }
  }

  // Read - Get wallet by user ID
  Future<WalletModel?> getWalletByUserId(int userId) async {
    try {
      final docId = userId.toString();
      final docSnapshot = await _walletsCollection.doc(docId).get();

      if (!docSnapshot.exists) return null;
      return _documentToWallet(docSnapshot);
    } catch (e) {
      throw Exception('Failed to get wallet by user ID: $e');
    }
  }

  // Read - Get wallet by user ID with stream (real-time)
  Stream<WalletModel?> getWalletByUserIdStream(int userId) {
    final docId = userId.toString();
    return _walletsCollection.doc(docId).snapshots().map((docSnapshot) {
      if (!docSnapshot.exists) return null;
      return _documentToWallet(docSnapshot);
    });
  }

  // Read - Get all wallets
  Future<List<WalletModel>> getAllWallets() async {
    try {
      final querySnapshot = await _walletsCollection
          .orderBy('eco_points', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToWallet(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all wallets: $e');
    }
  }

  // Read - Get all wallets with stream
  Stream<List<WalletModel>> getAllWalletsStream() {
    return _walletsCollection
        .orderBy('eco_points', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _documentToWallet(doc))
            .toList());
  }

  // Update - Update wallet
  Future<void> updateWallet(int userId, WalletModel wallet) async {
    try {
      final docId = userId.toString();

      await _walletsCollection.doc(docId).update({
        'eco_points': wallet.ecoPoints,
        'rupiah_value': wallet.rupiahValue,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update wallet: $e');
    }
  }

  // Update - Update eco points using transaction (atomic operation)
  Future<void> updateEcoPoints(int userId, double ecoPoints) async {
    try {
      final docId = userId.toString();

      await _walletsCollection.doc(docId).update({
        'eco_points': ecoPoints,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update eco points: $e');
    }
  }

  // Update - Add eco points using transaction (atomic operation)
  Future<void> addEcoPoints(int userId, double points) async {
    try {
      final docId = userId.toString();

      await _firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(_walletsCollection.doc(docId));

        if (!docSnapshot.exists) {
          throw Exception('Wallet not found');
        }

        final currentPoints = (docSnapshot.data() as Map<String, dynamic>)['eco_points'] ?? 0.0;
        final newPoints = currentPoints + points;

        transaction.update(_walletsCollection.doc(docId), {
          'eco_points': newPoints,
          'updated_at': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to add eco points: $e');
    }
  }

  // Update - Deduct eco points using transaction (atomic operation)
  Future<void> deductEcoPoints(int userId, double points) async {
    try {
      final docId = userId.toString();

      await _firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(_walletsCollection.doc(docId));

        if (!docSnapshot.exists) {
          throw Exception('Wallet not found');
        }

        final currentPoints = (docSnapshot.data() as Map<String, dynamic>)['eco_points'] ?? 0.0;

        if (currentPoints < points) {
          throw Exception('Insufficient eco points');
        }

        final newPoints = currentPoints - points;

        transaction.update(_walletsCollection.doc(docId), {
          'eco_points': newPoints,
          'updated_at': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to deduct eco points: $e');
    }
  }

  // Delete - Delete wallet by user ID
  Future<void> deleteWallet(int userId) async {
    try {
      final docId = userId.toString();
      await _walletsCollection.doc(docId).delete();
    } catch (e) {
      throw Exception('Failed to delete wallet: $e');
    }
  }

  // Get total eco points across all wallets
  Future<double> getTotalEcoPoints() async {
    try {
      final querySnapshot = await _walletsCollection.get();
      double total = 0.0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['eco_points'] ?? 0.0) as double;
      }

      return total;
    } catch (e) {
      throw Exception('Failed to get total eco points: $e');
    }
  }

  // Get wallet count
  Future<int> getWalletCount() async {
    try {
      final querySnapshot = await _walletsCollection.count().get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get wallet count: $e');
    }
  }

  // Get wallets with points greater than threshold
  Future<List<WalletModel>> getWalletsWithPointsGreaterThan(double threshold) async {
    try {
      final querySnapshot = await _walletsCollection
          .where('eco_points', isGreaterThan: threshold)
          .orderBy('eco_points', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToWallet(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get wallets with points greater than threshold: $e');
    }
  }

  // Batch operations - Create multiple wallets
  Future<void> batchCreateWallets(List<WalletModel> wallets) async {
    try {
      final batch = _firestore.batch();

      for (var wallet in wallets) {
        final docId = wallet.userId.toString();
        final docRef = _walletsCollection.doc(docId);

        batch.set(docRef, {
          'user_id': wallet.userId,
          'eco_points': wallet.ecoPoints,
          'rupiah_value': wallet.rupiahValue,
          'updated_at': FieldValue.serverTimestamp(),
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch create wallets: $e');
    }
  }
}
