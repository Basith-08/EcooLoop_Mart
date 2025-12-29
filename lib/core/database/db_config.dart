class DBConfig {
  static const String dbName = 'ecoloop_mart.db';
  static const int dbVersion = 2;

  // Table names
  static const String userTable = 'users';
  static const String productTable = 'products';
  static const String transactionTable = 'transactions';
  static const String walletTable = 'wallets';
  static const String settingsTable = 'settings';
  static const String wasteRateTable = 'waste_rates';
  static const String partnerTable = 'partners';

  // User table columns
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnEmail = 'email';
  static const String columnPhone = 'phone';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  // Settings keys
  static const String settingPointToRupiahRate = 'point_to_rupiah_rate';
}
