import '../data/models/cart_item_model.dart';

/// Base class for all cart states
abstract class CartState {
  const CartState();
}

/// Initial state when no action has been performed
class CartInitial extends CartState {
  const CartInitial();
}

/// Loading state while performing operations
class CartLoading extends CartState {
  const CartLoading();
}

/// Success state when cart is loaded
class CartLoaded extends CartState {
  final List<CartItemModel> items;
  final double totalPrice;
  final int totalItems;

  const CartLoaded(this.items, this.totalPrice, this.totalItems);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CartLoaded &&
           other.items.length == items.length &&
           _listEquals(other.items, items) &&
           other.totalPrice == totalPrice &&
           other.totalItems == totalItems;
  }

  bool _listEquals(List<CartItemModel> list1, List<CartItemModel> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => items.hashCode ^ totalPrice.hashCode ^ totalItems.hashCode;
}

/// Error state when an operation fails
class CartError extends CartState {
  final String message;
  final Exception? exception;

  const CartError(this.message, {this.exception});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CartError &&
           other.message == message &&
           other.exception == exception;
  }

  @override
  int get hashCode => message.hashCode ^ exception.hashCode;
}

/// Empty state when cart is empty
class CartEmpty extends CartState {
  final String message;

  const CartEmpty({this.message = 'Cart is empty'});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CartEmpty && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}
