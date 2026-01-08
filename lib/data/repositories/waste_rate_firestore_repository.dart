import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/waste_rate_model.dart';

/// WasteRate repository using Firebase Firestore for cloud-based data storage
class WasteRateFirestoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'waste_rates';

  // Get collection reference
  CollectionReference get _wasteRatesCollection =>
      _firestore.collection(collectionName);

  // Convert Firestore document to WasteRateModel
  WasteRateModel _documentToWasteRate(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WasteRateModel.fromMap({
      ...data,
      'id': int.tryParse(doc.id) ?? 0,
    });
  }

  // Create - Insert new waste rate
  Future<String> insertWasteRate(WasteRateModel wasteRate) async {
    try {
      final docRef = await _wasteRatesCollection.add({
        'name': wasteRate.name,
        'rupiah_per_kg': wasteRate.rupiahPerKg,
        'is_active': wasteRate.isActive,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to insert waste rate: $e');
    }
  }

  // Read - Get all waste rates with real-time updates
  Stream<List<WasteRateModel>> getAllWasteRatesStream() {
    return _wasteRatesCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _documentToWasteRate(doc))
            .toList());
  }

  // Read - Get all waste rates (one-time fetch)
  Future<List<WasteRateModel>> getAllWasteRates() async {
    try {
      final querySnapshot = await _wasteRatesCollection
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToWasteRate(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get waste rates: $e');
    }
  }

  // Read - Get waste rate by document ID
  Future<WasteRateModel?> getWasteRateByDocId(String docId) async {
    try {
      final docSnapshot = await _wasteRatesCollection.doc(docId).get();

      if (!docSnapshot.exists) return null;
      return _documentToWasteRate(docSnapshot);
    } catch (e) {
      throw Exception('Failed to get waste rate by ID: $e');
    }
  }

  // Read - Get active waste rates
  Future<List<WasteRateModel>> getActiveWasteRates() async {
    try {
      final querySnapshot = await _wasteRatesCollection
          .where('is_active', isEqualTo: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToWasteRate(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get active waste rates: $e');
    }
  }

  // Read - Get active waste rates with stream
  Stream<List<WasteRateModel>> getActiveWasteRatesStream() {
    return _wasteRatesCollection
        .where('is_active', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _documentToWasteRate(doc))
            .toList());
  }

  // Read - Get waste rate by name
  Future<WasteRateModel?> getWasteRateByName(String name) async {
    try {
      final querySnapshot = await _wasteRatesCollection
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;
      return _documentToWasteRate(querySnapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to get waste rate by name: $e');
    }
  }

  // Update - Update waste rate
  Future<void> updateWasteRate(String docId, WasteRateModel wasteRate) async {
    try {
      await _wasteRatesCollection.doc(docId).update({
        'name': wasteRate.name,
        'rupiah_per_kg': wasteRate.rupiahPerKg,
        'is_active': wasteRate.isActive,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update waste rate: $e');
    }
  }

  // Update - Update rupiah per kg
  Future<void> updateRupiahPerKg(String docId, double rupiahPerKg) async {
    try {
      await _wasteRatesCollection.doc(docId).update({
        'rupiah_per_kg': rupiahPerKg,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update rupiah per kg: $e');
    }
  }

  // Update - Update waste rate status
  Future<void> updateWasteRateStatus(String docId, bool isActive) async {
    try {
      await _wasteRatesCollection.doc(docId).update({
        'is_active': isActive,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update waste rate status: $e');
    }
  }

  // Delete - Delete waste rate by document ID
  Future<void> deleteWasteRate(String docId) async {
    try {
      await _wasteRatesCollection.doc(docId).delete();
    } catch (e) {
      throw Exception('Failed to delete waste rate: $e');
    }
  }

  // Search waste rates by name
  Future<List<WasteRateModel>> searchWasteRatesByName(String name) async {
    try {
      final querySnapshot = await _wasteRatesCollection
          .where('name', isGreaterThanOrEqualTo: name)
          .where('name', isLessThanOrEqualTo: '$name\uf8ff')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToWasteRate(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to search waste rates: $e');
    }
  }

  // Get total waste rate count
  Future<int> getWasteRateCount() async {
    try {
      final querySnapshot = await _wasteRatesCollection.count().get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get waste rate count: $e');
    }
  }

  // Get active waste rate count
  Future<int> getActiveWasteRateCount() async {
    try {
      final querySnapshot = await _wasteRatesCollection
          .where('is_active', isEqualTo: true)
          .count()
          .get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get active waste rate count: $e');
    }
  }

  // Batch operations - Create multiple waste rates
  Future<void> batchCreateWasteRates(List<WasteRateModel> wasteRates) async {
    try {
      final batch = _firestore.batch();

      for (var wasteRate in wasteRates) {
        final docRef = _wasteRatesCollection.doc();
        batch.set(docRef, {
          'name': wasteRate.name,
          'rupiah_per_kg': wasteRate.rupiahPerKg,
          'is_active': wasteRate.isActive,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch create waste rates: $e');
    }
  }
}
