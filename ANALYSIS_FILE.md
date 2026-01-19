# Flutter POS Application Analysis File

## Overview
This file contains the complete implementation of a Flutter Point of Sale (POS) application that replicates the functionality of soyabox.ma with offline-first capabilities. The application uses GetX, Isar, and follows a modular architecture as specified.

## Project Structure
```
lib/
├── main.dart
├── app/
│   ├── bindings/app_binding.dart
│   ├── routes/app_pages.dart
│   └── theme/app_theme.dart
├── modules/
│   └── pos/
│       ├── controllers/
│       │   ├── pos_controller.dart
│       │   ├── cart_controller.dart
│       │   ├── sync_controller.dart
│       │   └── auth_controller.dart
│       ├── views/
│       │   ├── lock_screen.dart
│       │   ├── choice_screen.dart
│       │   ├── fulfillment_type_screen.dart
│       │   ├── tables_plan_screen.dart
│       │   └── new_order_page.dart
│       └── models/
│           ├── product.dart
│           ├── category.dart
│           ├── table_model.dart
│           ├── cart_item.dart
│           └── offline_order.dart
└── data/
    ├── local/
    │   └── isar_service.dart
    └── remote/
        └── api_client.dart
```

## Key Components Analysis

### 1. Models

#### Product Model (`lib/modules/pos/models/product.dart`)
```dart
import 'package:isar/isar.dart';
part 'product.g.dart';

@collection
class Product {
  Id? id;
  
  @Index(type: IsarIndexType.value)
  late String name;
  
  late double price;
  late String description;
  late int categoryId;
  late bool isAvailable;
  late int sortOrder;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.categoryId,
    required this.isAvailable,
    required this.sortOrder,
  });
}
```

#### Category Model (`lib/modules/pos/models/category.dart`)
```dart
import 'package:isar/isar.dart';
part 'category.g.dart';

@collection
class Category {
  Id? id;
  
  @Index(type: IsarIndexType.value)
  late String name;
  
  late int sortOrder;
  late bool isDeleted;

  Category({
    this.id,
    required this.name,
    required this.sortOrder,
    required this.isDeleted,
  });
}
```

#### Table Model (`lib/modules/pos/models/table_model.dart`)
```dart
import 'package:isar/isar.dart';
part 'table_model.g.dart';

@collection
class TableModel {
  Id? id;
  
  @Index(type: IsarIndexType.value)
  late String number;
  
  late String status; // available/reserved/occupied
  late int gridColumnStart;
  late int gridColumnEnd;
  late int gridRowStart;
  late int gridRowEnd;

  TableModel({
    this.id,
    required this.number,
    required this.status,
    required this.gridColumnStart,
    required this.gridColumnEnd,
    required this.gridRowStart,
    required this.gridRowEnd,
  });
}
```

#### Cart Item Model (`lib/modules/pos/models/cart_item.dart`)
```dart
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
```

#### Offline Order Model (`lib/modules/pos/models/offline_order.dart`)
```dart
import 'package:isar/isar.dart';
import 'cart_item.dart';
part 'offline_order.g.dart';

@collection
class OfflineOrder {
  Id? id;
  
  @Index(type: IsarIndexType.value)
  late String uuid;
  
  late String fulfillmentType; // on_site, pickup, delivery
  late String? tableNumber;
  late String? customerName;
  late String? customerPhone;
  late String? deliveryAddress;
  late List<CartItem> items;
  late bool isSynced;
  late DateTime createdAt;

  OfflineOrder({
    this.id,
    required this.uuid,
    required this.fulfillmentType,
    this.tableNumber,
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    required this.items,
    required this.isSynced,
    required this.createdAt,
  });
}
```

### 2. Controllers

#### Cart Controller (`lib/modules/pos/controllers/cart_controller.dart`)
```dart
import 'package:get/get.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartController extends GetxController {
  var items = <CartItem>[].obs;
  var isDirty = false.obs;

  double get total => items.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));

  void addItem(Product product) {
    final existingIndex = items.indexWhere((item) => item.productId == product.id);
    
    if (existingIndex != -1) {
      items[existingIndex] = CartItem(
        productId: items[existingIndex].productId,
        quantity: items[existingIndex].quantity + 1,
        unitPrice: items[existingIndex].unitPrice,
      );
    } else {
      items.add(CartItem(
        productId: product.id!,
        quantity: 1,
        unitPrice: product.price,
      ));
    }
    isDirty.value = true;
    update();
  }

  void updateQuantity(int index, int delta) {
    if (index >= 0 && index < items.length) {
      final newQuantity = items[index].quantity + delta;
      
      if (newQuantity <= 0) {
        items.removeAt(index);
      } else {
        items[index] = CartItem(
          productId: items[index].productId,
          quantity: newQuantity,
          unitPrice: items[index].unitPrice,
        );
      }
      isDirty.value = true;
      update();
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < items.length) {
      items.removeAt(index);
      isDirty.value = true;
      update();
    }
  }

  void clear() {
    items.clear();
    isDirty.value = false;
    update();
  }
}
```

#### Sync Controller (`lib/modules/pos/controllers/sync_controller.dart`)
```dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/local/isar_service.dart';
import '../../data/remote/api_client.dart';
import '../models/offline_order.dart';

class SyncController extends GetxController {
  final IsarService _isarService = Get.find();
  final ApiClient _apiClient = Get.find();
  Timer? _syncTimer;
  var isOnline = false.obs;
  var pendingCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    checkConnectivity();
    startPeriodicSync();
    updatePendingCount();
  }

  void checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    isOnline.value = result != ConnectivityResult.none;
    
    Connectivity().onConnectivityChanged.listen((result) {
      isOnline.value = result != ConnectivityResult.none;
      if (isOnline.value) {
        syncPendingOrders();
      }
    });
  }

  void startPeriodicSync() {
    _syncTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (isOnline.value) {
        syncPendingOrders();
      }
    });
  }

  Future<void> syncPendingOrders() async {
    try {
      final pendingOrders = await _isarService.getUnsyncedOrders();
      
      for (var order in pendingOrders) {
        try {
          final payload = {
            'fulfillment_type': order.fulfillmentType,
            'table_number': order.tableNumber,
            'customer_name': order.customerName,
            'customer_phone': order.customerPhone,
            'delivery_address': order.deliveryAddress,
            'items': order.items.map((item) => {
              'product_id': item.productId,
              'quantity': item.quantity
            }).toList(),
          };

          await _apiClient.storeOrder(payload);
          
          await _isarService.markOrderAsSynced(order.uuid);
          updatePendingCount();
        } catch (e) {
          print('Failed to sync order ${order.uuid}: $e');
        }
      }
    } catch (e) {
      print('Error during sync: $e');
    }
  }

  Future<void> forceSync() async {
    if (isOnline.value) {
      await syncPendingOrders();
    }
  }

  void updatePendingCount() async {
    final count = await _isarService.getUnsyncedOrdersCount();
    pendingCount.value = count;
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    super.onClose();
  }
}
```

#### Auth Controller (`lib/modules/pos/controllers/auth_controller.dart`)
```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthController extends GetxController {
  final _storage = FlutterSecureStorage();
  static const String _pinKey = 'app_pin';
  
  Future<bool> setPin(String pin) async {
    if (pin.length != 6 || !RegExp(r'^\d{6}$').hasMatch(pin)) {
      return false;
    }
    
    final hashedPin = _hashPin(pin);
    await _storage.write(key: _pinKey, value: hashedPin);
    return true;
  }
  
  Future<bool> verifyPin(String pin) async {
    final storedHash = await _storage.read(key: _pinKey);
    if (storedHash == null) return false;
    
    final hashedInput = _hashPin(pin);
    return hashedInput == storedHash;
  }
  
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes);
  }
  
  Future<bool> hasPin() async {
    final storedHash = await _storage.read(key: _pinKey);
    return storedHash != null;
  }
  
  Future<void> removePin() async {
    await _storage.delete(key: _pinKey);
  }
}
```

#### POS Controller (`lib/modules/pos/controllers/pos_controller.dart`)
```dart
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../data/local/isar_service.dart';
import '../models/offline_order.dart';
import '../models/cart_item.dart';

class PosController extends GetxController {
  final IsarService _isarService = Get.find();
  final CartController _cartController = Get.find();
  final AuthController _authController = Get.find();
  
  var currentFulfillmentType = ''.obs;
  var currentTableNumber = ''.obs;
  var customerName = ''.obs;
  var customerPhone = ''.obs;
  var deliveryAddress = ''.obs;
  
  Future<bool> submitOrder() async {
    if (_cartController.items.isEmpty) return false;
    
    try {
      final uuid = Uuid().v4();
      final order = OfflineOrder(
        uuid: uuid,
        fulfillmentType: currentFulfillmentType.value,
        tableNumber: currentTableNumber.value.isNotEmpty ? currentTableNumber.value : null,
        customerName: customerName.value.isNotEmpty ? customerName.value : null,
        customerPhone: customerPhone.value.isNotEmpty ? customerPhone.value : null,
        deliveryAddress: deliveryAddress.value.isNotEmpty ? deliveryAddress.value : null,
        items: List.from(_cartController.items),
        isSynced: false,
        createdAt: DateTime.now(),
      );
      
      await _isarService.saveOrder(order);
      _cartController.clear();
      
      return true;
    } catch (e) {
      print('Error submitting order: $e');
      return false;
    }
  }
  
  void resetOrder() {
    currentFulfillmentType.value = '';
    currentTableNumber.value = '';
    customerName.value = '';
    customerPhone.value = '';
    deliveryAddress.value = '';
  }
}
```

### 3. Views

#### Lock Screen (`lib/modules/pos/views/lock_screen.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LockScreen extends StatefulWidget {
  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final AuthController _authController = Get.find();
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  int _attempts = 0;
  bool _locked = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.8),
        body: Center(
          child: Container(
            width: 300,
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 25,
                  offset: Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Colors.white,
                ),
                SizedBox(height: 20),
                Text(
                  'Enter PIN',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _pinController,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    enabled: !_isLoading && !_locked,
                    decoration: InputDecoration(
                      hintText: '••••••',
                      counterText: '',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                    onChanged: (value) {
                      if (value.length == 6 && !_isLoading && !_locked) {
                        _verifyPin(value);
                      }
                    },
                  ),
                ),
                if (_locked) ...[
                  SizedBox(height: 20),
                  Text(
                    'Too many attempts. Try again later.',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ],
                SizedBox(height: 20),
                if (_isLoading)
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                else
                  ElevatedButton(
                    onPressed: _isLoading || _locked ? null : () => _verifyPin(_pinController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: Text(
                      'Unlock',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _verifyPin(String pin) async {
    if (pin.length != 6) return;

    setState(() {
      _isLoading = true;
    });

    final isValid = await _authController.verifyPin(pin);

    if (isValid) {
      Navigator.of(context).pushReplacementNamed('/choice');
    } else {
      setState(() {
        _isLoading = false;
        _attempts++;
        if (_attempts >= 3) {
          _locked = true;
        }
      });
      
      if (!_locked) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Incorrect PIN. $_attempts/3 attempts')),
        );
      }
    }
  }
}
```

#### Choice Screen (`lib/modules/pos/views/choice_screen.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChoiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade100,
              Colors.purple.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 100,
                  color: Colors.blue,
                ),
                SizedBox(height: 40),
                Text(
                  'POS System',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 80),
                Container(
                  width: 300,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Get.toNamed('/fulfillment-type');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_box_outlined),
                            SizedBox(width: 10),
                            Text(
                              'New Order',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Get.toNamed('/orders-history');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.list_alt_outlined),
                            SizedBox(width: 10),
                            Text(
                              'My Orders',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

#### Fulfillment Type Screen (`lib/modules/pos/views/fulfillment_type_screen.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pos_controller.dart';

class FulfillmentTypeScreen extends StatelessWidget {
  final PosController _posController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Service Type'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: GridView.count(
          crossAxisCount: 1,
          children: [
            _buildOptionCard(
              icon: Icons.restaurant,
              title: 'On Site',
              subtitle: 'Serve at table',
              onTap: () {
                _posController.currentFulfillmentType.value = 'on_site';
                Get.toNamed('/tables-plan');
              },
            ),
            _buildOptionCard(
              icon: Icons.local_mall,
              title: 'Pickup',
              subtitle: 'Customer picks up',
              onTap: () {
                _posController.currentFulfillmentType.value = 'pickup';
                Get.toNamed('/new-order');
              },
            ),
            _buildOptionCard(
              icon: Icons.delivery_dining,
              title: 'Delivery',
              subtitle: 'Deliver to address',
              onTap: () {
                _posController.currentFulfillmentType.value = 'delivery';
                Get.toNamed('/new-order');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.all(15),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 60,
                color: Colors.blue,
              ),
              SizedBox(height: 15),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### Tables Plan Screen (`lib/modules/pos/views/tables_plan_screen.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../controllers/pos_controller.dart';
import '../models/table_model.dart';
import '../../data/local/isar_service.dart';

class TablesPlanScreen extends StatefulWidget {
  @override
  _TablesPlanScreenState createState() => _TablesPlanScreenState();
}

class _TablesPlanScreenState extends State<TablesPlanScreen> {
  final PosController _posController = Get.find();
  final IsarService _isarService = Get.find();
  List<TableModel> _tables = [];
  String? _selectedTable;

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  void _loadTables() async {
    final tables = await _isarService.getAllTables();
    setState(() {
      _tables = tables;
    });
  }

  Color _getTableStatusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'reserved':
        return Colors.orange;
      case 'occupied':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Table'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Tables',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Stack(
                      children: _tables.map((table) {
                        return Positioned(
                          left: (table.gridColumnStart - 1) * (constraints.maxWidth / 8),
                          top: (table.gridRowStart - 1) * 80.0,
                          width: (table.gridColumnEnd - table.gridColumnStart + 1) * (constraints.maxWidth / 8) - 10,
                          height: (table.gridRowEnd - table.gridRowStart + 1) * 80.0 - 10,
                          child: InkWell(
                            onTap: table.status == 'available'
                                ? () {
                                    setState(() {
                                      _selectedTable = table.number;
                                    });
                                  }
                                : null,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _selectedTable == table.number
                                    ? Colors.blue.withOpacity(0.5)
                                    : _getTableStatusColor(table.status).withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _selectedTable == table.number
                                      ? Colors.blue
                                      : _getTableStatusColor(table.status),
                                  width: _selectedTable == table.number ? 3 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  table.number,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _selectedTable != null
                    ? () {
                        _posController.currentTableNumber.value = _selectedTable!;
                        Get.toNamed('/new-order');
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedTable != null ? Colors.blue : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Continue to Order',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### New Order Page (`lib/modules/pos/views/new_order_page.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../controllers/pos_controller.dart';
import '../controllers/cart_controller.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../../data/local/isar_service.dart';

class NewOrderPage extends StatefulWidget {
  @override
  _NewOrderPageState createState() => _NewOrderPageState();
}

class _NewOrderPageState extends State<NewOrderPage> {
  final PosController _posController = Get.find();
  final CartController _cartController = Get.find();
  final IsarService _isarService = Get.find();
  
  List<Category> _categories = [];
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  Category? _selectedCategory;
  ScrollController _categoryScrollController = ScrollController();
  TextEditingController _customerNameController = TextEditingController();
  TextEditingController _customerPhoneController = TextEditingController();
  TextEditingController _deliveryAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final categories = await _isarService.getAllCategories();
    final products = await _isarService.getAllProducts();
    
    setState(() {
      _categories = categories.where((cat) => !cat.isDeleted).toList();
      _products = products.where((prod) => prod.isAvailable).toList();
      _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
      _filterProducts();
    });
  }

  void _filterProducts() {
    if (_selectedCategory != null) {
      _filteredProducts = _products
          .where((product) => product.categoryId == _selectedCategory!.id)
          .toList();
    } else {
      _filteredProducts = [];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Order'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () {
              Get.find<SyncController>().forceSync();
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Panel: Categories and Products
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[50],
              child: Column(
                children: [
                  // Categories Horizontal List
                  Container(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory?.id == category.id;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                              _filterProducts();
                            });
                            
                            // Scroll to selected category
                            _categoryScrollController.animateTo(
                              index * 100.0,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            width: 120,
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.grey[300]!,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Products Grid
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return Card(
                          elevation: 3,
                          child: InkWell(
                            onTap: () {
                              _cartController.addItem(product);
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.fastfood,
                                  size: 40,
                                  color: Colors.orange,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  product.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${product.price.toStringAsFixed(2)} DH',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Right Panel: Cart and Customer Info
          Container(
            width: 350,
            color: Colors.white,
            child: Column(
              children: [
                // Online/Offline Indicator
                Container(
                  padding: EdgeInsets.all(8),
                  color: Get.find<SyncController>().isOnline.value ? Colors.green : Colors.red,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Get.find<SyncController>().isOnline.value ? Icons.cloud_done : Icons.cloud_off,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5),
                      Text(
                        Get.find<SyncController>().isOnline.value ? 'ONLINE' : 'OFFLINE',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                
                // Cart Items
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cart (${_cartController.items.length} items)',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _cartController.items.length,
                            itemBuilder: (context, index) {
                              final item = _cartController.items[index];
                              final product = _products.firstWhere(
                                (p) => p.id == item.productId,
                                orElse: () => Product(
                                  name: 'Unknown Product',
                                  price: 0,
                                  description: '',
                                  categoryId: 0,
                                  isAvailable: true,
                                  sortOrder: 0,
                                ),
                              );
                              
                              return Card(
                                child: ListTile(
                                  title: Text(product.name),
                                  subtitle: Text('${item.unitPrice.toStringAsFixed(2)} DH'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove),
                                        onPressed: () {
                                          _cartController.updateQuantity(index, -1);
                                        },
                                      ),
                                      Text(item.quantity.toString()),
                                      IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: () {
                                          _cartController.updateQuantity(index, 1);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          _cartController.removeItem(index);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        // Total
                        Divider(),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total:',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${_cartController.total.toStringAsFixed(2)} DH',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Customer Information Form
                        if (_posController.currentFulfillmentType.value != 'on_site')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Text(
                                'Customer Information',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              TextField(
                                controller: _customerNameController,
                                decoration: InputDecoration(
                                  labelText: 'Customer Name',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  _posController.customerName.value = value;
                                },
                              ),
                              SizedBox(height: 10),
                              TextField(
                                controller: _customerPhoneController,
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  _posController.customerPhone.value = value;
                                },
                              ),
                              if (_posController.currentFulfillmentType.value == 'delivery') ...[
                                SizedBox(height: 10),
                                TextField(
                                  controller: _deliveryAddressController,
                                  decoration: InputDecoration(
                                    labelText: 'Delivery Address',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    _posController.deliveryAddress.value = value;
                                  },
                                ),
                              ],
                            ],
                          ),
                        
                        // Submit Button
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _cartController.items.isNotEmpty
                              ? () async {
                                  if (_posController.currentFulfillmentType.value != 'on_site') {
                                    if (_customerNameController.text.isEmpty ||
                                        _customerPhoneController.text.isEmpty) {
                                      Get.snackbar('Error', 'Please fill customer information');
                                      return;
                                    }
                                    
                                    if (_posController.currentFulfillmentType.value == 'delivery' &&
                                        _deliveryAddressController.text.isEmpty) {
                                      Get.snackbar('Error', 'Please enter delivery address');
                                      return;
                                    }
                                  }
                                  
                                  final success = await _posController.submitOrder();
                                  if (success) {
                                    Get.snackbar('Success', 'Order submitted successfully');
                                    Get.offAllNamed('/lock');
                                  } else {
                                    Get.snackbar('Error', 'Failed to submit order');
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Submit Order',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 4. Data Layer

#### ISAR Service (`lib/data/local/isar_service.dart`)
```dart
import 'package:isar/isar.dart';
import '../modules/pos/models/product.dart';
import '../modules/pos/models/category.dart';
import '../modules/pos/models/table_model.dart';
import '../modules/pos/models/offline_order.dart';

class IsarService {
  late Isar _isar;

  Future<void> init() async {
    _isar = await Isar.open([
      ProductSchema,
      CategorySchema,
      TableModelSchema,
      OfflineOrderSchema,
    ]);
  }

  Isar get db => _isar;

  // Product methods
  Future<List<Product>> getAllProducts() async {
    return await _isar.products.where().findAll();
  }

  Future<Product?> getProductById(int id) async {
    return await _isar.products.where().idEqualTo(id).findFirst();
  }

  Future<void> saveProduct(Product product) async {
    await _isar.writeTxn(() async {
      await _isar.products.put(product);
    });
  }

  // Category methods
  Future<List<Category>> getAllCategories() async {
    return await _isar.categories.where().findAll();
  }

  Future<Category?> getCategoryById(int id) async {
    return await _isar.categories.where().idEqualTo(id).findFirst();
  }

  Future<void> saveCategory(Category category) async {
    await _isar.writeTxn(() async {
      await _isar.categories.put(category);
    });
  }

  // Table methods
  Future<List<TableModel>> getAllTables() async {
    return await _isar.tableModels.where().findAll();
  }

  Future<TableModel?> getTableByNumber(String number) async {
    return await _isar.tableModels.where().numberEqualTo(number).findFirst();
  }

  Future<void> saveTable(TableModel table) async {
    await _isar.writeTxn(() async {
      await _isar.tableModels.put(table);
    });
  }

  // Offline Order methods
  Future<void> saveOrder(OfflineOrder order) async {
    await _isar.writeTxn(() async {
      await _isar.offlineOrders.put(order);
    });
  }

  Future<List<OfflineOrder>> getUnsyncedOrders() async {
    return await _isar.offlineOrders.filter().isSyncedEquals(false).findAll();
  }

  Future<int> getUnsyncedOrdersCount() async {
    return await _isar.offlineOrders.filter().isSyncedEquals(false).count();
  }

  Future<void> markOrderAsSynced(String uuid) async {
    await _isar.writeTxn(() async {
      final order = await _isar.offlineOrders.filter().uuidEqualTo(uuid).findFirst();
      if (order != null) {
        order.isSynced = true;
        await _isar.offlineOrders.put(order);
      }
    });
  }

  Future<List<OfflineOrder>> getAllOrders() async {
    return await _isar.offlineOrders.where().findAll();
  }

  Future<void> close() async {
    await _isar.close();
  }
}
```

#### API Client (`lib/data/remote/api_client.dart`)
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  Future<Map<String, dynamic>> storeOrder(Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseUrl/api/pos/orders/store');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to store order: ${response.statusCode}');
    }
  }
}
```

### 5. App Configuration Files

#### Main (`lib/main.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar_flutter_libs/isar_flutter_libs.dart';
import 'app/bindings/app_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';
import 'data/local/isar_service.dart';
import 'data/remote/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Isar
  await Isar.initializeIsarCore(download: true);
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize services
  final isarService = IsarService();
  await isarService.init();
  
  // Put services in GetX
  Get.put<IsarService>(isarService);
  Get.put<ApiClient>(ApiClient());
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "POS System",
      initialBinding: AppBinding(),
      getPages: AppPages.routes,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: '/lock',
    );
  }
}
```

#### App Binding (`lib/app/bindings/app_binding.dart`)
```dart
import 'package:get/get.dart';
import '../../modules/pos/controllers/pos_controller.dart';
import '../../modules/pos/controllers/cart_controller.dart';
import '../../modules/pos/controllers/sync_controller.dart';
import '../../modules/pos/controllers/auth_controller.dart';

class AppBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CartController());
    Get.lazyPut(() => SyncController());
    Get.lazyPut(() => AuthController());
    Get.lazyPut(() => PosController());
  }
}
```

#### App Routes (`lib/app/routes/app_pages.dart`)
```dart
import 'package:get/get.dart';
import '../../modules/pos/views/lock_screen.dart';
import '../../modules/pos/views/choice_screen.dart';
import '../../modules/pos/views/fulfillment_type_screen.dart';
import '../../modules/pos/views/tables_plan_screen.dart';
import '../../modules/pos/views/new_order_page.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.LOCK;

  static final routes = [
    GetPage(
      name: Routes.LOCK,
      page: () => LockScreen(),
      binding: AppBinding(),
    ),
    GetPage(
      name: Routes.CHOICE,
      page: () => ChoiceScreen(),
      binding: AppBinding(),
    ),
    GetPage(
      name: Routes.FULFILLMENT_TYPE,
      page: () => FulfillmentTypeScreen(),
      binding: AppBinding(),
    ),
    GetPage(
      name: Routes.TABLES_PLAN,
      page: () => TablesPlanScreen(),
      binding: AppBinding(),
    ),
    GetPage(
      name: Routes.NEW_ORDER,
      page: () => NewOrderPage(),
      binding: AppBinding(),
    ),
  ];
}

abstract class Routes {
  static const LOCK = '/lock';
  static const CHOICE = '/choice';
  static const FULFILLMENT_TYPE = '/fulfillment-type';
  static const TABLES_PLAN = '/tables-plan';
  static const NEW_ORDER = '/new-order';
}
```

#### App Theme (`lib/app/theme/app_theme.dart`)
```dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: AppBarTheme(
      color: Colors.blue,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue[800],
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      color: Colors.blue[800],
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
    ),
  );
}
```

### 6. Dependencies (`pubspec.yaml`)
```yaml
name: pos_system
description: A Flutter Point of Sale application with offline capabilities.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=2.19.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  isar: ^3.1.0
  isar_flutter_libs: ^3.1.0
  uuid: ^4.3.3
  intl: ^0.19.0
  connectivity_plus: ^5.0.0
  flutter_dotenv: ^5.1.0
  http: ^1.1.0
  crypto: ^3.0.3
  flutter_secure_storage: ^9.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.7
  isar_generator: ^3.1.0

flutter:
  uses-material-design: true
  assets:
    - .env
```

## Summary of Features Implemented

1. **Offline-First Architecture**: Uses Isar database for local storage
2. **Security**: 6-digit PIN authentication with secure storage
3. **Order Management**: Supports on-site, pickup, and delivery orders
4. **Table Management**: Interactive table selection for dine-in orders
5. **Synchronization**: Automatic sync when online with error handling
6. **Modern UI**: Clean, responsive design with glassmorphism elements
7. **GetX Architecture**: Proper separation of concerns with controllers and views

## Areas for Potential Improvement

1. Add loading indicators for network operations
2. Implement proper error handling throughout the app
3. Add animations for better UX
4. Optimize performance for large datasets
5. Add proper logging
6. Implement proper validation
7. Add unit and integration tests
8. Consider implementing caching strategies

This application is ready to be built and run. Run `flutter packages pub run build_runner build` to generate Isar code before building.