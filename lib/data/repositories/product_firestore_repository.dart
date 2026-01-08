import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

/// Product repository using Firebase Firestore for cloud-based data storage
class ProductFirestoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'products';

  // Get collection reference
  CollectionReference get _productsCollection =>
      _firestore.collection(collectionName);

  // Convert Firestore document to ProductModel
  ProductModel _documentToProduct(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel.fromMap({
      ...data,
      'id': int.tryParse(doc.id) ?? 0,
    });
  }

  // Create - Insert new product
  Future<String> insertProduct(ProductModel product) async {
    try {
      final docRef = await _productsCollection.add({
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'stock': product.stock,
        'image_url': product.imageUrl,
        'category': product.category,
        'is_eco_friendly': product.isEcoFriendly,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to insert product: $e');
    }
  }

  // Read - Get all products with real-time updates
  Stream<List<ProductModel>> getAllProductsStream() {
    return _productsCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _documentToProduct(doc))
            .toList());
  }

  // Read - Get all products (one-time fetch)
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final querySnapshot = await _productsCollection
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToProduct(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  // Read - Get available products (stock > 0)
  Future<List<ProductModel>> getAvailableProducts() async {
    try {
      final querySnapshot = await _productsCollection
          .where('stock', isGreaterThan: 0)
          .orderBy('stock', descending: false)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToProduct(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get available products: $e');
    }
  }

  // Read - Get product by document ID
  Future<ProductModel?> getProductByDocId(String docId) async {
    try {
      final docSnapshot = await _productsCollection.doc(docId).get();

      if (!docSnapshot.exists) return null;
      return _documentToProduct(docSnapshot);
    } catch (e) {
      throw Exception('Failed to get product by ID: $e');
    }
  }

  // Read - Get products by category
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final querySnapshot = await _productsCollection
          .where('category', isEqualTo: category)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToProduct(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get products by category: $e');
    }
  }

  // Read - Get products by category with stream
  Stream<List<ProductModel>> getProductsByCategoryStream(String category) {
    return _productsCollection
        .where('category', isEqualTo: category)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _documentToProduct(doc))
            .toList());
  }

  // Read - Get eco-friendly products
  Future<List<ProductModel>> getEcoFriendlyProducts() async {
    try {
      final querySnapshot = await _productsCollection
          .where('is_eco_friendly', isEqualTo: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToProduct(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get eco-friendly products: $e');
    }
  }

  // Update - Update product
  Future<void> updateProduct(String docId, ProductModel product) async {
    try {
      await _productsCollection.doc(docId).update({
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'stock': product.stock,
        'image_url': product.imageUrl,
        'category': product.category,
        'is_eco_friendly': product.isEcoFriendly,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // Update - Update stock
  Future<void> updateStock(String docId, int newStock) async {
    try {
      await _productsCollection.doc(docId).update({
        'stock': newStock,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update stock: $e');
    }
  }

  // Update - Decrease stock using transaction (atomic operation)
  Future<void> decreaseStock(String docId, int quantity) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(_productsCollection.doc(docId));

        if (!docSnapshot.exists) {
          throw Exception('Product not found');
        }

        final currentStock = (docSnapshot.data() as Map<String, dynamic>)['stock'] as int;

        if (currentStock < quantity) {
          throw Exception('Insufficient stock');
        }

        final newStock = currentStock - quantity;

        transaction.update(_productsCollection.doc(docId), {
          'stock': newStock,
          'updated_at': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to decrease stock: $e');
    }
  }

  // Update - Increase stock using transaction
  Future<void> increaseStock(String docId, int quantity) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(_productsCollection.doc(docId));

        if (!docSnapshot.exists) {
          throw Exception('Product not found');
        }

        final currentStock = (docSnapshot.data() as Map<String, dynamic>)['stock'] as int;
        final newStock = currentStock + quantity;

        transaction.update(_productsCollection.doc(docId), {
          'stock': newStock,
          'updated_at': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to increase stock: $e');
    }
  }

  // Delete - Delete product by document ID
  Future<void> deleteProduct(String docId) async {
    try {
      await _productsCollection.doc(docId).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Search products by name
  Future<List<ProductModel>> searchProductsByName(String name) async {
    try {
      final querySnapshot = await _productsCollection
          .where('name', isGreaterThanOrEqualTo: name)
          .where('name', isLessThanOrEqualTo: '$name\uf8ff')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToProduct(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  // Get total product count
  Future<int> getProductCount() async {
    try {
      final querySnapshot = await _productsCollection.count().get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get product count: $e');
    }
  }

  // Batch operations - Create multiple products
  Future<void> batchCreateProducts(List<ProductModel> products) async {
    try {
      final batch = _firestore.batch();

      for (var product in products) {
        final docRef = _productsCollection.doc();
        batch.set(docRef, {
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'stock': product.stock,
          'image_url': product.imageUrl,
          'category': product.category,
          'is_eco_friendly': product.isEcoFriendly,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch create products: $e');
    }
  }
}
