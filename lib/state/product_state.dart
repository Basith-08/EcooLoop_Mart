import '../data/models/product_model.dart';

/// Base class for all product states
abstract class ProductState {
  const ProductState();
}

/// Initial state when no action has been performed
class ProductInitial extends ProductState {
  const ProductInitial();
}

/// Loading state while performing operations
class ProductLoading extends ProductState {
  const ProductLoading();
}

/// Success state when products are loaded
class ProductLoaded extends ProductState {
  final List<ProductModel> products;

  const ProductLoaded(this.products);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductLoaded &&
           other.products.length == products.length &&
           _listEquals(other.products, products);
  }

  bool _listEquals(List<ProductModel> list1, List<ProductModel> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => products.hashCode;
}

/// Error state when an operation fails
class ProductError extends ProductState {
  final String message;
  final Exception? exception;

  const ProductError(this.message, {this.exception});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductError &&
           other.message == message &&
           other.exception == exception;
  }

  @override
  int get hashCode => message.hashCode ^ exception.hashCode;
}

/// Empty state when no products found
class ProductEmpty extends ProductState {
  final String message;

  const ProductEmpty({this.message = 'No products found'});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductEmpty && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

/// Success state when product is created
class ProductCreated extends ProductState {
  final ProductModel product;
  final String message;

  const ProductCreated(this.product, {this.message = 'Product created successfully'});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductCreated &&
           other.product == product &&
           other.message == message;
  }

  @override
  int get hashCode => product.hashCode ^ message.hashCode;
}

/// Success state when product is updated
class ProductUpdated extends ProductState {
  final ProductModel product;
  final String message;

  const ProductUpdated(this.product, {this.message = 'Product updated successfully'});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductUpdated &&
           other.product == product &&
           other.message == message;
  }

  @override
  int get hashCode => product.hashCode ^ message.hashCode;
}

/// Success state when product is deleted
class ProductDeleted extends ProductState {
  final String message;

  const ProductDeleted({this.message = 'Product deleted successfully'});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductDeleted && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}
