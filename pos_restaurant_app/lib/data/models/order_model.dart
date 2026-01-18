class Order {
  final int? id;
  final int? userId;
  final int? restaurantId;
  final String channel;
  final String? customerName;
  final String? customerPhone;
  final String fulfillmentType; // 'surplace', 'emporter', 'livraison'
  final String status;
  final double totalPrice;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? deliveryAddress;
  final String? tableNumber;
  final String? note;
  final String? qrCode;
  final List<OrderItem> items;

  Order({
    this.id,
    this.userId,
    this.restaurantId,
    required this.channel,
    this.customerName,
    this.customerPhone,
    required this.fulfillmentType,
    required this.status,
    required this.totalPrice,
    this.paymentMethod,
    this.paymentStatus,
    this.deliveryAddress,
    this.tableNumber,
    this.note,
    this.qrCode,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> items = [];
    if (json['items'] != null) {
      if (json['items'] is List) {
        items = (json['items'] as List).map((item) => OrderItem.fromJson(item)).toList();
      }
    }

    return Order(
      id: json['id'],
      userId: json['user_id'],
      restaurantId: json['restaurant_id'],
      channel: json['channel'] ?? 'pos',
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      fulfillmentType: json['fulfillment_type'] ?? 'surplace',
      status: json['status'] ?? 'pending',
      totalPrice: (json['total_price'] is int) 
          ? (json['total_price'] as int).toDouble() 
          : (json['total_price'] as double?) ?? 0.0,
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      deliveryAddress: json['delivery_address'],
      tableNumber: json['table_number'],
      note: json['note'],
      qrCode: json['qr_code'],
      items: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'restaurant_id': restaurantId,
      'channel': channel,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'fulfillment_type': fulfillmentType,
      'status': status,
      'total_price': totalPrice,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'delivery_address': deliveryAddress,
      'table_number': tableNumber,
      'note': note,
      'qr_code': qrCode,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderItem {
  final int productId;
  final int quantity;
  final double unitPrice;

  OrderItem({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unit_price'] is int) 
          ? (json['unit_price'] as int).toDouble() 
          : (json['unit_price'] as double?) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }
}