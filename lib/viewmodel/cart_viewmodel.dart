import 'package:flutter/foundation.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/product_model.dart';
import '../state/cart_state.dart';

class CartViewModel extends ChangeNotifier {
  CartState _state = const CartInitial();
  final List<CartItemModel> _cartItems = [];

  CartViewModel();

  CartState get state => _state;
  List<CartItemModel> get cartItems => List.unmodifiable(_cartItems);

  void _setState(CartState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Calculate total price of all items in cart
  double get totalPrice {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Calculate total number of items in cart
  int get totalItems {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Add product to cart
  Future<void> addToCart(ProductModel product) async {
    try {
      // Check if product is already in cart
      final existingItemIndex = _cartItems.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (existingItemIndex != -1) {
        // Product exists, increment quantity
        final existingItem = _cartItems[existingItemIndex];

        // Check if we can add more (stock limit)
        if (existingItem.quantity >= product.stock) {
          _setState(const CartError('Cannot add more items than available stock'));
          return;
        }

        existingItem.incrementQuantity();
      } else {
        // Product doesn't exist, add new cart item
        if (product.stock <= 0) {
          _setState(const CartError('Product is out of stock'));
          return;
        }

        _cartItems.add(CartItemModel(
          product: product,
          quantity: 1,
        ));
      }

      _updateCartState();
    } catch (e) {
      _setState(CartError(
        'Failed to add to cart',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Remove product from cart by product ID
  Future<void> removeFromCart(int productId) async {
    try {
      _cartItems.removeWhere((item) => item.product.id == productId);
      _updateCartState();
    } catch (e) {
      _setState(CartError(
        'Failed to remove from cart',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Update quantity of a product in cart
  Future<void> updateQuantity(int productId, int quantity) async {
    try {
      if (quantity <= 0) {
        // Remove item if quantity is 0 or less
        await removeFromCart(productId);
        return;
      }

      final itemIndex = _cartItems.indexWhere(
        (item) => item.product.id == productId,
      );

      if (itemIndex == -1) {
        _setState(const CartError('Product not found in cart'));
        return;
      }

      final item = _cartItems[itemIndex];

      // Check stock availability
      if (quantity > item.product.stock) {
        _setState(const CartError('Quantity exceeds available stock'));
        return;
      }

      // Update quantity
      _cartItems[itemIndex] = item.copyWith(quantity: quantity);
      _updateCartState();
    } catch (e) {
      _setState(CartError(
        'Failed to update quantity',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Clear all items from cart
  Future<void> clearCart() async {
    try {
      _cartItems.clear();
      _setState(const CartEmpty(message: 'Cart cleared successfully'));
    } catch (e) {
      _setState(CartError(
        'Failed to clear cart',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Checkout - prepare cart for transaction
  Future<Map<String, dynamic>> checkout() async {
    try {
      if (_cartItems.isEmpty) {
        _setState(const CartError('Cart is empty'));
        return {};
      }

      // Validate all items have sufficient stock
      for (final item in _cartItems) {
        if (item.quantity > item.product.stock) {
          _setState(CartError(
            'Insufficient stock for ${item.product.name}',
          ));
          return {};
        }
      }

      // Prepare checkout data
      final checkoutData = {
        'items': _cartItems,
        'totalPrice': totalPrice,
        'totalItems': totalItems,
        'itemCount': _cartItems.length,
      };

      return checkoutData;
    } catch (e) {
      _setState(CartError(
        'Failed to checkout',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
      return {};
    }
  }

  /// Get cart item by product ID
  CartItemModel? getCartItem(int productId) {
    try {
      return _cartItems.firstWhere(
        (item) => item.product.id == productId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if product is in cart
  bool isInCart(int productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  /// Get quantity of a specific product in cart
  int getProductQuantity(int productId) {
    final item = getCartItem(productId);
    return item?.quantity ?? 0;
  }

  /// Update cart state based on current items
  void _updateCartState() {
    if (_cartItems.isEmpty) {
      _setState(const CartEmpty());
    } else {
      _setState(CartLoaded(_cartItems, totalPrice, totalItems));
    }
  }

  /// Reset state to initial
  void resetState() {
    _setState(const CartInitial());
  }
}
