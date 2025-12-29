import '../data/models/wallet_model.dart';

/// Base class for all wallet states
abstract class WalletState {
  const WalletState();
}

/// Initial state when no action has been performed
class WalletInitial extends WalletState {
  const WalletInitial();
}

/// Loading state while performing operations
class WalletLoading extends WalletState {
  const WalletLoading();
}

/// Success state when wallet is loaded
class WalletLoaded extends WalletState {
  final WalletModel wallet;

  const WalletLoaded(this.wallet);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WalletLoaded && other.wallet == wallet;
  }

  @override
  int get hashCode => wallet.hashCode;
}

/// Error state when an operation fails
class WalletError extends WalletState {
  final String message;
  final Exception? exception;

  const WalletError(this.message, {this.exception});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WalletError &&
           other.message == message &&
           other.exception == exception;
  }

  @override
  int get hashCode => message.hashCode ^ exception.hashCode;
}

/// Success state when wallet is updated
class WalletUpdated extends WalletState {
  final WalletModel wallet;
  final String message;

  const WalletUpdated(this.wallet, {this.message = 'Wallet updated successfully'});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WalletUpdated &&
           other.wallet == wallet &&
           other.message == message;
  }

  @override
  int get hashCode => wallet.hashCode ^ message.hashCode;
}
