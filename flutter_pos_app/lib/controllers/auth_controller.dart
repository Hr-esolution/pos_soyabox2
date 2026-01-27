import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../constants/app_constants.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxBool _isLoggedIn = false.obs;
  final RxBool _isLoading = false.obs;
  
  User? get currentUser => _currentUser.value;
  bool get isLoggedIn => _isLoggedIn.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final userData = prefs.getString(AppConstants.currentUserKey);
    
    if (token != null && userData != null) {
      _apiService.setToken(token);
      _currentUser.value = User.fromJson(userData);
      _isLoggedIn.value = true;
    }
  }

  Future<bool> login(String phone, String password) async {
    _isLoading.value = true;
    try {
      final response = await _apiService.login(phone, password);
      
      if (response.success && response.user != null && response.token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, response.token!);
        await prefs.setString(AppConstants.currentUserKey, response.user!.toJson());
        
        _apiService.setToken(response.token!);
        _currentUser.value = response.user;
        _isLoggedIn.value = true;
        
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove(AppConstants.currentUserKey);
      
      _currentUser.value = null;
      _isLoggedIn.value = false;
    } catch (e) {
      print('Logout error: $e');
    }
  }

  Future<bool> validatePin(String pin) async {
    // Validate PIN against stored user data
    if (currentUser != null && currentUser!.pin == pin) {
      return true;
    }
    
    // Also check in local database if available
    // This would require dependency injection of UserController
    return false;
  }
}