import 'package:flutter/foundation.dart';
import '../data/models/wallet_model.dart';
import '../data/repositories/wallet_repository.dart';
import '../state/wallet_state.dart';

class WalletViewModel extends ChangeNotifier {
  final WalletRepository _repository;
  WalletState _state = const WalletInitial();

  WalletViewModel(this._repository);

  WalletState get state => _state;

  void _setState(WalletState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Load wallet for a specific user
  Future<void> loadWallet(int userId) async {
    try {
      _setState(const WalletLoading());

      // Get or create wallet for user
      final wallet = await _repository.getOrCreateWallet(userId);

      _setState(WalletLoaded(wallet));
    } catch (e) {
      _setState(WalletError(
        'Failed to load wallet',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Add points to user wallet
  Future<void> addPoints(int userId, double points) async {
    try {
      _setState(const WalletLoading());

      // Validate points
      if (points <= 0) {
        _setState(const WalletError('Points must be greater than zero'));
        return;
      }

      final success = await _repository.addPoints(userId, points);

      if (!success) {
        _setState(const WalletError('Failed to add points'));
        return;
      }

      // Reload wallet to get updated balance
      final wallet = await _repository.getWalletByUserId(userId);
      if (wallet == null) {
        _setState(const WalletError('Wallet not found after adding points'));
        return;
      }

      _setState(WalletUpdated(wallet, message: 'Points added successfully'));

      // Update to loaded state with new wallet
      _setState(WalletLoaded(wallet));
    } catch (e) {
      _setState(WalletError(
        'Failed to add points',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Deduct points from user wallet
  Future<void> deductPoints(int userId, double points) async {
    try {
      _setState(const WalletLoading());

      // Validate points
      if (points <= 0) {
        _setState(const WalletError('Points must be greater than zero'));
        return;
      }

      // Check if user has sufficient balance
      final currentBalance = await _repository.getBalance(userId);
      if (currentBalance < points) {
        _setState(const WalletError('Insufficient eco points'));
        return;
      }

      final success = await _repository.deductPoints(userId, points);

      if (!success) {
        _setState(const WalletError('Failed to deduct points'));
        return;
      }

      // Reload wallet to get updated balance
      final wallet = await _repository.getWalletByUserId(userId);
      if (wallet == null) {
        _setState(const WalletError('Wallet not found after deducting points'));
        return;
      }

      _setState(WalletUpdated(wallet, message: 'Points deducted successfully'));

      // Update to loaded state with new wallet
      _setState(WalletLoaded(wallet));
    } catch (e) {
      _setState(WalletError(
        'Failed to deduct points',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Get current balance for a user
  Future<double> getBalance(int userId) async {
    try {
      return await _repository.getBalance(userId);
    } catch (e) {
      return 0.0;
    }
  }

  /// Get rupiah value for user's eco points
  Future<double> getRupiahValue(int userId) async {
    try {
      return await _repository.getRupiahValue(userId);
    } catch (e) {
      return 0.0;
    }
  }

  /// Check if wallet exists for user
  Future<bool> walletExists(int userId) async {
    try {
      return await _repository.walletExists(userId);
    } catch (e) {
      return false;
    }
  }

  /// Create wallet for user if it doesn't exist
  Future<void> createWallet(int userId) async {
    try {
      _setState(const WalletLoading());

      final exists = await _repository.walletExists(userId);
      if (exists) {
        _setState(const WalletError('Wallet already exists for this user'));
        return;
      }

      final newWallet = WalletModel(
        userId: userId,
        ecoPoints: 0.0,
      );

      await _repository.createWallet(newWallet);

      // Reload wallet
      await loadWallet(userId);
    } catch (e) {
      _setState(WalletError(
        'Failed to create wallet',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Reset state to initial
  void resetState() {
    _setState(const WalletInitial());
  }
}
