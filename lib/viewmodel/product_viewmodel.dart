import 'package:flutter/foundation.dart';
import '../data/models/product_model.dart';
import '../data/repositories/product_hybrid_repository.dart';
import '../state/product_state.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductHybridRepository _repository;
  ProductState _state = const ProductInitial();

  ProductViewModel(this._repository);

  ProductState get state => _state;

  void _setState(ProductState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Load all products from database
  Future<void> loadProducts() async {
    try {
      _setState(const ProductLoading());

      final products = await _repository.getAllProducts();

      if (products.isEmpty) {
        _setState(const ProductEmpty());
      } else {
        _setState(ProductLoaded(products));
      }
    } catch (e) {
      _setState(ProductError(
        'Failed to load products',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Create new product
  Future<void> createProduct({
    required String name,
    String? description,
    required double price,
    required int stock,
    String? imageUrl,
    String category = 'general',
    bool isEcoFriendly = false,
  }) async {
    try {
      _setState(const ProductLoading());

      // Validate inputs
      if (name.trim().isEmpty) {
        _setState(const ProductError('Product name is required'));
        return;
      }

      if (price <= 0) {
        _setState(const ProductError('Price must be greater than zero'));
        return;
      }

      if (stock < 0) {
        _setState(const ProductError('Stock cannot be negative'));
        return;
      }

      final product = ProductModel(
        name: name,
        description: description,
        price: price,
        stock: stock,
        imageUrl: imageUrl,
        category: category,
        isEcoFriendly: isEcoFriendly,
      );

      final id = await _repository.insertProduct(product);
      final createdProduct = product.copyWith(id: id);

      _setState(ProductCreated(createdProduct));

      // Reload products to update the list
      await loadProducts();
    } catch (e) {
      _setState(ProductError(
        'Failed to create product',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Update existing product
  Future<void> updateProduct(ProductModel product) async {
    try {
      _setState(const ProductLoading());

      if (product.id == null) {
        _setState(const ProductError('Product ID is required for update'));
        return;
      }

      // Validate inputs
      if (product.name.trim().isEmpty) {
        _setState(const ProductError('Product name is required'));
        return;
      }

      if (product.price <= 0) {
        _setState(const ProductError('Price must be greater than zero'));
        return;
      }

      if (product.stock < 0) {
        _setState(const ProductError('Stock cannot be negative'));
        return;
      }

      final rowsAffected = await _repository.updateProduct(product);

      if (rowsAffected == 0) {
        _setState(const ProductError('Product not found or no changes made'));
      } else {
        _setState(ProductUpdated(product));

        // Reload products to update the list
        await loadProducts();
      }
    } catch (e) {
      _setState(ProductError(
        'Failed to update product',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Delete product by ID
  Future<void> deleteProduct(int id) async {
    try {
      _setState(const ProductLoading());

      final rowsAffected = await _repository.deleteProduct(id);

      if (rowsAffected == 0) {
        _setState(const ProductError('Product not found'));
      } else {
        _setState(const ProductDeleted());

        // Reload products to update the list
        await loadProducts();
      }
    } catch (e) {
      _setState(ProductError(
        'Failed to delete product',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Search products by name
  Future<void> searchProducts(String name) async {
    try {
      _setState(const ProductLoading());

      final products = await _repository.searchProductsByName(name);

      if (products.isEmpty) {
        _setState(const ProductEmpty(message: 'No products found matching the search'));
      } else {
        _setState(ProductLoaded(products));
      }
    } catch (e) {
      _setState(ProductError(
        'Failed to search products',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Update stock for a product
  Future<void> updateStock(int id, int stock) async {
    try {
      _setState(const ProductLoading());

      if (stock < 0) {
        _setState(const ProductError('Stock cannot be negative'));
        return;
      }

      final rowsAffected = await _repository.updateStock(id, stock);

      if (rowsAffected == 0) {
        _setState(const ProductError('Product not found'));
      } else {
        // Reload products to update the list
        await loadProducts();
      }
    } catch (e) {
      _setState(ProductError(
        'Failed to update stock',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Get available products (stock > 0)
  Future<void> loadAvailableProducts() async {
    try {
      _setState(const ProductLoading());

      final products = await _repository.getAvailableProducts();

      if (products.isEmpty) {
        _setState(const ProductEmpty(message: 'No available products'));
      } else {
        _setState(ProductLoaded(products));
      }
    } catch (e) {
      _setState(ProductError(
        'Failed to load available products',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Get products by category
  Future<void> loadProductsByCategory(String category) async {
    try {
      _setState(const ProductLoading());

      final products = await _repository.getProductsByCategory(category);

      if (products.isEmpty) {
        _setState(const ProductEmpty(message: 'No products found in this category'));
      } else {
        _setState(ProductLoaded(products));
      }
    } catch (e) {
      _setState(ProductError(
        'Failed to load products by category',
        exception: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  /// Reset state to initial
  void resetState() {
    _setState(const ProductInitial());
  }
}
