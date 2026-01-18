enum FulfillmentType { surplace, emporter, livraison }

class OrderItem {
  final int productId;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
    };
  }
}

class Order {
  final String fulfillmentType;
  final String? tableNumber;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final List<OrderItem> items;

  Order({
    required this.fulfillmentType,
    this.tableNumber,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<dynamic> itemsJson = json['items'] ?? [];
    List<OrderItem> items = itemsJson.map((item) => OrderItem.fromJson(item)).toList();

    return Order(
      fulfillmentType: json['fulfillment_type'] ?? 'surplace',
      tableNumber: json['table_number'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      customerAddress: json['customer_address'],
      items: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fulfillment_type': fulfillmentType,
      'table_number': tableNumber,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_address': customerAddress,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}