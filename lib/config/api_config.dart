class ApiConfig {
  static const String baseUrl = 'http://your-laravel-api.com/api';
  
  // Endpoints
  static const String login = '/login';
  static const String logout = '/logout';
  static const String users = '/users';
  static const String sync = '/sync';
  static const String syncPending = '/sync/pending';
  static const String posData = '/pos/data';
  
  // Headers
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer ';
}