import '../../core/database/db_config.dart';

class UserModel {
  final int? id;
  final String name;
  final String username;
  final String password;
  final String role; // 'admin' or 'warga'
  final String? email;
  final String? phone;
  final double ecoPoints;
  final String status; // 'active' or 'inactive'
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    this.id,
    required this.name,
    required this.username,
    required this.password,
    this.role = 'warga',
    this.email,
    this.phone,
    this.ecoPoints = 0.0,
    this.status = 'active',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert from Map to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map[DBConfig.columnId] as int?,
      name: map[DBConfig.columnName] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      role: map['role'] as String? ?? 'warga',
      email: map[DBConfig.columnEmail] as String?,
      phone: map[DBConfig.columnPhone] as String?,
      ecoPoints: (map['eco_points'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'active',
      createdAt: DateTime.parse(map[DBConfig.columnCreatedAt] as String),
      updatedAt: DateTime.parse(map[DBConfig.columnUpdatedAt] as String),
    );
  }

  // Convert from UserModel to Map
  Map<String, dynamic> toMap() {
    return {
      DBConfig.columnId: id,
      DBConfig.columnName: name,
      'username': username,
      'password': password,
      'role': role,
      DBConfig.columnEmail: email,
      DBConfig.columnPhone: phone,
      'eco_points': ecoPoints,
      'status': status,
      DBConfig.columnCreatedAt: createdAt.toIso8601String(),
      DBConfig.columnUpdatedAt: updatedAt.toIso8601String(),
    };
  }

  // CopyWith method for updating
  UserModel copyWith({
    int? id,
    String? name,
    String? username,
    String? password,
    String? role,
    String? email,
    String? phone,
    double? ecoPoints,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      ecoPoints: ecoPoints ?? this.ecoPoints,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, username: $username, role: $role, points: $ecoPoints)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.username == username;
  }

  @override
  int get hashCode {
    return id.hashCode ^ username.hashCode;
  }

  // Helper methods
  bool get isAdmin => role == 'admin';
  bool get isWarga => role == 'warga';
  bool get isActive => status == 'active';
}
