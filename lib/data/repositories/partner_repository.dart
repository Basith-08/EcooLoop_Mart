import '../../core/database/db_config.dart';
import '../../core/database/db_helper.dart';
import '../models/partner_model.dart';

class PartnerRepository {
  PartnerRepository({DBHelper? dbHelper}) : _dbHelper = dbHelper ?? DBHelper();

  final DBHelper _dbHelper;

  Future<List<PartnerModel>> getPartnersByType(String type) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      DBConfig.partnerTable,
      where: 'type = ? AND is_active = ?',
      whereArgs: [type, 1],
      orderBy: 'name ASC',
    );
    return rows.map(PartnerModel.fromMap).toList();
  }

  Future<int> getPartnerCountByType(String type) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DBConfig.partnerTable} WHERE type = ? AND is_active = ?',
      [type, 1],
    );
    return (rows.first['count'] as num?)?.toInt() ?? 0;
  }

  Future<PartnerModel?> getPartnerById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      DBConfig.partnerTable,
      where: '${DBConfig.columnId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return PartnerModel.fromMap(rows.first);
  }

  Future<int> createPartner(PartnerModel model) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    return db.insert(
      DBConfig.partnerTable,
      model
          .copyWith(createdAt: now, updatedAt: now, isActive: true)
          .toMap()
        ..remove(DBConfig.columnId),
    );
  }

  Future<int> updatePartner(PartnerModel model) async {
    if (model.id == null) {
      throw Exception('Partner ID is required for update');
    }
    final db = await _dbHelper.database;
    final updated = model.copyWith(updatedAt: DateTime.now());
    return db.update(
      DBConfig.partnerTable,
      updated.toMap(),
      where: '${DBConfig.columnId} = ?',
      whereArgs: [model.id],
    );
  }

  Future<int> setPartnerActive(int id, bool isActive) async {
    final db = await _dbHelper.database;
    return db.update(
      DBConfig.partnerTable,
      {
        'is_active': isActive ? 1 : 0,
        DBConfig.columnUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${DBConfig.columnId} = ?',
      whereArgs: [id],
    );
  }
}
