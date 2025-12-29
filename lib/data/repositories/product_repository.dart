import 'package:sqflite/sqflite.dart';
import '../../core/database/db_helper.dart';
import '../../core/database/db_config.dart';
import '../models/product_model.dart';

class ProductRepository {
  final DBHelper _dbHelper = DBHelper();

  // Create - Insert new product
  Future<int> insertProduct(ProductModel product) async {
    try {
      final db = await _dbHelper.database;
      return await db.insert(
        DBConfig.productTable,
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to insert product: $e');
    }
  }

  // Read - Get all products
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.productTable,
        orderBy: 'created_at DESC',
      );

      return List.generate(maps.length, (i) {
        return ProductModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  // Read - Get available products (stock > 0)
  Future<List<ProductModel>> getAvailableProducts() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.productTable,
        where: 'stock > ?',
        whereArgs: [0],
        orderBy: 'name ASC',
      );

      return List.generate(maps.length, (i) {
        return ProductModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get available products: $e');
    }
  }

  // Read - Get product by ID
  Future<ProductModel?> getProductById(int id) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.productTable,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return ProductModel.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to get product by ID: $e');
    }
  }

  // Read - Get products by category
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.productTable,
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'name ASC',
      );

      return List.generate(maps.length, (i) {
        return ProductModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get products by category: $e');
    }
  }

  // Update - Update product
  Future<int> updateProduct(ProductModel product) async {
    try {
      final db = await _dbHelper.database;
      final updatedProduct = product.copyWith(updatedAt: DateTime.now());

      return await db.update(
        DBConfig.productTable,
        updatedProduct.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // Update stock
  Future<int> updateStock(int productId, int newStock) async {
    try {
      final db = await _dbHelper.database;
      return await db.update(
        DBConfig.productTable,
        {
          'stock': newStock,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [productId],
      );
    } catch (e) {
      throw Exception('Failed to update stock: $e');
    }
  }

  // Decrease stock (for purchase)
  Future<bool> decreaseStock(int productId, int quantity) async {
    try {
      final product = await getProductById(productId);
      if (product == null) return false;

      if (product.stock < quantity) {
        throw Exception('Insufficient stock');
      }

      final newStock = product.stock - quantity;
      await updateStock(productId, newStock);
      return true;
    } catch (e) {
      throw Exception('Failed to decrease stock: $e');
    }
  }

  // Increase stock (for restocking)
  Future<bool> increaseStock(int productId, int quantity) async {
    try {
      final product = await getProductById(productId);
      if (product == null) return false;

      final newStock = product.stock + quantity;
      await updateStock(productId, newStock);
      return true;
    } catch (e) {
      throw Exception('Failed to increase stock: $e');
    }
  }

  // Delete - Delete product by ID
  Future<int> deleteProduct(int id) async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(
        DBConfig.productTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Search products by name
  Future<List<ProductModel>> searchProductsByName(String name) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.productTable,
        where: 'name LIKE ?',
        whereArgs: ['%$name%'],
        orderBy: 'name ASC',
      );

      return List.generate(maps.length, (i) {
        return ProductModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  // Get total product count
  Future<int> getProductCount() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DBConfig.productTable}'
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Failed to get product count: $e');
    }
  }
}
