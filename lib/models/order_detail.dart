class OrderDetail {
  final int? id;
  final int orderId;
  final int productId;
  final int quantity;
  final double unitPrice;

  OrderDetail({
    this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      unitPrice: (json['unit_price'] is int) ? (json['unit_price'] as int).toDouble() : json['unit_price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }
}