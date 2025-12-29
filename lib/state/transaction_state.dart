import '../data/models/transaction_model.dart';

/// Base class for all transaction states
abstract class TransactionState {
  const TransactionState();
}

/// Initial state when no action has been performed
class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

/// Loading state while performing operations
class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

/// Success state when transactions are loaded
class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;

  const TransactionLoaded(this.transactions);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionLoaded &&
           other.transactions.length == transactions.length &&
           _listEquals(other.transactions, transactions);
  }

  bool _listEquals(List<TransactionModel> list1, List<TransactionModel> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => transactions.hashCode;
}

/// Error state when an operation fails
class TransactionError extends TransactionState {
  final String message;
  final Exception? exception;

  const TransactionError(this.message, {this.exception});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionError &&
           other.message == message &&
           other.exception == exception;
  }

  @override
  int get hashCode => message.hashCode ^ exception.hashCode;
}

/// Empty state when no transactions found
class TransactionEmpty extends TransactionState {
  final String message;

  const TransactionEmpty({this.message = 'No transactions found'});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionEmpty && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

/// Success state when transaction is created
class TransactionCreated extends TransactionState {
  final TransactionModel transaction;
  final String message;

  const TransactionCreated(this.transaction, {this.message = 'Transaction created successfully'});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionCreated &&
           other.transaction == transaction &&
           other.message == message;
  }

  @override
  int get hashCode => transaction.hashCode ^ message.hashCode;
}
