class AppConstants {
  // App
  static const String appName = 'POS System';
  
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String currentUserKey = 'current_user';
  static const String lastSyncTimeKey = 'last_sync_time';
  
  // Validation
  static const int minPinLength = 4;
  static const int maxPinLength = 4;
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration syncInterval = Duration(seconds: 30);
  static const Duration lockTimeout = Duration(minutes: 5);
  
  // Error messages
  static const String networkError = 'Network error occurred';
  static const String unauthorizedError = 'Unauthorized access';
  static const String serverError = 'Server error occurred';
  static const String unknownError = 'An unknown error occurred';
  
  // Success messages
  static const String syncSuccess = 'Sync completed successfully';
  static const String userCreated = 'User created successfully';
  static const String userUpdated = 'User updated successfully';
  static const String userDeleted = 'User deactivated successfully';
}