import 'package:isar/isar.dart';

part 'cart_item.g.dart';

@embedded
class CartItem {
  late int productId;
  late int quantity;
  late double unitPrice;

  CartItem({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });
}