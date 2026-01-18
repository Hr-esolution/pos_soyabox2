import '../models/user_model.dart';
import '../models/table_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';

class PosRepository {
  final ApiService _apiService = ApiService();

  // Authentification
  Future<User> login(String emailOrPhone, String password) => 
      _apiService.login(emailOrPhone, password);

  // Tables
  Future<List<Table>> getTables() => _apiService.getTables();

  // Catégories
  Future<List<Category>> getCategories() => _apiService.getCategories();

  // Produits
  Future<List<Product>> getProducts() => _apiService.getProducts();

  // Commandes
  Future<Order> createOrder(Order order) => _apiService.createOrder(order);
}