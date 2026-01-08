import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

/// Transaction repository using Firebase Firestore for cloud-based data storage
class TransactionFirestoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'transactions';

  // Get collection reference
  CollectionReference get _transactionsCollection =>
      _firestore.collection(collectionName);

  // Convert Firestore document to TransactionModel
  TransactionModel _documentToTransaction(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel.fromMap({
      ...data,
      'id': int.tryParse(doc.id) ?? 0,
    });
  }

  // Create - Insert new transaction
  Future<String> insertTransaction(TransactionModel transaction) async {
    try {
      final docRef = await _transactionsCollection.add({
        'user_id': transaction.userId,
        'product_id': transaction.productId,
        'quantity': transaction.quantity,
        'total_price': transaction.totalPrice,
        'transaction_date': Timestamp.fromDate(transaction.transactionDate),
        'status': transaction.status,
        'type': transaction.type,
        'waste_type': transaction.wasteType,
        'product_name': transaction.productName,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to insert transaction: $e');
    }
  }

  // Read - Get all transactions with real-time updates
  Stream<List<TransactionModel>> getAllTransactionsStream() {
    return _transactionsCollection
        .orderBy('transaction_date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _documentToTransaction(doc))
            .toList());
  }

  // Read - Get all transactions (one-time fetch)
  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      final querySnapshot = await _transactionsCollection
          .orderBy('transaction_date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToTransaction(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get transactions: $e');
    }
  }

  // Read - Get transaction by document ID
  Future<TransactionModel?> getTransactionByDocId(String docId) async {
    try {
      final docSnapshot = await _transactionsCollection.doc(docId).get();

      if (!docSnapshot.exists) return null;
      return _documentToTransaction(docSnapshot);
    } catch (e) {
      throw Exception('Failed to get transaction by ID: $e');
    }
  }

  // Read - Get transactions by user ID
  Future<List<TransactionModel>> getTransactionsByUserId(int userId) async {
    try {
      final querySnapshot = await _transactionsCollection
          .where('user_id', isEqualTo: userId)
          .orderBy('transaction_date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToTransaction(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get transactions by user ID: $e');
    }
  }

  // Read - Get transactions by user ID with stream
  Stream<List<TransactionModel>> getTransactionsByUserIdStream(int userId) {
    return _transactionsCollection
        .where('user_id', isEqualTo: userId)
        .orderBy('transaction_date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _documentToTransaction(doc))
            .toList());
  }

  // Read - Get transactions by type
  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    try {
      final querySnapshot = await _transactionsCollection
          .where('type', isEqualTo: type)
          .orderBy('transaction_date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToTransaction(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get transactions by type: $e');
    }
  }

  // Read - Get deposit transactions
  Future<List<TransactionModel>> getDepositTransactions() async {
    return getTransactionsByType('deposit');
  }

  // Read - Get purchase transactions
  Future<List<TransactionModel>> getPurchaseTransactions() async {
    return getTransactionsByType('purchase');
  }

  // Read - Get transactions by user ID and type
  Future<List<TransactionModel>> getTransactionsByUserIdAndType(
      int userId, String type) async {
    try {
      final querySnapshot = await _transactionsCollection
          .where('user_id', isEqualTo: userId)
          .where('type', isEqualTo: type)
          .orderBy('transaction_date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToTransaction(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get transactions by user ID and type: $e');
    }
  }

  // Read - Get user deposit transactions
  Future<List<TransactionModel>> getUserDepositTransactions(int userId) async {
    return getTransactionsByUserIdAndType(userId, 'deposit');
  }

  // Read - Get user purchase transactions
  Future<List<TransactionModel>> getUserPurchaseTransactions(int userId) async {
    return getTransactionsByUserIdAndType(userId, 'purchase');
  }

  // Read - Get transactions by date range
  Future<List<TransactionModel>> getTransactionsByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final querySnapshot = await _transactionsCollection
          .where('transaction_date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('transaction_date',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('transaction_date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToTransaction(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get transactions by date range: $e');
    }
  }

  // Read - Get transactions by status
  Future<List<TransactionModel>> getTransactionsByStatus(String status) async {
    try {
      final querySnapshot = await _transactionsCollection
          .where('status', isEqualTo: status)
          .orderBy('transaction_date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToTransaction(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get transactions by status: $e');
    }
  }

  // Update - Update transaction
  Future<void> updateTransaction(
      String docId, TransactionModel transaction) async {
    try {
      await _transactionsCollection.doc(docId).update({
        'user_id': transaction.userId,
        'product_id': transaction.productId,
        'quantity': transaction.quantity,
        'total_price': transaction.totalPrice,
        'transaction_date': Timestamp.fromDate(transaction.transactionDate),
        'status': transaction.status,
        'type': transaction.type,
        'waste_type': transaction.wasteType,
        'product_name': transaction.productName,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  // Update - Update transaction status
  Future<void> updateTransactionStatus(String docId, String status) async {
    try {
      await _transactionsCollection.doc(docId).update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update transaction status: $e');
    }
  }

  // Delete - Delete transaction by document ID
  Future<void> deleteTransaction(String docId) async {
    try {
      await _transactionsCollection.doc(docId).delete();
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  // Get total transaction count
  Future<int> getTransactionCount() async {
    try {
      final querySnapshot = await _transactionsCollection.count().get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get transaction count: $e');
    }
  }

  // Get total transaction count by user
  Future<int> getTransactionCountByUserId(int userId) async {
    try {
      final querySnapshot = await _transactionsCollection
          .where('user_id', isEqualTo: userId)
          .count()
          .get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get transaction count by user: $e');
    }
  }

  // Calculate total points for user by type
  Future<double> getTotalPointsByUserIdAndType(
      int userId, String type) async {
    try {
      final transactions = await getTransactionsByUserIdAndType(userId, type);
      return transactions.fold<double>(
          0.0, (total, transaction) => total + transaction.totalPrice);
    } catch (e) {
      throw Exception('Failed to get total points: $e');
    }
  }

  // Get total deposit points for user
  Future<double> getTotalDepositPoints(int userId) async {
    return getTotalPointsByUserIdAndType(userId, 'deposit');
  }

  // Get total purchase points for user
  Future<double> getTotalPurchasePoints(int userId) async {
    return getTotalPointsByUserIdAndType(userId, 'purchase');
  }

  // Batch operations - Create multiple transactions
  Future<void> batchCreateTransactions(
      List<TransactionModel> transactions) async {
    try {
      final batch = _firestore.batch();

      for (var transaction in transactions) {
        final docRef = _transactionsCollection.doc();
        batch.set(docRef, {
          'user_id': transaction.userId,
          'product_id': transaction.productId,
          'quantity': transaction.quantity,
          'total_price': transaction.totalPrice,
          'transaction_date': Timestamp.fromDate(transaction.transactionDate),
          'status': transaction.status,
          'type': transaction.type,
          'waste_type': transaction.wasteType,
          'product_name': transaction.productName,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch create transactions: $e');
    }
  }
}
