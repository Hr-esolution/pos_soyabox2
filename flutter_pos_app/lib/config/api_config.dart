class ApiConfig {
  static const String baseUrl = 'http://localhost:8000/api'; // Replace with your Laravel API URL
  
  // Endpoints
  static const String loginEndpoint = '/login';
  static const String logoutEndpoint = '/logout';
  static const String usersEndpoint = '/users';
  static const String syncEndpoint = '/sync';
  static const String pendingSyncEndpoint = '/sync/pending';
  
  // Headers
  static Map<String, String> get defaultHeaders {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
  
  static Map<String, String> getAuthHeaders(String token) {
    return {
      ...defaultHeaders,
      'Authorization': 'Bearer $token',
    };
  }
}