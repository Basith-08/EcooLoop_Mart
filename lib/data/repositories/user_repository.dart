import 'package:sqflite/sqflite.dart';
import '../../core/database/db_helper.dart';
import '../../core/database/db_config.dart';
import '../models/user_model.dart';

class UserRepository {
  final DBHelper _dbHelper = DBHelper();

  // Authentication - Register new user
  Future<int> register(UserModel user) async {
    try {
      final db = await _dbHelper.database;

      // Check if username already exists
      final existingUser = await getUserByUsername(user.username);
      if (existingUser != null) {
        throw Exception('Username already exists');
      }

      return await db.insert(
        DBConfig.userTable,
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  // Authentication - Login user
  Future<UserModel?> login(String username, String password) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.userTable,
        where: 'username = ? AND password = ?',
        whereArgs: [username, password],
        limit: 1,
      );

      if (maps.isEmpty) return null;

      final user = UserModel.fromMap(maps.first);

      // Check if user is active
      if (!user.isActive) {
        throw Exception('Account is inactive');
      }

      return user;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  // Create - Insert new user
  Future<int> insertUser(UserModel user) async {
    try {
      final db = await _dbHelper.database;
      return await db.insert(
        DBConfig.userTable,
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to insert user: $e');
    }
  }

  // Read - Get all users
  Future<List<UserModel>> getAllUsers() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.userTable,
        orderBy: '${DBConfig.columnCreatedAt} DESC',
      );

      return List.generate(maps.length, (i) {
        return UserModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  // Read - Get user by ID
  Future<UserModel?> getUserById(int id) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.userTable,
        where: '${DBConfig.columnId} = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return UserModel.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to get user by ID: $e');
    }
  }

  // Read - Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.userTable,
        where: '${DBConfig.columnEmail} = ?',
        whereArgs: [email],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return UserModel.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to get user by email: $e');
    }
  }

  // Read - Get user by username
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.userTable,
        where: 'username = ?',
        whereArgs: [username],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return UserModel.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to get user by username: $e');
    }
  }

  // Read - Get users by role
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.userTable,
        where: 'role = ?',
        whereArgs: [role],
        orderBy: '${DBConfig.columnName} ASC',
      );

      return List.generate(maps.length, (i) {
        return UserModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get users by role: $e');
    }
  }

  // Read - Get all admin users
  Future<List<UserModel>> getAllAdmins() async {
    return getUsersByRole('admin');
  }

  // Read - Get all warga users
  Future<List<UserModel>> getAllWarga() async {
    return getUsersByRole('warga');
  }

  // Read - Get active users
  Future<List<UserModel>> getActiveUsers() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.userTable,
        where: 'status = ?',
        whereArgs: ['active'],
        orderBy: '${DBConfig.columnName} ASC',
      );

      return List.generate(maps.length, (i) {
        return UserModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get active users: $e');
    }
  }

  // Read - Get inactive users
  Future<List<UserModel>> getInactiveUsers() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.userTable,
        where: 'status = ?',
        whereArgs: ['inactive'],
        orderBy: '${DBConfig.columnName} ASC',
      );

      return List.generate(maps.length, (i) {
        return UserModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get inactive users: $e');
    }
  }

  // Update - Update user
  Future<int> updateUser(UserModel user) async {
    try {
      final db = await _dbHelper.database;
      final updatedUser = user.copyWith(updatedAt: DateTime.now());

      return await db.update(
        DBConfig.userTable,
        updatedUser.toMap(),
        where: '${DBConfig.columnId} = ?',
        whereArgs: [user.id],
      );
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Update - Update user eco points
  Future<int> updateEcoPoints(int userId, double ecoPoints) async {
    try {
      final db = await _dbHelper.database;
      return await db.update(
        DBConfig.userTable,
        {
          'eco_points': ecoPoints,
          DBConfig.columnUpdatedAt: DateTime.now().toIso8601String(),
        },
        where: '${DBConfig.columnId} = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      throw Exception('Failed to update eco points: $e');
    }
  }

  // Update - Add eco points to user
  Future<bool> addEcoPoints(int userId, double points) async {
    try {
      final user = await getUserById(userId);
      if (user == null) return false;

      final newPoints = user.ecoPoints + points;
      await updateEcoPoints(userId, newPoints);
      return true;
    } catch (e) {
      throw Exception('Failed to add eco points: $e');
    }
  }

  // Update - Deduct eco points from user
  Future<bool> deductEcoPoints(int userId, double points) async {
    try {
      final user = await getUserById(userId);
      if (user == null) return false;

      if (user.ecoPoints < points) {
        throw Exception('Insufficient eco points');
      }

      final newPoints = user.ecoPoints - points;
      await updateEcoPoints(userId, newPoints);
      return true;
    } catch (e) {
      throw Exception('Failed to deduct eco points: $e');
    }
  }

  // Update - Update user status
  Future<int> updateUserStatus(int userId, String status) async {
    try {
      final db = await _dbHelper.database;
      return await db.update(
        DBConfig.userTable,
        {
          'status': status,
          DBConfig.columnUpdatedAt: DateTime.now().toIso8601String(),
        },
        where: '${DBConfig.columnId} = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }

  // Update - Activate user
  Future<int> activateUser(int userId) async {
    return updateUserStatus(userId, 'active');
  }

  // Update - Deactivate user
  Future<int> deactivateUser(int userId) async {
    return updateUserStatus(userId, 'inactive');
  }

  // Update - Change password
  Future<int> changePassword(int userId, String newPassword) async {
    try {
      final db = await _dbHelper.database;
      return await db.update(
        DBConfig.userTable,
        {
          'password': newPassword,
          DBConfig.columnUpdatedAt: DateTime.now().toIso8601String(),
        },
        where: '${DBConfig.columnId} = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // Update - Update user role
  Future<int> updateUserRole(int userId, String role) async {
    try {
      final db = await _dbHelper.database;
      return await db.update(
        DBConfig.userTable,
        {
          'role': role,
          DBConfig.columnUpdatedAt: DateTime.now().toIso8601String(),
        },
        where: '${DBConfig.columnId} = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  // Delete - Delete user by ID
  Future<int> deleteUser(int id) async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(
        DBConfig.userTable,
        where: '${DBConfig.columnId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Delete - Delete all users
  Future<int> deleteAllUsers() async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(DBConfig.userTable);
    } catch (e) {
      throw Exception('Failed to delete all users: $e');
    }
  }

  // Search users by name
  Future<List<UserModel>> searchUsersByName(String name) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DBConfig.userTable,
        where: '${DBConfig.columnName} LIKE ?',
        whereArgs: ['%$name%'],
        orderBy: '${DBConfig.columnName} ASC',
      );

      return List.generate(maps.length, (i) {
        return UserModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // Get total user count
  Future<int> getUserCount() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DBConfig.userTable}'
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Failed to get user count: $e');
    }
  }

  // Get user count by role
  Future<int> getUserCountByRole(String role) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DBConfig.userTable} WHERE role = ?',
        [role]
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Failed to get user count by role: $e');
    }
  }

  // Get active user count
  Future<int> getActiveUserCount() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DBConfig.userTable} WHERE status = ?',
        ['active']
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Failed to get active user count: $e');
    }
  }

  // Check if username exists
  Future<bool> usernameExists(String username) async {
    try {
      final user = await getUserByUsername(username);
      return user != null;
    } catch (e) {
      throw Exception('Failed to check username existence: $e');
    }
  }

  // Verify password for user
  Future<bool> verifyPassword(int userId, String password) async {
    try {
      final user = await getUserById(userId);
      if (user == null) return false;
      return user.password == password;
    } catch (e) {
      throw Exception('Failed to verify password: $e');
    }
  }

  // Get total eco points across all users
  Future<double> getTotalEcoPoints() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT SUM(eco_points) as total FROM ${DBConfig.userTable}'
      );

      final total = result.first['total'];
      return total != null ? (total as num).toDouble() : 0.0;
    } catch (e) {
      throw Exception('Failed to get total eco points: $e');
    }
  }
}
