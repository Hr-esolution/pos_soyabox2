import 'package:flutter/foundation.dart';
import 'order_detail.dart';

class Order {
  final int? id;
  final int userId;
  final int restaurantId;
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
  final int? rewardId;
  final double originalTotal;
  final double discountAmount;
  final bool hasDiscount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderDetail>? details;

  Order({
    this.id,
    required this.userId,
    required this.restaurantId,
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
    this.details,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      restaurantId: json['restaurant_id'],
      channel: json['channel'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      fulfillmentType: json['fulfillment_type'],
      status: json['status'],
      totalPrice: (json['total_price'] is int) ? (json['total_price'] as int).toDouble() : json['total_price'].toDouble(),
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      deliveryAddress: json['delivery_address'],
      tableNumber: json['table_number'],
      note: json['note'],
      qrCode: json['qr_code'],
      rewardId: json['reward_id'],
      originalTotal: (json['original_total'] is int) ? (json['original_total'] as int).toDouble() : json['original_total'].toDouble(),
      discountAmount: (json['discount_amount'] is int) ? (json['discount_amount'] as int).toDouble() : json['discount_amount'].toDouble(),
      hasDiscount: json['has_discount'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      details: json['details'] != null
          ? (json['details'] as List).map((e) => OrderDetail.fromJson(e)).toList()
          : null,
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
      'reward_id': rewardId,
      'original_total': originalTotal,
      'discount_amount': discountAmount,
      'has_discount': hasDiscount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'details': details?.map((e) => e.toJson()).toList(),
    };
  }
}