import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/partner_model.dart';

/// Partner repository using Firebase Firestore for cloud-based data storage
class PartnerFirestoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'partners';

  // Get collection reference
  CollectionReference get _partnersCollection =>
      _firestore.collection(collectionName);

  // Convert Firestore document to PartnerModel
  PartnerModel _documentToPartner(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PartnerModel.fromMap({
      ...data,
      'id': int.tryParse(doc.id) ?? 0,
    });
  }

  // Create - Insert new partner
  Future<String> insertPartner(PartnerModel partner) async {
    try {
      final docRef = await _partnersCollection.add({
        'type': partner.type,
        'name': partner.name,
        'location': partner.location,
        'tag': partner.tag,
        'subtitle': partner.subtitle,
        'area': partner.area,
        'detail': partner.detail,
        'is_active': partner.isActive,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to insert partner: $e');
    }
  }

  // Read - Get all partners with real-time updates
  Stream<List<PartnerModel>> getAllPartnersStream() {
    return _partnersCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _documentToPartner(doc))
            .toList());
  }

  // Read - Get all partners (one-time fetch)
  Future<List<PartnerModel>> getAllPartners() async {
    try {
      final querySnapshot = await _partnersCollection
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToPartner(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get partners: $e');
    }
  }

  // Read - Get partner by document ID
  Future<PartnerModel?> getPartnerByDocId(String docId) async {
    try {
      final docSnapshot = await _partnersCollection.doc(docId).get();

      if (!docSnapshot.exists) return null;
      return _documentToPartner(docSnapshot);
    } catch (e) {
      throw Exception('Failed to get partner by ID: $e');
    }
  }

  // Read - Get partners by type
  Future<List<PartnerModel>> getPartnersByType(String type) async {
    try {
      final querySnapshot = await _partnersCollection
          .where('type', isEqualTo: type)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToPartner(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get partners by type: $e');
    }
  }

  // Read - Get partners by type with stream
  Stream<List<PartnerModel>> getPartnersByTypeStream(String type) {
    return _partnersCollection
        .where('type', isEqualTo: type)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _documentToPartner(doc))
            .toList());
  }

  // Read - Get active partners
  Future<List<PartnerModel>> getActivePartners() async {
    try {
      final querySnapshot = await _partnersCollection
          .where('is_active', isEqualTo: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToPartner(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get active partners: $e');
    }
  }

  // Read - Get pengrajin partners
  Future<List<PartnerModel>> getPengrajinPartners() async {
    return getPartnersByType('pengrajin');
  }

  // Read - Get grosir partners
  Future<List<PartnerModel>> getGrosirPartners() async {
    return getPartnersByType('grosir');
  }

  // Read - Get active partners by type
  Future<List<PartnerModel>> getActivePartnersByType(String type) async {
    try {
      final querySnapshot = await _partnersCollection
          .where('type', isEqualTo: type)
          .where('is_active', isEqualTo: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToPartner(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get active partners by type: $e');
    }
  }

  // Update - Update partner
  Future<void> updatePartner(String docId, PartnerModel partner) async {
    try {
      await _partnersCollection.doc(docId).update({
        'type': partner.type,
        'name': partner.name,
        'location': partner.location,
        'tag': partner.tag,
        'subtitle': partner.subtitle,
        'area': partner.area,
        'detail': partner.detail,
        'is_active': partner.isActive,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update partner: $e');
    }
  }

  // Update - Update partner status
  Future<void> updatePartnerStatus(String docId, bool isActive) async {
    try {
      await _partnersCollection.doc(docId).update({
        'is_active': isActive,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update partner status: $e');
    }
  }

  // Delete - Delete partner by document ID
  Future<void> deletePartner(String docId) async {
    try {
      await _partnersCollection.doc(docId).delete();
    } catch (e) {
      throw Exception('Failed to delete partner: $e');
    }
  }

  // Search partners by name
  Future<List<PartnerModel>> searchPartnersByName(String name) async {
    try {
      final querySnapshot = await _partnersCollection
          .where('name', isGreaterThanOrEqualTo: name)
          .where('name', isLessThanOrEqualTo: '$name\uf8ff')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToPartner(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to search partners: $e');
    }
  }

  // Get total partner count
  Future<int> getPartnerCount() async {
    try {
      final querySnapshot = await _partnersCollection.count().get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get partner count: $e');
    }
  }

  // Get partner count by type
  Future<int> getPartnerCountByType(String type) async {
    try {
      final querySnapshot = await _partnersCollection
          .where('type', isEqualTo: type)
          .count()
          .get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get partner count by type: $e');
    }
  }

  // Batch operations - Create multiple partners
  Future<void> batchCreatePartners(List<PartnerModel> partners) async {
    try {
      final batch = _firestore.batch();

      for (var partner in partners) {
        final docRef = _partnersCollection.doc();
        batch.set(docRef, {
          'type': partner.type,
          'name': partner.name,
          'location': partner.location,
          'tag': partner.tag,
          'subtitle': partner.subtitle,
          'area': partner.area,
          'detail': partner.detail,
          'is_active': partner.isActive,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch create partners: $e');
    }
  }
}
