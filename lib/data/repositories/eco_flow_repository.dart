import 'package:sqflite/sqflite.dart';
import '../../core/database/db_config.dart';
import '../../core/database/db_helper.dart';
import 'settings_repository.dart';

class PurchaseItemInput {
  PurchaseItemInput({required this.productId, required this.quantity});

  final int productId;
  final int quantity;
}

class PurchaseResult {
  PurchaseResult({
    required this.totalPointsSpent,
    required this.itemLines,
  });

  final double totalPointsSpent;
  final int itemLines;
}

class DepositResult {
  DepositResult({
    required this.pointsEarned,
    required this.wasteType,
    required this.weightKg,
  });

  final double pointsEarned;
  final String wasteType;
  final double weightKg;
}

class EcoFlowRepository {
  EcoFlowRepository({DBHelper? dbHelper, SettingsRepository? settingsRepository})
      : _dbHelper = dbHelper ?? DBHelper(),
        _settingsRepository = settingsRepository ?? SettingsRepository();

  final DBHelper _dbHelper;
  final SettingsRepository _settingsRepository;

  Future<DepositResult> processDeposit({
    required int userId,
    required int wasteRateId,
    required double weightKg,
  }) async {
    if (weightKg <= 0) {
      throw Exception('Berat harus lebih dari 0');
    }

    final pointToRupiahRate = await _settingsRepository.getPointToRupiahRate();

    return _dbHelper.runInTransaction((txn) async {
      final wasteRows = await txn.query(
        DBConfig.wasteRateTable,
        where: '${DBConfig.columnId} = ? AND is_active = ?',
        whereArgs: [wasteRateId, 1],
        limit: 1,
      );
      if (wasteRows.isEmpty) {
        throw Exception('Jenis sampah tidak ditemukan');
      }

      final wasteType = wasteRows.first['name'] as String;
      final rupiahPerKg =
          (wasteRows.first['rupiah_per_kg'] as num).toDouble();
      final pointsEarned = (weightKg * rupiahPerKg) / pointToRupiahRate;

      await _applyWalletDelta(
        txn,
        userId: userId,
        deltaPoints: pointsEarned,
        pointToRupiahRate: pointToRupiahRate,
      );

      final now = DateTime.now().toIso8601String();
      await txn.insert(DBConfig.transactionTable, {
        'user_id': userId,
        'product_id': null,
        'quantity': weightKg,
        'total_price': pointsEarned,
        'transaction_date': now,
        'status': 'completed',
        'type': 'deposit',
        'waste_type': wasteType,
        'product_name': null,
      });

      return DepositResult(
        pointsEarned: pointsEarned,
        wasteType: wasteType,
        weightKg: weightKg,
      );
    });
  }

  Future<PurchaseResult> processPurchase({
    required int userId,
    required List<PurchaseItemInput> items,
  }) async {
    if (items.isEmpty) {
      throw Exception('Keranjang kosong');
    }

    final pointToRupiahRate = await _settingsRepository.getPointToRupiahRate();

    return _dbHelper.runInTransaction((txn) async {
      final wallet = await _getOrCreateWallet(txn, userId);

      double totalPoints = 0.0;
      final productRowsById = <int, Map<String, dynamic>>{};

      for (final item in items) {
        if (item.quantity <= 0) {
          throw Exception('Jumlah item tidak valid');
        }

        final rows = await txn.query(
          DBConfig.productTable,
          where: 'id = ?',
          whereArgs: [item.productId],
          limit: 1,
        );
        if (rows.isEmpty) {
          throw Exception('Produk tidak ditemukan');
        }

        final productRow = rows.first;
        final stock = (productRow['stock'] as num).toInt();
        if (stock < item.quantity) {
          final name = productRow['name'] as String;
          throw Exception('Stok tidak cukup untuk $name');
        }

        productRowsById[item.productId] = productRow;
        final price = (productRow['price'] as num).toDouble();
        totalPoints += price * item.quantity;
      }

      if (wallet['eco_points'] is! num) {
        throw Exception('Saldo tidak valid');
      }
      final currentPoints = (wallet['eco_points'] as num).toDouble();
      if (currentPoints < totalPoints) {
        throw Exception('Saldo EcoPoin tidak mencukupi');
      }

      await _applyWalletDelta(
        txn,
        userId: userId,
        deltaPoints: -totalPoints,
        pointToRupiahRate: pointToRupiahRate,
      );

      final now = DateTime.now().toIso8601String();
      for (final item in items) {
        final productRow = productRowsById[item.productId]!;
        final price = (productRow['price'] as num).toDouble();
        final productName = productRow['name'] as String;
        final currentStock = (productRow['stock'] as num).toInt();
        final newStock = currentStock - item.quantity;

        await txn.update(
          DBConfig.productTable,
          {
            'stock': newStock,
            'updated_at': now,
          },
          where: 'id = ?',
          whereArgs: [item.productId],
        );

        await txn.insert(DBConfig.transactionTable, {
          'user_id': userId,
          'product_id': item.productId,
          'quantity': item.quantity,
          'total_price': price * item.quantity,
          'transaction_date': now,
          'status': 'completed',
          'type': 'purchase',
          'waste_type': null,
          'product_name': productName,
        });
      }

      return PurchaseResult(totalPointsSpent: totalPoints, itemLines: items.length);
    });
  }

  Future<Map<String, dynamic>> _getOrCreateWallet(
    DatabaseExecutor txn,
    int userId,
  ) async {
    final rows = await txn.query(
      DBConfig.walletTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (rows.isNotEmpty) return rows.first;

    final now = DateTime.now().toIso8601String();
    await txn.insert(DBConfig.walletTable, {
      'user_id': userId,
      'eco_points': 0.0,
      'rupiah_value': 0.0,
      'updated_at': now,
    });

    final created = await txn.query(
      DBConfig.walletTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (created.isEmpty) throw Exception('Gagal membuat wallet');
    return created.first;
  }

  Future<void> _applyWalletDelta(
    DatabaseExecutor txn, {
    required int userId,
    required double deltaPoints,
    required double pointToRupiahRate,
  }) async {
    final wallet = await _getOrCreateWallet(txn, userId);
    final currentPoints = (wallet['eco_points'] as num).toDouble();
    final newPoints = currentPoints + deltaPoints;
    if (newPoints < 0) {
      throw Exception('Saldo tidak mencukupi');
    }

    final now = DateTime.now().toIso8601String();
    await txn.update(
      DBConfig.walletTable,
      {
        'eco_points': newPoints,
        'rupiah_value': newPoints * pointToRupiahRate,
        'updated_at': now,
      },
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    await txn.update(
      DBConfig.userTable,
      {
        'eco_points': newPoints,
        DBConfig.columnUpdatedAt: now,
      },
      where: '${DBConfig.columnId} = ?',
      whereArgs: [userId],
    );
  }
}

