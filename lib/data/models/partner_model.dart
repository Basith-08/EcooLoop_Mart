import '../../core/database/db_config.dart';

class PartnerModel {
  final int? id;
  final String type; // 'pengrajin' | 'grosir'
  final String name;
  final String? location;
  final String? tag;
  final String? subtitle;
  final String? area;
  final String? detail;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  PartnerModel({
    this.id,
    required this.type,
    required this.name,
    this.location,
    this.tag,
    this.subtitle,
    this.area,
    this.detail,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory PartnerModel.fromMap(Map<String, dynamic> map) {
    return PartnerModel(
      id: map[DBConfig.columnId] as int?,
      type: map['type'] as String,
      name: map['name'] as String,
      location: map['location'] as String?,
      tag: map['tag'] as String?,
      subtitle: map['subtitle'] as String?,
      area: map['area'] as String?,
      detail: map['detail'] as String?,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(map[DBConfig.columnCreatedAt] as String),
      updatedAt: DateTime.parse(map[DBConfig.columnUpdatedAt] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DBConfig.columnId: id,
      'type': type,
      'name': name,
      'location': location,
      'tag': tag,
      'subtitle': subtitle,
      'area': area,
      'detail': detail,
      'is_active': isActive ? 1 : 0,
      DBConfig.columnCreatedAt: createdAt.toIso8601String(),
      DBConfig.columnUpdatedAt: updatedAt.toIso8601String(),
    };
  }

  PartnerModel copyWith({
    int? id,
    String? type,
    String? name,
    String? location,
    String? tag,
    String? subtitle,
    String? area,
    String? detail,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PartnerModel(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      location: location ?? this.location,
      tag: tag ?? this.tag,
      subtitle: subtitle ?? this.subtitle,
      area: area ?? this.area,
      detail: detail ?? this.detail,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
