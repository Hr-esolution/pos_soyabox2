import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';
import '../models/auth_response.dart';
import '../constants/app_constants.dart';

class ApiService {
  final http.Client _client = http.Client();

  Future<AuthResponse> login(String phone, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}'),
        headers: {
          ApiConfig.contentType: ApiConfig.applicationJson,
        },
        body: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);
      return AuthResponse.fromJson(responseData);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<AuthResponse> logout(String token) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.logout}'),
        headers: {
          ApiConfig.authorization: '${ApiConfig.bearer}$token',
        },
      );

      final responseData = jsonDecode(response.body);
      return AuthResponse.fromJson(responseData);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<AuthResponse> getUsers() async {
    try {
      // This is a simplified implementation
      // In a real app, you'd need authentication
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.users}'),
        headers: {
          ApiConfig.contentType: ApiConfig.applicationJson,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final usersData = responseData['data'] as List;
          final users = usersData.map((json) => User.fromJson(json)).toList();
          return AuthResponse(
            success: true,
            data: users,
          );
        }
      }
      
      return AuthResponse(
        success: false,
        message: 'Failed to load users',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<AuthResponse> createUser(User user, String token) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.users}'),
        headers: {
          ApiConfig.contentType: ApiConfig.applicationJson,
          ApiConfig.authorization: '${ApiConfig.bearer}$token',
        },
        body: jsonEncode({
          'name': user.name,
          'phone': user.phone,
          'role': user.role,
          'pin': user.pin,
          'is_active': user.isActive,
        }),
      );

      final responseData = jsonDecode(response.body);
      return AuthResponse.fromJson(responseData);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<AuthResponse> updateUser(int userId, User user, String token) async {
    try {
      final response = await _client.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.users}/$userId'),
        headers: {
          ApiConfig.contentType: ApiConfig.applicationJson,
          ApiConfig.authorization: '${ApiConfig.bearer}$token',
        },
        body: jsonEncode({
          'name': user.name,
          'phone': user.phone,
          'role': user.role,
          'pin': user.pin,
          'is_active': user.isActive,
        }),
      );

      final responseData = jsonDecode(response.body);
      return AuthResponse.fromJson(responseData);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<AuthResponse> deleteUser(int userId, String token) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.users}/$userId'),
        headers: {
          ApiConfig.authorization: '${ApiConfig.bearer}$token',
        },
      );

      final responseData = jsonDecode(response.body);
      return AuthResponse.fromJson(responseData);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<AuthResponse> syncData(List<Map<String, dynamic>> operations, String token) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.sync}'),
        headers: {
          ApiConfig.contentType: ApiConfig.applicationJson,
          ApiConfig.authorization: '${ApiConfig.bearer}$token',
        },
        body: jsonEncode({
          'operations': operations,
        }),
      );

      final responseData = jsonDecode(response.body);
      return AuthResponse.fromJson(responseData);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<AuthResponse> getPendingSyncOperations(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.syncPending}'),
        headers: {
          ApiConfig.authorization: '${ApiConfig.bearer}$token',
        },
      );

      final responseData = jsonDecode(response.body);
      return AuthResponse.fromJson(responseData);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  void dispose() {
    _client.close();
  }
}