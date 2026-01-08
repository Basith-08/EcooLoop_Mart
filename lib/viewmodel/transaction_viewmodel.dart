import 'package:flutter/foundation.dart';
import '../data/models/transaction_model.dart';
import '../data/repositories/transaction_hybrid_repository.dart';
import '../state/transaction_state.dart';

class TransactionViewModel extends ChangeNotifier {
  final TransactionHybridRepository _repository;
  TransactionState _state = const TransactionInitial();

  TransactionViewModel(this._repository);

  TransactionState get state => _state;

  void _setState(TransactionState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Load all transactions from database
  Future<void> loadTransactions() async {
    try {
      _setState(const TransactionLoading());

      final transactions = await _repository.getAllTransactions();

      if (transactions.isEmpty) {
        _setState(const TransactionEmpty());
      } else {
        _setState(TransactionLoaded(transactions));
      }
    } catch (e) {
      _setState(TransactionError(
        'Failed to load transactions',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Load transactions for a specific user
  Future<void> loadUserTransactions(int userId) async {
    try {
      _setState(const TransactionLoading());

      final transactions = await _repository.getTransactionsByUserId(userId);

      if (transactions.isEmpty) {
        _setState(const TransactionEmpty(message: 'No transactions found for this user'));
      } else {
        _setState(TransactionLoaded(transactions));
      }
    } catch (e) {
      _setState(TransactionError(
        'Failed to load user transactions',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Create new transaction
  Future<void> createTransaction({
    required int userId,
    int? productId,
    required double quantity,
    required double totalPrice,
    required String type,
    String status = 'completed',
    String? wasteType,
    String? productName,
  }) async {
    try {
      _setState(const TransactionLoading());

      // Validate inputs
      if (quantity <= 0) {
        _setState(const TransactionError('Quantity must be greater than zero'));
        return;
      }

      if (totalPrice <= 0) {
        _setState(const TransactionError('Total price must be greater than zero'));
        return;
      }

      if (type != 'deposit' && type != 'purchase') {
        _setState(const TransactionError('Invalid transaction type'));
        return;
      }

      // For purchase transactions, productId is required
      if (type == 'purchase' && productId == null) {
        _setState(const TransactionError('Product ID is required for purchase transactions'));
        return;
      }

      // For deposit transactions, wasteType is recommended
      if (type == 'deposit' && wasteType == null) {
        _setState(const TransactionError('Waste type is recommended for deposit transactions'));
        return;
      }

      final transaction = TransactionModel(
        userId: userId,
        productId: productId,
        quantity: quantity,
        totalPrice: totalPrice,
        type: type,
        status: status,
        wasteType: wasteType,
        productName: productName,
      );

      final id = await _repository.insertTransaction(transaction);
      final createdTransaction = transaction.copyWith(id: id);

      _setState(TransactionCreated(createdTransaction));

      // Reload transactions to update the list
      await loadTransactions();
    } catch (e) {
      _setState(TransactionError(
        'Failed to create transaction',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Load transactions by type (deposit or purchase)
  Future<void> loadTransactionsByType(String type) async {
    try {
      _setState(const TransactionLoading());

      if (type != 'deposit' && type != 'purchase') {
        _setState(const TransactionError('Invalid transaction type'));
        return;
      }

      final transactions = await _repository.getTransactionsByType(type);

      if (transactions.isEmpty) {
        _setState(TransactionEmpty(message: 'No $type transactions found'));
      } else {
        _setState(TransactionLoaded(transactions));
      }
    } catch (e) {
      _setState(TransactionError(
        'Failed to load transactions by type',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Load recent transactions with limit
  Future<void> loadRecentTransactions({int limit = 10}) async {
    try {
      _setState(const TransactionLoading());

      final transactions = await _repository.getRecentTransactions(limit: limit);

      if (transactions.isEmpty) {
        _setState(const TransactionEmpty(message: 'No recent transactions'));
      } else {
        _setState(TransactionLoaded(transactions));
      }
    } catch (e) {
      _setState(TransactionError(
        'Failed to load recent transactions',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Load transactions by status
  Future<void> loadTransactionsByStatus(String status) async {
    try {
      _setState(const TransactionLoading());

      final transactions = await _repository.getTransactionsByStatus(status);

      if (transactions.isEmpty) {
        _setState(TransactionEmpty(message: 'No $status transactions found'));
      } else {
        _setState(TransactionLoaded(transactions));
      }
    } catch (e) {
      _setState(TransactionError(
        'Failed to load transactions by status',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Update transaction status
  Future<void> updateTransactionStatus(int transactionId, String status) async {
    try {
      _setState(const TransactionLoading());

      final rowsAffected = await _repository.updateTransactionStatus(transactionId, status);

      if (rowsAffected == 0) {
        _setState(const TransactionError('Transaction not found'));
      } else {
        // Reload transactions to update the list
        await loadTransactions();
      }
    } catch (e) {
      _setState(TransactionError(
        'Failed to update transaction status',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Delete transaction by ID
  Future<void> deleteTransaction(int id) async {
    try {
      _setState(const TransactionLoading());

      final rowsAffected = await _repository.deleteTransaction(id);

      if (rowsAffected == 0) {
        _setState(const TransactionError('Transaction not found'));
      } else {
        // Reload transactions to update the list
        await loadTransactions();
      }
    } catch (e) {
      _setState(TransactionError(
        'Failed to delete transaction',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Get total points earned by user (from deposits)
  Future<double> getTotalPointsEarned(int userId) async {
    try {
      return await _repository.getTotalPointsEarned(userId);
    } catch (e) {
      return 0.0;
    }
  }

  /// Get total points spent by user (from purchases)
  Future<double> getTotalPointsSpent(int userId) async {
    try {
      return await _repository.getTotalPointsSpent(userId);
    } catch (e) {
      return 0.0;
    }
  }

  /// Reset state to initial
  void resetState() {
    _setState(const TransactionInitial());
  }
}
