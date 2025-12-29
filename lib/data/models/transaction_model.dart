class TransactionModel {
  final int? id;
  final int userId;
  final int? productId; // null for deposit transactions
  final double quantity; // kg for deposit, item count for purchase
  final double totalPrice; // points
  final DateTime transactionDate;
  final String status; // 'completed', 'pending', 'cancelled'
  final String type; // 'deposit' (setor sampah) or 'purchase' (tukar barang)
  final String? wasteType; // for deposit: 'Kardus Bekas', 'Botol Plastik', etc.
  final String? productName; // for purchase

  TransactionModel({
    this.id,
    required this.userId,
    this.productId,
    required this.quantity,
    required this.totalPrice,
    DateTime? transactionDate,
    this.status = 'completed',
    required this.type,
    this.wasteType,
    this.productName,
  }) : transactionDate = transactionDate ?? DateTime.now();

  // Convert from Map to TransactionModel
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      productId: map['product_id'] as int?,
      quantity: (map['quantity'] as num).toDouble(),
      totalPrice: (map['total_price'] as num).toDouble(),
      transactionDate: DateTime.parse(map['transaction_date'] as String),
      status: map['status'] as String? ?? 'completed',
      type: map['type'] as String,
      wasteType: map['waste_type'] as String?,
      productName: map['product_name'] as String?,
    );
  }

  // Convert from TransactionModel to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'total_price': totalPrice,
      'transaction_date': transactionDate.toIso8601String(),
      'status': status,
      'type': type,
      'waste_type': wasteType,
      'product_name': productName,
    };
  }

  // CopyWith method
  TransactionModel copyWith({
    int? id,
    int? userId,
    int? productId,
    double? quantity,
    double? totalPrice,
    DateTime? transactionDate,
    String? status,
    String? type,
    String? wasteType,
    String? productName,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      transactionDate: transactionDate ?? this.transactionDate,
      status: status ?? this.status,
      type: type ?? this.type,
      wasteType: wasteType ?? this.wasteType,
      productName: productName ?? this.productName,
    );
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, userId: $userId, type: $type, totalPrice: $totalPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionModel &&
        other.id == id &&
        other.userId == userId &&
        other.type == type &&
        other.totalPrice == totalPrice;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ type.hashCode ^ totalPrice.hashCode;
  }
}
