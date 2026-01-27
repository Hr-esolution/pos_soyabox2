import 'dart:convert';

class Order {
  final String? id;
  final String? userId;
  final String? restaurantId;
  final String channel;
  final String? customerName;
  final String? customerPhone;
  final String fulfillmentType;
  final String status;
  final double totalPrice;
  final String paymentMethod;
  final String paymentStatus;
  final String? deliveryAddress;
  final String? tableNumber;
  final String? note;
  final String? qrCode;
  final String? rewardId;
  final double originalTotal;
  final double discountAmount;
  final bool hasDiscount;
  final DateTime createdAt;
  final DateTime updatedAt;

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
    required this.paymentMethod,
    required this.paymentStatus,
    this.deliveryAddress,
    this.tableNumber,
    this.note,
    this.qrCode,
    this.rewardId,
    required this.originalTotal,
    required this.discountAmount,
    required this.hasDiscount,
    required this.createdAt,
    required this.updatedAt,
  });

  Order copyWith({
    String? id,
    String? userId,
    String? restaurantId,
    String? channel,
    String? customerName,
    String? customerPhone,
    String? fulfillmentType,
    String? status,
    double? totalPrice,
    String? paymentMethod,
    String? paymentStatus,
    String? deliveryAddress,
    String? tableNumber,
    String? note,
    String? qrCode,
    String? rewardId,
    double? originalTotal,
    double? discountAmount,
    bool? hasDiscount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      channel: channel ?? this.channel,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      fulfillmentType: fulfillmentType ?? this.fulfillmentType,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      tableNumber: tableNumber ?? this.tableNumber,
      note: note ?? this.note,
      qrCode: qrCode ?? this.qrCode,
      rewardId: rewardId ?? this.rewardId,
      originalTotal: originalTotal ?? this.originalTotal,
      discountAmount: discountAmount ?? this.discountAmount,
      hasDiscount: hasDiscount ?? this.hasDiscount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
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
      'reward_id': rewardId,
      'original_total': originalTotal,
      'discount_amount': discountAmount,
      'has_discount': hasDiscount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      userId: map['user_id'],
      restaurantId: map['restaurant_id'],
      channel: map['channel'] ?? 'pos',
      customerName: map['customer_name'],
      customerPhone: map['customer_phone'],
      fulfillmentType: map['fulfillment_type'] ?? 'on_site',
      status: map['status'] ?? 'pending',
      totalPrice: map['total_price']?.toDouble() ?? 0.0,
      paymentMethod: map['payment_method'] ?? 'cash',
      paymentStatus: map['payment_status'] ?? 'pending',
      deliveryAddress: map['delivery_address'],
      tableNumber: map['table_number'],
      note: map['note'],
      qrCode: map['qr_code'],
      rewardId: map['reward_id'],
      originalTotal: map['original_total']?.toDouble() ?? 0.0,
      discountAmount: map['discount_amount']?.toDouble() ?? 0.0,
      hasDiscount: map['has_discount'] ?? false,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Order(id: $id, userId: $userId, restaurantId: $restaurantId, channel: $channel, customerName: $customerName, customerPhone: $customerPhone, fulfillmentType: $fulfillmentType, status: $status, totalPrice: $totalPrice, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, deliveryAddress: $deliveryAddress, tableNumber: $tableNumber, note: $note, qrCode: $qrCode, rewardId: $rewardId, originalTotal: $originalTotal, discountAmount: $discountAmount, hasDiscount: $hasDiscount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Order &&
        other.id == id &&
        other.userId == userId &&
        other.restaurantId == restaurantId &&
        other.channel == channel &&
        other.customerName == customerName &&
        other.customerPhone == customerPhone &&
        other.fulfillmentType == fulfillmentType &&
        other.status == status &&
        other.totalPrice == totalPrice &&
        other.paymentMethod == paymentMethod &&
        other.paymentStatus == paymentStatus &&
        other.deliveryAddress == deliveryAddress &&
        other.tableNumber == tableNumber &&
        other.note == note &&
        other.qrCode == qrCode &&
        other.rewardId == rewardId &&
        other.originalTotal == originalTotal &&
        other.discountAmount == discountAmount &&
        other.hasDiscount == hasDiscount &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      restaurantId,
      channel,
      customerName,
      customerPhone,
      fulfillmentType,
      status,
      totalPrice,
      paymentMethod,
      paymentStatus,
      deliveryAddress,
      tableNumber,
      note,
      qrCode,
      rewardId,
      originalTotal,
      discountAmount,
      hasDiscount,
      createdAt,
      updatedAt,
    );
  }
}