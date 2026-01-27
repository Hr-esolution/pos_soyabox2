import 'package:get/get.dart';
import '../models/product.dart';

class CartController extends GetxController {
  final RxList<Product> _items = <Product>[].obs;
  final RxDouble _total = 0.0.obs;

  List<Product> get items => _items.toList();
  double get total => _total.value;

  @override
  void onInit() {
    super.onInit();
    _calculateTotal();
  }

  void addToCart(Product product) {
    _items.add(product);
    _calculateTotal();
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      _calculateTotal();
    }
  }

  void clearCart() {
    _items.clear();
    _calculateTotal();
  }

  void _calculateTotal() {
    _total.value = _items.fold(0.0, (sum, item) => sum + item.price);
  }
}