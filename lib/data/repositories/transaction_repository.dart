import 'package:sqflite/sqflite.dart';
import '../../core/database/db_helper.dart';
import '../../core/database/db_config.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final DBHelper _dbHelper = DBHelper();

  // Create - Insert new transaction
  Future<int> insertTransaction(TransactionModel transaction) async {
    try {
      final db = await _dbHelper.database;
      return await db.insert(
        DBConfig.transactionTable,
        transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to insert transaction: $e');
    }
  }

  // Read - Get all transactions
  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.transactionTable,
        orderBy: 'transaction_date DESC',
      );

      return List.generate(maps.length, (i) {
        return TransactionModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get transactions: $e');
    }
  }

  // Read - Get transactions by user ID
  Future<List<TransactionModel>> getTransactionsByUserId(int userId) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.transactionTable,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'transaction_date DESC',
      );

      return List.generate(maps.length, (i) {
        return TransactionModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get transactions by user ID: $e');
    }
  }

  // Read - Get transactions by type (deposit/purchase)
  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.transactionTable,
        where: 'type = ?',
        whereArgs: [type],
        orderBy: 'transaction_date DESC',
      );

      return List.generate(maps.length, (i) {
        return TransactionModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get transactions by type: $e');
    }
  }

  // Read - Get recent transactions (limited)
  Future<List<TransactionModel>> getRecentTransactions({int limit = 10}) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.transactionTable,
        orderBy: 'transaction_date DESC',
        limit: limit,
      );

      return List.generate(maps.length, (i) {
        return TransactionModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get recent transactions: $e');
    }
  }

  // Read - Get transaction by ID
  Future<TransactionModel?> getTransactionById(int id) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.transactionTable,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return TransactionModel.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to get transaction by ID: $e');
    }
  }

  // Read - Get transactions by user ID and type
  Future<List<TransactionModel>> getTransactionsByUserIdAndType(
      int userId, String type) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.transactionTable,
        where: 'user_id = ? AND type = ?',
        whereArgs: [userId, type],
        orderBy: 'transaction_date DESC',
      );

      return List.generate(maps.length, (i) {
        return TransactionModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get transactions by user ID and type: $e');
    }
  }

  // Read - Get transactions by status
  Future<List<TransactionModel>> getTransactionsByStatus(String status) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.transactionTable,
        where: 'status = ?',
        whereArgs: [status],
        orderBy: 'transaction_date DESC',
      );

      return List.generate(maps.length, (i) {
        return TransactionModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get transactions by status: $e');
    }
  }

  // Read - Get transactions by date range
  Future<List<TransactionModel>> getTransactionsByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.transactionTable,
        where: 'transaction_date BETWEEN ? AND ?',
        whereArgs: [
          startDate.toIso8601String(),
          endDate.toIso8601String(),
        ],
        orderBy: 'transaction_date DESC',
      );

      return List.generate(maps.length, (i) {
        return TransactionModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get transactions by date range: $e');
    }
  }

  // Update - Update transaction
  Future<int> updateTransaction(TransactionModel transaction) async {
    try {
      final db = await _dbHelper.database;
      return await db.update(
        DBConfig.transactionTable,
        transaction.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  // Update - Update transaction status
  Future<int> updateTransactionStatus(int transactionId, String status) async {
    try {
      final db = await _dbHelper.database;
      return await db.update(
        DBConfig.transactionTable,
        {'status': status},
        where: 'id = ?',
        whereArgs: [transactionId],
      );
    } catch (e) {
      throw Exception('Failed to update transaction status: $e');
    }
  }

  // Delete - Delete transaction by ID
  Future<int> deleteTransaction(int id) async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(
        DBConfig.transactionTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  // Delete - Delete all transactions
  Future<int> deleteAllTransactions() async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(DBConfig.transactionTable);
    } catch (e) {
      throw Exception('Failed to delete all transactions: $e');
    }
  }

  // Get total transaction count
  Future<int> getTransactionCount() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
          'SELECT COUNT(*) as count FROM ${DBConfig.transactionTable}');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Failed to get transaction count: $e');
    }
  }

  // Get transaction count by type
  Future<int> getTransactionCountByType(String type) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
          'SELECT COUNT(*) as count FROM ${DBConfig.transactionTable} WHERE type = ?',
          [type]);
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Failed to get transaction count by type: $e');
    }
  }

  // Get total points earned (from deposits)
  Future<double> getTotalPointsEarned(int userId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
          'SELECT SUM(total_price) as total FROM ${DBConfig.transactionTable} WHERE user_id = ? AND type = ? AND status = ?',
          [userId, 'deposit', 'completed']);

      final total = result.first['total'];
      return total != null ? (total as num).toDouble() : 0.0;
    } catch (e) {
      throw Exception('Failed to get total points earned: $e');
    }
  }

  // Get total points spent (from purchases)
  Future<double> getTotalPointsSpent(int userId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
          'SELECT SUM(total_price) as total FROM ${DBConfig.transactionTable} WHERE user_id = ? AND type = ? AND status = ?',
          [userId, 'purchase', 'completed']);

      final total = result.first['total'];
      return total != null ? (total as num).toDouble() : 0.0;
    } catch (e) {
      throw Exception('Failed to get total points spent: $e');
    }
  }
}
