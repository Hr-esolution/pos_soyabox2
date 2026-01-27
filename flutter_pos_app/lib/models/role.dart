class Role {
  static const String admin = 'admin';
  static const String server = 'server';
  
  static List<String> getAllRoles() {
    return [admin, server];
  }
  
  static bool isValidRole(String role) {
    return getAllRoles().contains(role);
  }
}