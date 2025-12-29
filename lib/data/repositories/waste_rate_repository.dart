import 'package:sqflite/sqflite.dart';
import '../../core/database/db_config.dart';
import '../../core/database/db_helper.dart';
import '../models/waste_rate_model.dart';

class WasteRateRepository {
  WasteRateRepository({DBHelper? dbHelper}) : _dbHelper = dbHelper ?? DBHelper();

  final DBHelper _dbHelper;

  Future<List<WasteRateModel>> getActiveWasteRates() async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      DBConfig.wasteRateTable,
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return rows.map(WasteRateModel.fromMap).toList();
  }

  Future<WasteRateModel?> getWasteRateById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      DBConfig.wasteRateTable,
      where: '${DBConfig.columnId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return WasteRateModel.fromMap(rows.first);
  }

  Future<WasteRateModel?> getWasteRateByName(String name) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      DBConfig.wasteRateTable,
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return WasteRateModel.fromMap(rows.first);
  }

  Future<int> upsertWasteRate(WasteRateModel model) async {
    final db = await _dbHelper.database;
    final updated = model.copyWith(updatedAt: DateTime.now());
    return db.insert(
      DBConfig.wasteRateTable,
      updated.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

