class ApiEndpoints {
  // Base URL - à remplacer par l'URL de votre backend
  static const String baseUrl = 'http://localhost:8000/api'; // Remplacer par l'URL réelle de votre API
  
  // Authentification
  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/register';
  
  // Ressources
  static const String tables = '$baseUrl/tables';
  static const String categories = '$baseUrl/categories';
  static const String products = '$baseUrl/products';
  static const String orders = '$baseUrl/pos/orders/store';
  
  // Utilisateur
  static const String profile = '$baseUrl/profile';
  static const String logout = '$baseUrl/logout';
}