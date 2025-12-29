import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'db_config.dart';

/// Platform-agnostic database helper that works on:
/// - Android & iOS (using sqflite)
/// - Web (using sqflite_ffi_web with IndexedDB)
/// - Desktop: Windows, macOS, Linux (using sqflite_ffi)
class PlatformDBHelper {
  static final PlatformDBHelper _instance = PlatformDBHelper._internal();
  static Database? _database;
  static bool _initialized = false;

  factory PlatformDBHelper() {
    return _instance;
  }

  PlatformDBHelper._internal();

  /// Initialize database factory based on platform
  static Future<void> initialize() async {
    if (_initialized) return;

    if (kIsWeb) {
      // Web platform - use IndexedDB via sqflite_ffi_web
      databaseFactory = databaseFactoryFfiWeb;
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Desktop platforms - use FFI
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    // Android & iOS use default sqflite (no initialization needed)

    _initialized = true;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Ensure initialization
    await initialize();

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = await _getDatabasePath();

    return await openDatabase(
      path,
      version: DBConfig.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Get platform-specific database path
  Future<String> _getDatabasePath() async {
    if (kIsWeb) {
      // Web: Just use the database name (stored in IndexedDB)
      return DBConfig.dbName;
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Mobile: Use default database directory
      return join(await getDatabasesPath(), DBConfig.dbName);
    } else {
      // Desktop: Use application documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String dbPath = join(appDocDir.path, 'ecoloop_mart_db');

      // Create directory if it doesn't exist
      final Directory dbDir = Directory(dbPath);
      if (!await dbDir.exists()) {
        await dbDir.create(recursive: true);
      }

      return join(dbPath, DBConfig.dbName);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE ${DBConfig.userTable} (
        ${DBConfig.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DBConfig.columnName} TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'warga',
        ${DBConfig.columnEmail} TEXT,
        ${DBConfig.columnPhone} TEXT,
        eco_points REAL NOT NULL DEFAULT 0.0,
        status TEXT NOT NULL DEFAULT 'active',
        ${DBConfig.columnCreatedAt} TEXT NOT NULL,
        ${DBConfig.columnUpdatedAt} TEXT NOT NULL
      )
    ''');

    // Create products table
    await db.execute('''
      CREATE TABLE ${DBConfig.productTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0,
        image_url TEXT,
        category TEXT,
        is_eco_friendly INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE ${DBConfig.transactionTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        product_id INTEGER,
        quantity INTEGER NOT NULL,
        total_price REAL NOT NULL,
        transaction_date TEXT NOT NULL,
        status TEXT NOT NULL,
        type TEXT NOT NULL,
        waste_type TEXT,
        product_name TEXT,
        FOREIGN KEY (user_id) REFERENCES ${DBConfig.userTable} (${DBConfig.columnId}),
        FOREIGN KEY (product_id) REFERENCES ${DBConfig.productTable} (id)
      )
    ''');

    // Create wallets table
    await db.execute('''
      CREATE TABLE ${DBConfig.walletTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL UNIQUE,
        eco_points REAL NOT NULL DEFAULT 0.0,
        rupiah_value REAL NOT NULL DEFAULT 0.0,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES ${DBConfig.userTable} (${DBConfig.columnId})
      )
    ''');

    await _createSettingsTables(db);
    await _createWasteRateTable(db);
    await _createPartnerTable(db);

    // Insert default admin account
    await db.insert('${DBConfig.userTable}', {
      'name': 'Admin IndoApril',
      'username': 'admin',
      'password': 'admin123',
      'role': 'admin',
      'email': 'admin@ecoloopmart.com',
      'eco_points': 0.0,
      'status': 'active',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    await _seedSettings(db);
    await _seedWasteRates(db);
    await _seedPartners(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < 2) {
      await _createSettingsTables(db);
      await _createWasteRateTable(db);
      await _createPartnerTable(db);
      await _seedSettings(db);
      await _seedWasteRates(db);
      await _seedPartners(db);
    }
  }

  Future<void> _createSettingsTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DBConfig.settingsTable} (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createWasteRateTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DBConfig.wasteRateTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        rupiah_per_kg REAL NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createPartnerTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DBConfig.partnerTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        name TEXT NOT NULL,
        location TEXT,
        tag TEXT,
        subtitle TEXT,
        area TEXT,
        detail TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _seedSettings(Database db) async {
    final now = DateTime.now().toIso8601String();
    await db.insert(
      DBConfig.settingsTable,
      {
        'key': DBConfig.settingPointToRupiahRate,
        'value': '150',
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> _seedWasteRates(Database db) async {
    final now = DateTime.now().toIso8601String();
    final seeds = [
      {'name': 'Kardus Bekas', 'rupiah_per_kg': 20.0},
      {'name': 'Botol Plastik', 'rupiah_per_kg': 35.0},
      {'name': 'Kaleng Aluminium', 'rupiah_per_kg': 50.0},
      {'name': 'Minyak Jelantah', 'rupiah_per_kg': 40.0},
    ];

    for (final row in seeds) {
      await db.insert(
        DBConfig.wasteRateTable,
        {
          'name': row['name'],
          'rupiah_per_kg': row['rupiah_per_kg'],
          'is_active': 1,
          'created_at': now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> _seedPartners(Database db) async {
    final now = DateTime.now().toIso8601String();

    final partners = [
      // Pengrajin Sampah
      {
        'type': 'pengrajin',
        'name': 'CV Kreasi Plastik',
        'location': 'Tangerang',
        'tag': 'Paving Block & Bata',
      },
      {
        'type': 'pengrajin',
        'name': 'Bank Sampah Kreatif',
        'location': 'Jakarta Selatan',
        'tag': 'Tas & Dompet Daur Ulang',
      },
      {
        'type': 'pengrajin',
        'name': 'Studio Pot Botol',
        'location': 'Depok',
        'tag': 'Pot Tanaman Hias',
      },
      // Agen Grosir
      {
        'type': 'grosir',
        'name': 'Toko H. Slamet',
        'subtitle': 'Agen Sembako Grosir',
        'area': 'Ps. Kramat Jati',
        'detail': 'Blok A1 No. 4',
      },
      {
        'type': 'grosir',
        'name': 'Agen Beras Makmur',
        'subtitle': 'Spesialis Beras Premium',
        'area': 'Ps. Induk Cipinang',
        'detail': 'Gudang Beras No. 12',
      },
      {
        'type': 'grosir',
        'name': 'Grosir Telur Rejeki',
        'subtitle': 'Suplier Telur Ayam',
        'area': 'Ps. Minggu',
        'detail': 'Los Blash B-10',
      },
    ];

    for (final partner in partners) {
      await db.insert(
        DBConfig.partnerTable,
        {
          ...partner,
          'is_active': 1,
          'created_at': now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Future<void> deleteDatabase() async {
    if (kIsWeb) {
      // Web: Delete from IndexedDB
      await databaseFactory.deleteDatabase(DBConfig.dbName);
    } else {
      String path = await _getDatabasePath();
      await databaseFactory.deleteDatabase(path);
    }
    _database = null;
  }

  /// Get database size (useful for monitoring)
  Future<int> getDatabaseSize() async {
    if (kIsWeb) {
      // Cannot get size on web easily
      return 0;
    }

    try {
      String path = await _getDatabasePath();
      final File dbFile = File(path);
      if (await dbFile.exists()) {
        return await dbFile.length();
      }
    } catch (e) {
      print('Error getting database size: $e');
    }
    return 0;
  }

  /// Backup database (desktop/mobile only)
  Future<String?> backupDatabase() async {
    if (kIsWeb) {
      return null; // Web doesn't support file backup
    }

    try {
      String sourcePath = await _getDatabasePath();
      final File sourceFile = File(sourcePath);

      if (!await sourceFile.exists()) {
        return null;
      }

      // Create backup directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String backupDir = join(appDocDir.path, 'ecoloop_mart_backups');
      final Directory backupDirectory = Directory(backupDir);

      if (!await backupDirectory.exists()) {
        await backupDirectory.create(recursive: true);
      }

      // Create backup file with timestamp
      final String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final String backupPath = join(backupDir, 'backup_$timestamp.db');

      await sourceFile.copy(backupPath);
      return backupPath;
    } catch (e) {
      print('Error backing up database: $e');
      return null;
    }
  }
}
