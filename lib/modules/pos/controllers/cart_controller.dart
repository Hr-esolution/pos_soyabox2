import 'package:get/get.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartController extends GetxController {
  var items = <CartItem>[].obs;
  
  double get total {
    return items.fold(0, (sum, item) => sum + (item.unitPrice * item.quantity));
  }

  void addItem(Product product) {
    int existingIndex = -1;
    for (int i = 0; i < items.length; i++) {
      if (items[i].productId == product.id) {
        existingIndex = i;
        break;
      }
    }

    if (existingIndex != -1) {
      // Item already exists, increment quantity
      items[existingIndex] = CartItem(
        productId: items[existingIndex].productId,
        quantity: items[existingIndex].quantity + 1,
        unitPrice: items[existingIndex].unitPrice,
      );
    } else {
      // New item
      items.add(CartItem(
        productId: product.id!,
        quantity: 1,
        unitPrice: product.price,
      ));
    }
    update();
  }

  void updateQuantity(int index, int delta) {
    if (index >= 0 && index < items.length) {
      int newQuantity = items[index].quantity + delta;
      
      if (newQuantity <= 0) {
        items.removeAt(index);
      } else {
        items[index] = CartItem(
          productId: items[index].productId,
          quantity: newQuantity,
          unitPrice: items[index].unitPrice,
        );
      }
      update();
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < items.length) {
      items.removeAt(index);
      update();
    }
  }

  void clearCart() {
    items.clear();
    update();
  }

  Map<String, dynamic> getCartData() {
    return {
      'items': items.map((item) => {
        'product_id': item.productId,
        'quantity': item.quantity,
      }).toList(),
      'total': total,
    };
  }
}