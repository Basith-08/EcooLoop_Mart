import 'package:sqflite/sqflite.dart';
import '../../core/database/db_config.dart';
import '../../core/database/db_helper.dart';

class SettingsRepository {
  SettingsRepository({DBHelper? dbHelper}) : _dbHelper = dbHelper ?? DBHelper();

  final DBHelper _dbHelper;

  Future<double> getPointToRupiahRate() async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      DBConfig.settingsTable,
      where: 'key = ?',
      whereArgs: [DBConfig.settingPointToRupiahRate],
      limit: 1,
    );

    if (rows.isEmpty) {
      await upsertPointToRupiahRate(150.0);
      return 150.0;
    }

    final raw = rows.first['value']?.toString() ?? '150';
    return double.tryParse(raw) ?? 150.0;
  }

  Future<void> upsertPointToRupiahRate(double rate) async {
    final db = await _dbHelper.database;
    await db.insert(
      DBConfig.settingsTable,
      {
        'key': DBConfig.settingPointToRupiahRate,
        'value': rate.toString(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

