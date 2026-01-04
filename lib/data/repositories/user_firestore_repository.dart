import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Example repository using Firebase Firestore instead of SQLite
/// This demonstrates how to use Firestore for cloud-based data storage
class UserFirestoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'users';

  // Get collection reference
  CollectionReference get _usersCollection =>
      _firestore.collection(collectionName);

  // Convert Firestore document to UserModel
  UserModel _documentToUser(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap({
      ...data,
      'id': int.tryParse(doc.id) ?? 0, // Use document ID as user ID
    });
  }

  // Authentication - Register new user
  Future<String> register(UserModel user) async {
    try {
      // Check if username already exists
      final existingUser = await getUserByUsername(user.username);
      if (existingUser != null) {
        throw Exception('Username already exists');
      }

      // Create user document
      final docRef = await _usersCollection.add({
        'name': user.name,
        'username': user.username,
        'password': user.password, // Note: In production, use Firebase Auth instead
        'role': user.role,
        'email': user.email,
        'phone': user.phone,
        'eco_points': user.ecoPoints,
        'status': user.status,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  // Authentication - Login user
  Future<UserModel?> login(String username, String password) async {
    try {
      final querySnapshot = await _usersCollection
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final user = _documentToUser(querySnapshot.docs.first);

      // Check if user is active
      if (!user.isActive) {
        throw Exception('Account is inactive');
      }

      return user;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  // Create - Insert new user
  Future<String> insertUser(UserModel user) async {
    try {
      final docRef = await _usersCollection.add({
        'name': user.name,
        'username': user.username,
        'password': user.password,
        'role': user.role,
        'email': user.email,
        'phone': user.phone,
        'eco_points': user.ecoPoints,
        'status': user.status,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to insert user: $e');
    }
  }

  // Read - Get all users (with real-time updates using Stream)
  Stream<List<UserModel>> getAllUsersStream() {
    return _usersCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _documentToUser(doc))
            .toList());
  }

  // Read - Get all users (one-time fetch)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _usersCollection
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToUser(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  // Read - Get user by document ID
  Future<UserModel?> getUserByDocId(String docId) async {
    try {
      final docSnapshot = await _usersCollection.doc(docId).get();

      if (!docSnapshot.exists) return null;
      return _documentToUser(docSnapshot);
    } catch (e) {
      throw Exception('Failed to get user by ID: $e');
    }
  }

  // Read - Get user by username
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final querySnapshot = await _usersCollection
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;
      return _documentToUser(querySnapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to get user by username: $e');
    }
  }

  // Read - Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await _usersCollection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;
      return _documentToUser(querySnapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to get user by email: $e');
    }
  }

  // Read - Get users by role (with real-time updates)
  Stream<List<UserModel>> getUsersByRoleStream(String role) {
    return _usersCollection
        .where('role', isEqualTo: role)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _documentToUser(doc))
            .toList());
  }

  // Read - Get users by role (one-time fetch)
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final querySnapshot = await _usersCollection
          .where('role', isEqualTo: role)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToUser(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users by role: $e');
    }
  }

  // Read - Get active users
  Future<List<UserModel>> getActiveUsers() async {
    try {
      final querySnapshot = await _usersCollection
          .where('status', isEqualTo: 'active')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToUser(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get active users: $e');
    }
  }

  // Update - Update user
  Future<void> updateUser(String docId, UserModel user) async {
    try {
      await _usersCollection.doc(docId).update({
        'name': user.name,
        'username': user.username,
        'role': user.role,
        'email': user.email,
        'phone': user.phone,
        'eco_points': user.ecoPoints,
        'status': user.status,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Update - Update eco points
  Future<void> updateEcoPoints(String docId, double ecoPoints) async {
    try {
      await _usersCollection.doc(docId).update({
        'eco_points': ecoPoints,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update eco points: $e');
    }
  }

  // Update - Add eco points using transaction (atomic operation)
  Future<void> addEcoPoints(String docId, double points) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(_usersCollection.doc(docId));

        if (!docSnapshot.exists) {
          throw Exception('User not found');
        }

        final currentPoints = (docSnapshot.data() as Map<String, dynamic>)['eco_points'] ?? 0.0;
        final newPoints = currentPoints + points;

        transaction.update(_usersCollection.doc(docId), {
          'eco_points': newPoints,
          'updated_at': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to add eco points: $e');
    }
  }

  // Update - Deduct eco points using transaction
  Future<void> deductEcoPoints(String docId, double points) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(_usersCollection.doc(docId));

        if (!docSnapshot.exists) {
          throw Exception('User not found');
        }

        final currentPoints = (docSnapshot.data() as Map<String, dynamic>)['eco_points'] ?? 0.0;

        if (currentPoints < points) {
          throw Exception('Insufficient eco points');
        }

        final newPoints = currentPoints - points;

        transaction.update(_usersCollection.doc(docId), {
          'eco_points': newPoints,
          'updated_at': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to deduct eco points: $e');
    }
  }

  // Update - Update user status
  Future<void> updateUserStatus(String docId, String status) async {
    try {
      await _usersCollection.doc(docId).update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }

  // Delete - Delete user by document ID
  Future<void> deleteUser(String docId) async {
    try {
      await _usersCollection.doc(docId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Delete - Delete all users (use with caution!)
  Future<void> deleteAllUsers() async {
    try {
      final batch = _firestore.batch();
      final querySnapshot = await _usersCollection.get();

      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all users: $e');
    }
  }

  // Search users by name (using array-contains for better search)
  Future<List<UserModel>> searchUsersByName(String name) async {
    try {
      // Note: Firestore doesn't support LIKE queries natively
      // For better search, consider using Algolia or FlutterFire UI
      final querySnapshot = await _usersCollection
          .where('name', isGreaterThanOrEqualTo: name)
          .where('name', isLessThanOrEqualTo: '$name\uf8ff')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToUser(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // Get total user count
  Future<int> getUserCount() async {
    try {
      final querySnapshot = await _usersCollection.count().get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get user count: $e');
    }
  }

  // Get user count by role
  Future<int> getUserCountByRole(String role) async {
    try {
      final querySnapshot = await _usersCollection
          .where('role', isEqualTo: role)
          .count()
          .get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get user count by role: $e');
    }
  }

  // Batch operations example
  Future<void> batchCreateUsers(List<UserModel> users) async {
    try {
      final batch = _firestore.batch();

      for (var user in users) {
        final docRef = _usersCollection.doc();
        batch.set(docRef, {
          'name': user.name,
          'username': user.username,
          'password': user.password,
          'role': user.role,
          'email': user.email,
          'phone': user.phone,
          'eco_points': user.ecoPoints,
          'status': user.status,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch create users: $e');
    }
  }
}
