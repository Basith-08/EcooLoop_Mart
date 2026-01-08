import '../../core/database/db_config.dart';
import '../../core/database/db_helper.dart';
import 'partner_hybrid_repository.dart';

class AdminReportData {
  AdminReportData({
    required this.totalWasteKg,
    required this.totalTransactions,
    required this.topWasteType,
    required this.depositCountThisMonth,
    required this.totalWarga,
    required this.newWargaThisMonth,
    required this.activeWargaPercentThisMonth,
    required this.pointsCirculating,
    required this.pointsSpent,
    required this.stockHealthPercent,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.pengrajinCount,
    required this.grosirCount,
  });

  final double totalWasteKg;
  final int totalTransactions;
  final String? topWasteType;
  final int depositCountThisMonth;
  final int totalWarga;
  final int newWargaThisMonth;
  final int activeWargaPercentThisMonth;
  final double pointsCirculating;
  final double pointsSpent;
  final int stockHealthPercent;
  final int lowStockCount;
  final int outOfStockCount;
  final int pengrajinCount;
  final int grosirCount;
}

class DashboardSummary {
  DashboardSummary({
    required this.pointsEarnedThisMonth,
    required this.pointsSpentThisMonth,
    required this.transactionCountThisMonth,
  });

  final double pointsEarnedThisMonth;
  final double pointsSpentThisMonth;
  final int transactionCountThisMonth;
}

class ReportRepository {
  ReportRepository({
    DBHelper? dbHelper,
    PartnerHybridRepository? partnerRepository,
  })  : _dbHelper = dbHelper ?? DBHelper(),
        _partnerRepository = partnerRepository ?? PartnerHybridRepository();

  final DBHelper _dbHelper;
  final PartnerHybridRepository _partnerRepository;

  DateTime _monthStart(DateTime now) => DateTime(now.year, now.month, 1);
  DateTime _nextMonthStart(DateTime now) =>
      now.month == 12 ? DateTime(now.year + 1, 1, 1) : DateTime(now.year, now.month + 1, 1);

  Future<DashboardSummary> getDashboardSummary() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final start = _monthStart(now).toIso8601String();
    final end = _nextMonthStart(now).toIso8601String();

    final earnedRows = await db.rawQuery(
      'SELECT SUM(total_price) as total FROM ${DBConfig.transactionTable} '
      'WHERE type = ? AND status = ? AND transaction_date >= ? AND transaction_date < ?',
      ['deposit', 'completed', start, end],
    );
    final spentRows = await db.rawQuery(
      'SELECT SUM(total_price) as total FROM ${DBConfig.transactionTable} '
      'WHERE type = ? AND status = ? AND transaction_date >= ? AND transaction_date < ?',
      ['purchase', 'completed', start, end],
    );
    final countRows = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DBConfig.transactionTable} '
      'WHERE status = ? AND transaction_date >= ? AND transaction_date < ?',
      ['completed', start, end],
    );

    return DashboardSummary(
      pointsEarnedThisMonth: (earnedRows.first['total'] as num?)?.toDouble() ?? 0.0,
      pointsSpentThisMonth: (spentRows.first['total'] as num?)?.toDouble() ?? 0.0,
      transactionCountThisMonth: (countRows.first['count'] as num?)?.toInt() ?? 0,
    );
  }

  Future<AdminReportData> getAdminReportData() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final start = _monthStart(now).toIso8601String();
    final end = _nextMonthStart(now).toIso8601String();

    final totalWasteRows = await db.rawQuery(
      'SELECT SUM(quantity) as total FROM ${DBConfig.transactionTable} '
      'WHERE type = ? AND status = ?',
      ['deposit', 'completed'],
    );

    final txnCountRows = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DBConfig.transactionTable} WHERE status = ?',
      ['completed'],
    );

    final topWasteRows = await db.rawQuery(
      'SELECT waste_type, SUM(quantity) as total '
      'FROM ${DBConfig.transactionTable} '
      'WHERE type = ? AND status = ? AND waste_type IS NOT NULL '
      'GROUP BY waste_type ORDER BY total DESC LIMIT 1',
      ['deposit', 'completed'],
    );

    final depositThisMonthRows = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DBConfig.transactionTable} '
      'WHERE type = ? AND status = ? AND transaction_date >= ? AND transaction_date < ?',
      ['deposit', 'completed', start, end],
    );

    final totalWargaRows = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DBConfig.userTable} WHERE role = ?',
      ['warga'],
    );

    final newWargaThisMonthRows = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DBConfig.userTable} '
      'WHERE role = ? AND created_at >= ? AND created_at < ?',
      ['warga', start, end],
    );

    final activeWargaRows = await db.rawQuery(
      'SELECT COUNT(DISTINCT user_id) as count '
      'FROM ${DBConfig.transactionTable} t '
      'JOIN ${DBConfig.userTable} u ON u.id = t.user_id '
      "WHERE u.role = 'warga' AND t.status = ? AND t.transaction_date >= ? AND t.transaction_date < ?",
      ['completed', start, end],
    );

    final totalWarga = (totalWargaRows.first['count'] as num?)?.toInt() ?? 0;
    final newWargaThisMonth =
        (newWargaThisMonthRows.first['count'] as num?)?.toInt() ?? 0;
    final activeWarga = (activeWargaRows.first['count'] as num?)?.toInt() ?? 0;
    final activeWargaPercent =
        totalWarga == 0 ? 0 : ((activeWarga / totalWarga) * 100).round();

    final pointsCirculatingRows = await db.rawQuery(
      'SELECT SUM(eco_points) as total FROM ${DBConfig.walletTable}',
    );

    final pointsSpentRows = await db.rawQuery(
      'SELECT SUM(total_price) as total FROM ${DBConfig.transactionTable} '
      'WHERE type = ? AND status = ?',
      ['purchase', 'completed'],
    );

    final lowStockRows = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DBConfig.productTable} WHERE stock > 0 AND stock <= ?',
      [5],
    );
    final outOfStockRows = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DBConfig.productTable} WHERE stock = 0',
    );
    final productCountRows = await db
        .rawQuery('SELECT COUNT(*) as count FROM ${DBConfig.productTable}');
    final readyProductCountRows = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DBConfig.productTable} WHERE stock > 0',
    );
    final totalProducts = (productCountRows.first['count'] as num?)?.toInt() ?? 0;
    final readyProducts =
        (readyProductCountRows.first['count'] as num?)?.toInt() ?? 0;
    final stockHealthPercent =
        totalProducts == 0 ? 0 : ((readyProducts / totalProducts) * 100).round();

    final pengrajinCount = await _partnerRepository.getPartnerCountByType('pengrajin');
    final grosirCount = await _partnerRepository.getPartnerCountByType('grosir');

    return AdminReportData(
      totalWasteKg: (totalWasteRows.first['total'] as num?)?.toDouble() ?? 0.0,
      totalTransactions: (txnCountRows.first['count'] as num?)?.toInt() ?? 0,
      topWasteType: topWasteRows.isEmpty ? null : (topWasteRows.first['waste_type'] as String?),
      depositCountThisMonth: (depositThisMonthRows.first['count'] as num?)?.toInt() ?? 0,
      totalWarga: totalWarga,
      newWargaThisMonth: newWargaThisMonth,
      activeWargaPercentThisMonth: activeWargaPercent,
      pointsCirculating: (pointsCirculatingRows.first['total'] as num?)?.toDouble() ?? 0.0,
      pointsSpent: (pointsSpentRows.first['total'] as num?)?.toDouble() ?? 0.0,
      stockHealthPercent: stockHealthPercent,
      lowStockCount: (lowStockRows.first['count'] as num?)?.toInt() ?? 0,
      outOfStockCount: (outOfStockRows.first['count'] as num?)?.toInt() ?? 0,
      pengrajinCount: pengrajinCount,
      grosirCount: grosirCount,
    );
  }
}
