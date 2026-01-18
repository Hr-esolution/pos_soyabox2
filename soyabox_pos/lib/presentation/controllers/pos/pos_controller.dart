import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/pos_repository.dart';
import '../../../core/utils/app_snackbar.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem(this.product, this.quantity);
  
  double get totalPrice => product.price * quantity;
}

class PosController extends GetxController {
  final PosRepository _repository = Get.find<PosRepository>();
  final List<Category> _categories = <Category>[].obs;
  final List<Product> _products = <Product>[].obs;
  final List<CartItem> _cartItems = <CartItem>[].obs;
  final RxInt _selectedCategoryId = 0.obs;
  final RxBool _isLoading = false.obs;
  final RxDouble _dailyRevenue = 0.0.obs;
  
  String? fulfillmentType;
  String? tableNumber;
  String? customerName;
  String? customerPhone;
  String? customerAddress;

  List<Category> get categories => _categories;
  List<Product> get products => _products;
  List<CartItem> get cartItems => _cartItems;
  int get selectedCategoryId => _selectedCategoryId.value;
  bool get isLoading => _isLoading.value;
  double get dailyRevenue => _dailyRevenue.value;
  double get cartTotal => _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  @override
  void onInit() {
    super.onInit();
    // Get arguments passed to the screen
    final args = Get.arguments as Map<String, dynamic>;
    fulfillmentType = args['fulfillmentType'];
    tableNumber = args['tableNumber'];
    
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    _isLoading.value = true;
    try {
      // Fetch categories and products simultaneously
      await Future.wait([
        fetchCategories(),
        fetchProducts(),
      ]);
    } catch (e) {
      AppSnackbar.showError("Failed to load data: $e");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    try {
      final data = await _repository.getCategories();
      _categories.assignAll(data);
      // Add "All" category as first item
      _categories.insert(0, Category(id: 0, name: "All"));
    } catch (e) {
      AppSnackbar.showError("Failed to load categories: $e");
    }
  }

  Future<void> fetchProducts() async {
    try {
      final data = await _repository.getProducts();
      _products.assignAll(data);
    } catch (e) {
      AppSnackbar.showError("Failed to load products: $e");
    }
  }

  void selectCategory(int categoryId) {
    _selectedCategoryId.value = categoryId;
  }

  List<Product> getFilteredProducts() {
    if (_selectedCategoryId.value == 0) {
      return _products; // Show all products
    }
    return _products.where((product) => product.categoryId == _selectedCategoryId.value).toList();
  }

  void addToCart(Product product) {
    final existingItemIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
    
    if (existingItemIndex != -1) {
      _cartItems[existingItemIndex].quantity++;
    } else {
      _cartItems.add(CartItem(product, 1));
    }
    update();
  }

  void removeFromCart(int index) {
    _cartItems.removeAt(index);
    update();
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _cartItems.removeAt(index);
    } else {
      _cartItems[index].quantity = newQuantity;
    }
    update();
  }

  Future<bool> validateAndSubmitOrder() async {
    // Validate cart is not empty
    if (_cartItems.isEmpty) {
      AppSnackbar.showError("Cart is empty. Please add items to cart.");
      return false;
    }

    // Validate required fields for takeout and delivery
    if (fulfillmentType == 'emporter') {
      if (customerName == null || customerName!.isEmpty) {
        AppSnackbar.showError("Customer name is required for takeout orders.");
        return false;
      }
      if (customerPhone == null || customerPhone!.isEmpty) {
        AppSnackbar.showError("Customer phone is required for takeout orders.");
        return false;
      }
    } else if (fulfillmentType == 'livraison') {
      if (customerName == null || customerName!.isEmpty) {
        AppSnackbar.showError("Customer name is required for delivery orders.");
        return false;
      }
      if (customerPhone == null || customerPhone!.isEmpty) {
        AppSnackbar.showError("Customer phone is required for delivery orders.");
        return false;
      }
      if (customerAddress == null || customerAddress!.isEmpty) {
        AppSnackbar.showError("Customer address is required for delivery orders.");
        return false;
      }
    }

    // Prepare order items
    List<OrderItem> orderItems = _cartItems.map((item) => 
      OrderItem(productId: item.product.id, quantity: item.quantity)
    ).toList();

    // Create order
    final order = Order(
      fulfillmentType: fulfillmentType!,
      tableNumber: tableNumber,
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
      items: orderItems,
    );

    try {
      _isLoading.value = true;
      final result = await _repository.createOrder(order);
      
      AppSnackbar.showSuccess("Order submitted successfully!");
      
      // Clear cart and navigate back
      _cartItems.clear();
      Get.back(); // Go back to choice screen
      
      return true;
    } catch (e) {
      AppSnackbar.showError("Failed to submit order: $e");
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}

class PosBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PosController>(() => PosController());
  }
}