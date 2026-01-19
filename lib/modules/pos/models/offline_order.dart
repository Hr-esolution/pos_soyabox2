import 'package:isar/isar.dart';
import 'cart_item.dart';
import 'package:uuid/uuid.dart';

part 'offline_order.g.dart';

@collection
class OfflineOrder {
  Id? id;
  
  late String uuid;
  late String fulfillmentType; // 'on_site', 'pickup', 'delivery'
  String? tableNumber;
  String? customerName;
  String? customerPhone;
  String? deliveryAddress;
  List<CartItem> items = [];
  bool isSynced = false;
  DateTime createdAt;

  OfflineOrder({
    this.id,
    String? uuid,
    required this.fulfillmentType,
    this.tableNumber,
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    this.items = const [],
    this.isSynced = false,
  }) : this.uuid = uuid ?? Uuid().v4(),
       this.createdAt = DateTime.now();
}