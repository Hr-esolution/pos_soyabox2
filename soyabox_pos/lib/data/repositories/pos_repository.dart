import 'package:get/get.dart';
import '../models/table_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';

class PosRepository extends GetxService {
  late ApiService _apiService;

  Future<PosRepository> init() async {
    _apiService = Get.find<ApiService>();
    return this;
  }

  // Tables
  Future<List<TableModel>> getTables() async {
    try {
      final response = await _apiService.getTables();
      if (_apiService.isSuccess(response)) {
        List<dynamic> data = response.body['data'] ?? response.body;
        return data.map((json) => TableModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tables');
      }
    } catch (e) {
      throw Exception('Error loading tables: $e');
    }
  }

  // Categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiService.getCategories();
      if (_apiService.isSuccess(response)) {
        List<dynamic> data = response.body['data'] ?? response.body;
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error loading categories: $e');
    }
  }

  // Products
  Future<List<Product>> getProducts() async {
    try {
      final response = await _apiService.getProducts();
      if (_apiService.isSuccess(response)) {
        List<dynamic> data = response.body['data'] ?? response.body;
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error loading products: $e');
    }
  }

  // Create Order
  Future<Map<String, dynamic>> createOrder(Order order) async {
    try {
      final response = await _apiService.createOrder(order);
      if (_apiService.isSuccess(response)) {
        return response.body;
      } else {
        throw Exception(response.body['message'] ?? 'Failed to create order');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }
}