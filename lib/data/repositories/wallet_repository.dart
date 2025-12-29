import 'package:sqflite/sqflite.dart';
import '../../core/database/db_helper.dart';
import '../../core/database/db_config.dart';
import '../models/wallet_model.dart';
import 'settings_repository.dart';

class WalletRepository {
  final DBHelper _dbHelper = DBHelper();
  final SettingsRepository _settingsRepository = SettingsRepository();

  Future<void> _syncUserEcoPoints(int userId, double ecoPoints) async {
    final db = await _dbHelper.database;
    await db.update(
      DBConfig.userTable,
      {
        'eco_points': ecoPoints,
        DBConfig.columnUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${DBConfig.columnId} = ?',
      whereArgs: [userId],
    );
  }

  Future<WalletModel> _withCalculatedRupiah(WalletModel wallet) async {
    final rate = await _settingsRepository.getPointToRupiahRate();
    return wallet.copyWith(rupiahValue: wallet.ecoPoints * rate);
  }

  // Create - Create new wallet for user
  Future<int> createWallet(WalletModel wallet) async {
    try {
      final db = await _dbHelper.database;
      final calculated = await _withCalculatedRupiah(wallet);
      final id = await db.insert(
        DBConfig.walletTable,
        calculated.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await _syncUserEcoPoints(wallet.userId, wallet.ecoPoints);
      return id;
    } catch (e) {
      throw Exception('Failed to create wallet: $e');
    }
  }

  // Read - Get wallet by user ID
  Future<WalletModel?> getWalletByUserId(int userId) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.walletTable,
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return WalletModel.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to get wallet by user ID: $e');
    }
  }

  // Read - Get wallet by ID
  Future<WalletModel?> getWalletById(int id) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.walletTable,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return WalletModel.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to get wallet by ID: $e');
    }
  }

  // Read - Get all wallets
  Future<List<WalletModel>> getAllWallets() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.walletTable,
        orderBy: 'eco_points DESC',
      );

      return List.generate(maps.length, (i) {
        return WalletModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get all wallets: $e');
    }
  }

  // Update - Update wallet
  Future<int> updateWallet(WalletModel wallet) async {
    try {
      final db = await _dbHelper.database;
      final updatedWallet = wallet.copyWith(updatedAt: DateTime.now());
      final calculated = await _withCalculatedRupiah(updatedWallet);

      return await db.update(
        DBConfig.walletTable,
        calculated.toMap(),
        where: 'user_id = ?',
        whereArgs: [wallet.userId],
      );
    } catch (e) {
      throw Exception('Failed to update wallet: $e');
    }
  }

  // Update - Add points to wallet
  Future<bool> addPoints(int userId, double points) async {
    try {
      final wallet = await getWalletByUserId(userId);
      if (wallet == null) {
        // Create wallet if it doesn't exist
        final newWallet = WalletModel(
          userId: userId,
          ecoPoints: points,
        );
        await createWallet(newWallet);
        return true;
      }

      final updatedWallet = wallet.addPoints(points);
      await updateWallet(updatedWallet);
      await _syncUserEcoPoints(userId, updatedWallet.ecoPoints);
      return true;
    } catch (e) {
      throw Exception('Failed to add points: $e');
    }
  }

  // Update - Deduct points from wallet
  Future<bool> deductPoints(int userId, double points) async {
    try {
      final wallet = await getWalletByUserId(userId);
      if (wallet == null) {
        throw Exception('Wallet not found for user');
      }

      if (wallet.ecoPoints < points) {
        throw Exception('Insufficient eco points');
      }

      final updatedWallet = wallet.deductPoints(points);
      await updateWallet(updatedWallet);
      await _syncUserEcoPoints(userId, updatedWallet.ecoPoints);
      return true;
    } catch (e) {
      throw Exception('Failed to deduct points: $e');
    }
  }

  // Read - Get balance (eco points)
  Future<double> getBalance(int userId) async {
    try {
      final wallet = await getWalletByUserId(userId);
      return wallet?.ecoPoints ?? 0.0;
    } catch (e) {
      throw Exception('Failed to get balance: $e');
    }
  }

  // Read - Get rupiah value
  Future<double> getRupiahValue(int userId) async {
    try {
      final wallet = await getWalletByUserId(userId);
      return wallet?.rupiahValue ?? 0.0;
    } catch (e) {
      throw Exception('Failed to get rupiah value: $e');
    }
  }

  // Delete - Delete wallet by user ID
  Future<int> deleteWalletByUserId(int userId) async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(
        DBConfig.walletTable,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      throw Exception('Failed to delete wallet: $e');
    }
  }

  // Delete - Delete wallet by ID
  Future<int> deleteWallet(int id) async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(
        DBConfig.walletTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete wallet: $e');
    }
  }

  // Check if wallet exists for user
  Future<bool> walletExists(int userId) async {
    try {
      final wallet = await getWalletByUserId(userId);
      return wallet != null;
    } catch (e) {
      throw Exception('Failed to check wallet existence: $e');
    }
  }

  // Get or create wallet (ensures wallet exists)
  Future<WalletModel> getOrCreateWallet(int userId) async {
    try {
      var wallet = await getWalletByUserId(userId);
      if (wallet == null) {
        final newWallet = WalletModel(
          userId: userId,
          ecoPoints: 0.0,
        );
        await createWallet(newWallet);
        wallet = await getWalletByUserId(userId);
      }
      return wallet!;
    } catch (e) {
      throw Exception('Failed to get or create wallet: $e');
    }
  }

  // Get total eco points across all wallets
  Future<double> getTotalEcoPoints() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
          'SELECT SUM(eco_points) as total FROM ${DBConfig.walletTable}');

      final total = result.first['total'];
      return total != null ? (total as num).toDouble() : 0.0;
    } catch (e) {
      throw Exception('Failed to get total eco points: $e');
    }
  }

  // Get wallet count
  Future<int> getWalletCount() async {
    try {
      final db = await _dbHelper.database;
      final result = await db
          .rawQuery('SELECT COUNT(*) as count FROM ${DBConfig.walletTable}');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Failed to get wallet count: $e');
    }
  }
}
