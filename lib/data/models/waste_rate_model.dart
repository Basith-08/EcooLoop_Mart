import '../../core/database/db_config.dart';

class WasteRateModel {
  final int? id;
  final String name;
  final double rupiahPerKg;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  WasteRateModel({
    this.id,
    required this.name,
    required this.rupiahPerKg,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory WasteRateModel.fromMap(Map<String, dynamic> map) {
    return WasteRateModel(
      id: map[DBConfig.columnId] as int?,
      name: map['name'] as String,
      rupiahPerKg: (map['rupiah_per_kg'] as num).toDouble(),
      isActive: (map['is_active'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(map[DBConfig.columnCreatedAt] as String),
      updatedAt: DateTime.parse(map[DBConfig.columnUpdatedAt] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DBConfig.columnId: id,
      'name': name,
      'rupiah_per_kg': rupiahPerKg,
      'is_active': isActive ? 1 : 0,
      DBConfig.columnCreatedAt: createdAt.toIso8601String(),
      DBConfig.columnUpdatedAt: updatedAt.toIso8601String(),
    };
  }

  WasteRateModel copyWith({
    int? id,
    String? name,
    double? rupiahPerKg,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WasteRateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      rupiahPerKg: rupiahPerKg ?? this.rupiahPerKg,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

