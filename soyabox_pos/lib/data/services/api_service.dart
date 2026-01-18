import 'package:get/get.dart';
import '../models/user_model.dart';
import '../models/table_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../../core/constants/api_endpoints.dart';

class ApiService extends GetConnect {
  final String baseUrl = 'http://your-api-url.com'; // Replace with your actual API URL

  @override
  void onInit() {
    super.onInit();
    httpClient.defaultDecoder = (map) {
      if (map is Map) return map.cast<String, dynamic>();
      if (map is List) return map;
      return {};
    };
    httpClient.baseUrl = baseUrl;
  }

  // Authentication methods
  Future<Response> login(String emailOrPhone, String password) async {
    return await post(ApiEndpoints.login, {
      'email': emailOrPhone,
      'password': password,
    });
  }

  // Tables
  Future<Response> getTables() async {
    return await get(ApiEndpoints.tables);
  }

  // Categories
  Future<Response> getCategories() async {
    return await get(ApiEndpoints.categories);
  }

  // Products
  Future<Response> getProducts() async {
    return await get(ApiEndpoints.products);
  }

  // Create Order
  Future<Response> createOrder(Order order) async {
    return await post(
      ApiEndpoints.orders,
      order.toJson(),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // Helper method to check if request was successful
  bool isSuccess(Response response) {
    return response.statusCode == 200 || response.statusCode == 201;
  }
}