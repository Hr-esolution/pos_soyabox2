import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/table_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../../core/constants/api_endpoints.dart';

class ApiService {
  static const String contentType = 'application/json';
  static const int requestTimeout = 30000; // 30 secondes

  // Méthode générique pour les requêtes GET
  Future<Map<String, dynamic>> _getRequest(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': contentType},
      ).timeout(const Duration(milliseconds: requestTimeout));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur de réseau: $e');
    }
  }

  // Méthode générique pour les requêtes POST
  Future<Map<String, dynamic>> _postRequest(String url, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': contentType},
        body: json.encode(body),
      ).timeout(const Duration(milliseconds: requestTimeout));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur de réseau: $e');
    }
  }

  // Authentification
  Future<User> login(String emailOrPhone, String password) async {
    final response = await _postRequest(ApiEndpoints.login, {
      'email': emailOrPhone,
      'password': password,
    });
    
    return User.fromJson(response['data']);
  }

  // Récupération des tables
  Future<List<Table>> getTables() async {
    final response = await _getRequest(ApiEndpoints.tables);
    if (response['data'] is List) {
      return (response['data'] as List)
          .map((table) => Table.fromJson(table))
          .toList();
    }
    return [];
  }

  // Récupération des catégories
  Future<List<Category>> getCategories() async {
    final response = await _getRequest(ApiEndpoints.categories);
    if (response['data'] is List) {
      return (response['data'] as List)
          .map((category) => Category.fromJson(category))
          .toList();
    }
    return [];
  }

  // Récupération des produits
  Future<List<Product>> getProducts() async {
    final response = await _getRequest(ApiEndpoints.products);
    if (response['data'] is List) {
      return (response['data'] as List)
          .map((product) => Product.fromJson(product))
          .toList();
    }
    return [];
  }

  // Création d'une commande
  Future<Order> createOrder(Order order) async {
    final response = await _postRequest(ApiEndpoints.orders, order.toJson());
    return Order.fromJson(response['data']);
  }
}