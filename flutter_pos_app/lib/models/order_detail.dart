import 'dart:convert';

class OrderDetail {
  final String? id;
  final String orderId;
  final String productId;
  final int quantity;
  final double unitPrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderDetail({
    this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  OrderDetail copyWith({
    String? id,
    String? orderId,
    String? productId,
    int? quantity,
    double? unitPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderDetail(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory OrderDetail.fromMap(Map<String, dynamic> map) {
    return OrderDetail(
      id: map['id'],
      orderId: map['order_id'] ?? '',
      productId: map['product_id'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
      unitPrice: map['unit_price']?.toDouble() ?? 0.0,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderDetail.fromJson(String source) => OrderDetail.fromMap(json.decode(source));

  @override
  String toString() {
    return 'OrderDetail(id: $id, orderId: $orderId, productId: $productId, quantity: $quantity, unitPrice: $unitPrice, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is OrderDetail &&
        other.id == id &&
        other.orderId == orderId &&
        other.productId == productId &&
        other.quantity == quantity &&
        other.unitPrice == unitPrice &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      orderId,
      productId,
      quantity,
      unitPrice,
      createdAt,
      updatedAt,
    );
  }
}