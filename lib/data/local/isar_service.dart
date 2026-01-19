import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../modules/pos/models/product.dart';
import '../../modules/pos/models/category.dart';
import '../../modules/pos/models/table_model.dart';
import '../../modules/pos/models/offline_order.dart';

class IsarService {
  static late Isar _isar;
  static bool _isOpen = false;

  static Future<void> open() async {
    if (_isOpen) return;
    
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        ProductSchema,
        CategorySchema,
        TableModelSchema,
        OfflineOrderSchema,
      ],
      directory: dir.path,
    );
    _isOpen = true;
  }

  static Isar get db {
    if (!_isOpen) {
      throw Exception('Isar database not opened. Call open() first.');
    }
    return _isar;
  }

  // Product operations
  static Future<int> addProduct(Product product) async {
    return await _isar.writeTxn(() => _isar.products.put(product));
  }

  static Future<List<Product>> getAllProducts() async {
    return await _isar.products.where().findAll();
  }

  static Future<Product?> getProductById(int id) async {
    return await _isar.products.where().idEqualTo(id).findFirst();
  }

  // Category operations
  static Future<int> addCategory(Category category) async {
    return await _isar.writeTxn(() => _isar.categories.put(category));
  }

  static Future<List<Category>> getAllCategories() async {
    return await _isar.categories.where().findAll();
  }

  static Future<Category?> getCategoryById(int id) async {
    return await _isar.categories.where().idEqualTo(id).findFirst();
  }

  // Table operations
  static Future<int> addTable(TableModel table) async {
    return await _isar.writeTxn(() => _isar.tables.put(table));
  }

  static Future<List<TableModel>> getAllTables() async {
    return await _isar.tables.where().findAll();
  }

  static Future<TableModel?> getTableById(int id) async {
    return await _isar.tables.where().idEqualTo(id).findFirst();
  }

  static Future<int> updateTableStatus(int tableId, TableStatus status) async {
    return await _isar.writeTxn(() async {
      final table = await _isar.tables.get(tableId);
      if (table != null) {
        table.status = status;
        return await _isar.tables.put(table);
      }
      return -1;
    });
  }

  // Offline Order operations
  static Future<int> addOfflineOrder(OfflineOrder order) async {
    return await _isar.writeTxn(() => _isar.offlineOrders.put(order));
  }

  static Future<List<OfflineOrder>> getUnsyncedOrders() async {
    return await _isar.offlineOrders.filter().isSyncedFalse().findAll();
  }

  static Future<int> markOrderAsSynced(String uuid) async {
    return await _isar.writeTxn(() async {
      final order = await _isar.offlineOrders.filter().uuidEquals(uuid).findFirst();
      if (order != null) {
        order.isSynced = true;
        return await _isar.offlineOrders.put(order);
      }
      return -1;
    });
  }

  static Future<List<OfflineOrder>> getAllOrders() async {
    return await _isar.offlineOrders.where().findAll();
  }

  static Future<void> close() async {
    await _isar.close();
    _isOpen = false;
  }
}