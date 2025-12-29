import 'package:sqflite/sqflite.dart';
import 'platform_db_helper.dart';

/// Wrapper class for backward compatibility
/// Uses PlatformDBHelper for multi-platform support
class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  final PlatformDBHelper _platformHelper = PlatformDBHelper();

  factory DBHelper() {
    return _instance;
  }

  DBHelper._internal();

  Future<Database> get database async {
    return await _platformHelper.database;
  }

  Future<T> runInTransaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return db.transaction(action);
  }

  Future<void> closeDatabase() async {
    await _platformHelper.closeDatabase();
  }

  Future<void> deleteDatabase() async {
    await _platformHelper.deleteDatabase();
  }

  Future<int> getDatabaseSize() async {
    return await _platformHelper.getDatabaseSize();
  }

  Future<String?> backupDatabase() async {
    return await _platformHelper.backupDatabase();
  }
}
