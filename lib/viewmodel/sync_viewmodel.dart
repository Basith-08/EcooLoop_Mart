import 'package:flutter/foundation.dart';
import '../core/services/firebase_sync_service.dart';
import '../data/repositories/user_hybrid_repository.dart';
import '../data/repositories/product_hybrid_repository.dart';
import '../data/repositories/transaction_hybrid_repository.dart';
import '../data/repositories/wallet_hybrid_repository.dart';
import '../data/repositories/partner_hybrid_repository.dart';
import '../data/repositories/waste_rate_hybrid_repository.dart';

/// ViewModel untuk mengelola synchronization antara local dan cloud
///
/// Gunakan ini di UI untuk:
/// - Show sync status
/// - Manual sync trigger
/// - Monitor sync progress
class SyncViewModel extends ChangeNotifier {
  final UserHybridRepository _userRepo;
  final ProductHybridRepository _productRepo;
  final TransactionHybridRepository _transactionRepo;
  final WalletHybridRepository _walletRepo;
  final PartnerHybridRepository _partnerRepo;
  final WasteRateHybridRepository _wasteRateRepo;

  SyncViewModel({
    required UserHybridRepository userRepo,
    required ProductHybridRepository productRepo,
    required TransactionHybridRepository transactionRepo,
    required WalletHybridRepository walletRepo,
    required PartnerHybridRepository partnerRepo,
    required WasteRateHybridRepository wasteRateRepo,
  })  : _userRepo = userRepo,
        _productRepo = productRepo,
        _transactionRepo = transactionRepo,
        _walletRepo = walletRepo,
        _partnerRepo = partnerRepo,
        _wasteRateRepo = wasteRateRepo;

  bool _isSyncing = false;
  String? _errorMessage;
  String? _successMessage;
  DateTime? _lastSyncTime;
  int? _lastSyncedItems;
  String _currentSyncEntity = '';

  // Getters
  bool get isSyncing => _isSyncing;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  DateTime? get lastSyncTime => _lastSyncTime;
  int? get lastSyncedItems => _lastSyncedItems;
  bool get hasError => _errorMessage != null;
  bool get hasSuccess => _successMessage != null;
  String get currentSyncEntity => _currentSyncEntity;

  // Get sync status dari user repository
  SyncStatus get syncStatus => _userRepo.syncStatus;

  /// Check internet connection
  Future<bool> checkConnection() async {
    try {
      return await _userRepo.checkConnection();
    } catch (e) {
      return false;
    }
  }

  /// Sync ALL entities dari local ke cloud (Upload)
  Future<void> syncToCloud() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Check connection first
      final hasConnection = await checkConnection();
      if (!hasConnection) {
        throw Exception('Tidak ada koneksi internet');
      }

      int totalSynced = 0;

      // Sync Users
      _currentSyncEntity = 'Users';
      notifyListeners();
      final userResult = await _userRepo.syncToCloud();
      if (!userResult.isSuccess) throw Exception(userResult.message);
      totalSynced += userResult.itemsSynced ?? 0;

      // Sync Products
      _currentSyncEntity = 'Products';
      notifyListeners();
      final productResult = await _productRepo.syncToCloud();
      if (!productResult.isSuccess) throw Exception(productResult.message);
      totalSynced += productResult.itemsSynced ?? 0;

      // Sync Transactions
      _currentSyncEntity = 'Transactions';
      notifyListeners();
      final transactionResult = await _transactionRepo.syncToCloud();
      if (!transactionResult.isSuccess) throw Exception(transactionResult.message);
      totalSynced += transactionResult.itemsSynced ?? 0;

      // Sync Wallets
      _currentSyncEntity = 'Wallets';
      notifyListeners();
      final walletResult = await _walletRepo.syncToCloud();
      if (!walletResult.isSuccess) throw Exception(walletResult.message);
      totalSynced += walletResult.itemsSynced ?? 0;

      // Sync Partners
      _currentSyncEntity = 'Partners';
      notifyListeners();
      final partnerResult = await _partnerRepo.syncToCloud();
      if (!partnerResult.isSuccess) throw Exception(partnerResult.message);
      totalSynced += partnerResult.itemsSynced ?? 0;

      // Sync Waste Rates
      _currentSyncEntity = 'Waste Rates';
      notifyListeners();
      final wasteRateResult = await _wasteRateRepo.syncToCloud();
      if (!wasteRateResult.isSuccess) throw Exception(wasteRateResult.message);
      totalSynced += wasteRateResult.itemsSynced ?? 0;

      _successMessage = 'Berhasil upload $totalSynced item ke cloud';
      _lastSyncTime = DateTime.now();
      _lastSyncedItems = totalSynced;
      _currentSyncEntity = '';
    } catch (e) {
      _errorMessage = 'Error: $e';
      _currentSyncEntity = '';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Sync ALL entities dari cloud ke local (Download)
  Future<void> syncFromCloud() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Check connection first
      final hasConnection = await checkConnection();
      if (!hasConnection) {
        throw Exception('Tidak ada koneksi internet');
      }

      int totalSynced = 0;

      // Sync Users
      _currentSyncEntity = 'Users';
      notifyListeners();
      final userResult = await _userRepo.syncFromCloud();
      if (!userResult.isSuccess) throw Exception(userResult.message);
      totalSynced += userResult.itemsSynced ?? 0;

      // Sync Products
      _currentSyncEntity = 'Products';
      notifyListeners();
      final productResult = await _productRepo.syncFromCloud();
      if (!productResult.isSuccess) throw Exception(productResult.message);
      totalSynced += productResult.itemsSynced ?? 0;

      // Sync Transactions
      _currentSyncEntity = 'Transactions';
      notifyListeners();
      final transactionResult = await _transactionRepo.syncFromCloud();
      if (!transactionResult.isSuccess) throw Exception(transactionResult.message);
      totalSynced += transactionResult.itemsSynced ?? 0;

      // Sync Wallets
      _currentSyncEntity = 'Wallets';
      notifyListeners();
      final walletResult = await _walletRepo.syncFromCloud();
      if (!walletResult.isSuccess) throw Exception(walletResult.message);
      totalSynced += walletResult.itemsSynced ?? 0;

      // Sync Partners
      _currentSyncEntity = 'Partners';
      notifyListeners();
      final partnerResult = await _partnerRepo.syncFromCloud();
      if (!partnerResult.isSuccess) throw Exception(partnerResult.message);
      totalSynced += partnerResult.itemsSynced ?? 0;

      // Sync Waste Rates
      _currentSyncEntity = 'Waste Rates';
      notifyListeners();
      final wasteRateResult = await _wasteRateRepo.syncFromCloud();
      if (!wasteRateResult.isSuccess) throw Exception(wasteRateResult.message);
      totalSynced += wasteRateResult.itemsSynced ?? 0;

      _successMessage = 'Berhasil download $totalSynced item dari cloud';
      _lastSyncTime = DateTime.now();
      _lastSyncedItems = totalSynced;
      _currentSyncEntity = '';
    } catch (e) {
      _errorMessage = 'Error: $e';
      _currentSyncEntity = '';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Bidirectional sync ALL entities (Upload & Download)
  Future<void> syncBidirectional() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Check connection first
      final hasConnection = await checkConnection();
      if (!hasConnection) {
        throw Exception('Tidak ada koneksi internet');
      }

      int totalSynced = 0;

      // Sync Users
      _currentSyncEntity = 'Users';
      notifyListeners();
      final userResult = await _userRepo.syncBidirectional();
      if (!userResult.isSuccess) throw Exception(userResult.message);
      totalSynced += userResult.itemsSynced ?? 0;

      // Sync Products
      _currentSyncEntity = 'Products';
      notifyListeners();
      final productResult = await _productRepo.syncBidirectional();
      if (!productResult.isSuccess) throw Exception(productResult.message);
      totalSynced += productResult.itemsSynced ?? 0;

      // Sync Transactions
      _currentSyncEntity = 'Transactions';
      notifyListeners();
      final transactionResult = await _transactionRepo.syncBidirectional();
      if (!transactionResult.isSuccess) throw Exception(transactionResult.message);
      totalSynced += transactionResult.itemsSynced ?? 0;

      // Sync Wallets
      _currentSyncEntity = 'Wallets';
      notifyListeners();
      final walletResult = await _walletRepo.syncBidirectional();
      if (!walletResult.isSuccess) throw Exception(walletResult.message);
      totalSynced += walletResult.itemsSynced ?? 0;

      // Sync Partners
      _currentSyncEntity = 'Partners';
      notifyListeners();
      final partnerResult = await _partnerRepo.syncBidirectional();
      if (!partnerResult.isSuccess) throw Exception(partnerResult.message);
      totalSynced += partnerResult.itemsSynced ?? 0;

      // Sync Waste Rates
      _currentSyncEntity = 'Waste Rates';
      notifyListeners();
      final wasteRateResult = await _wasteRateRepo.syncBidirectional();
      if (!wasteRateResult.isSuccess) throw Exception(wasteRateResult.message);
      totalSynced += wasteRateResult.itemsSynced ?? 0;

      _successMessage = 'Sync berhasil! Total: $totalSynced item';
      _lastSyncTime = DateTime.now();
      _lastSyncedItems = totalSynced;
      _currentSyncEntity = '';
    } catch (e) {
      _errorMessage = 'Error: $e';
      _currentSyncEntity = '';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Clear messages
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Reset sync status
  void resetStatus() {
    _isSyncing = false;
    _errorMessage = null;
    _successMessage = null;
    _currentSyncEntity = '';
    _userRepo.resetSyncStatus();
    _productRepo.resetSyncStatus();
    _transactionRepo.resetSyncStatus();
    _walletRepo.resetSyncStatus();
    _partnerRepo.resetSyncStatus();
    _wasteRateRepo.resetSyncStatus();
    notifyListeners();
  }

  /// Get sync status display text
  String getSyncStatusText() {
    if (_isSyncing && _currentSyncEntity.isNotEmpty) {
      return 'Syncing $_currentSyncEntity...';
    }

    switch (syncStatus) {
      case SyncStatus.idle:
        return 'Siap untuk sync';
      case SyncStatus.syncing:
        return 'Sedang sync...';
      case SyncStatus.success:
        if (_lastSyncTime != null) {
          final diff = DateTime.now().difference(_lastSyncTime!);
          if (diff.inMinutes < 1) {
            return 'Sync ${diff.inSeconds} detik yang lalu';
          } else if (diff.inHours < 1) {
            return 'Sync ${diff.inMinutes} menit yang lalu';
          } else if (diff.inDays < 1) {
            return 'Sync ${diff.inHours} jam yang lalu';
          } else {
            return 'Sync ${diff.inDays} hari yang lalu';
          }
        }
        return 'Sync berhasil';
      case SyncStatus.error:
        return 'Sync gagal';
      case SyncStatus.conflict:
        return 'Konflik data';
    }
  }
}
