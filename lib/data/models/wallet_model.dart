class WalletModel {
  final int? id;
  final int userId;
  final double ecoPoints;
  final double rupiahValue;
  final DateTime updatedAt;

  WalletModel({
    this.id,
    required this.userId,
    this.ecoPoints = 0.0,
    this.rupiahValue = 0.0,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  // Convert from Map to WalletModel
  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      ecoPoints: (map['eco_points'] as num?)?.toDouble() ?? 0.0,
      rupiahValue: (map['rupiah_value'] as num?)?.toDouble() ?? 0.0,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Convert from WalletModel to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'eco_points': ecoPoints,
      'rupiah_value': rupiahValue,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // CopyWith method
  WalletModel copyWith({
    int? id,
    int? userId,
    double? ecoPoints,
    double? rupiahValue,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      ecoPoints: ecoPoints ?? this.ecoPoints,
      rupiahValue: rupiahValue ?? this.rupiahValue,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Add points
  WalletModel addPoints(double points) {
    return copyWith(
      ecoPoints: ecoPoints + points,
      updatedAt: DateTime.now(),
    );
  }

  // Deduct points
  WalletModel deductPoints(double points) {
    return copyWith(
      ecoPoints: ecoPoints - points,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'WalletModel(userId: $userId, ecoPoints: $ecoPoints, rupiah: $rupiahValue)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WalletModel &&
        other.userId == userId &&
        other.ecoPoints == ecoPoints;
  }

  @override
  int get hashCode {
    return userId.hashCode ^ ecoPoints.hashCode;
  }
}
