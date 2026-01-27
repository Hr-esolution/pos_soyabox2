import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/user.dart';
import '../models/auth_response.dart';
import '../config/api_config.dart';

class ApiService {
  String? _token;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void setToken(String token) {
    _token = token;
  }

  void setConnectionStatus(bool connected) {
    _isConnected = connected;
  }

  Map<String, String> get _headers {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<AuthResponse> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromMap(data);
        
        if (authResponse.token != null) {
          _token = authResponse.token;
        }
        
        return authResponse;
      } else {
        final errorData = jsonDecode(response.body);
        return AuthResponse(
          success: false,
          message: errorData['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.logoutEndpoint}'),
        headers: _headers,
      );
      _token = null;
    } catch (e) {
      print('Logout error: $e');
    }
  }

  Future<List<User>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.usersEndpoint}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((userMap) => User.fromMap(userMap))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load users');
        }
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting users: $e');
      rethrow;
    }
  }

  Future<User> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.usersEndpoint}'),
        headers: _headers,
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return User.fromMap(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to create user');
        }
      } else {
        throw Exception('Failed to create user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  Future<User> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.usersEndpoint}/$userId'),
        headers: _headers,
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return User.fromMap(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to update user');
        }
      } else {
        throw Exception('Failed to update user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.usersEndpoint}/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        throw Exception('Failed to delete user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> syncData(List<Map<String, dynamic>> operations) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.syncEndpoint}'),
        headers: _headers,
        body: jsonEncode({'operations': operations}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Sync failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error syncing data: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPendingSyncOperations() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.pendingSyncEndpoint}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to get pending sync operations');
        }
      } else {
        throw Exception('Failed to get pending sync operations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting pending sync operations: $e');
      rethrow;
    }
  }
}