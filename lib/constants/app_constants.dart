class AppConstants {
  static const String appName = 'POS System';
  static const String version = '1.0.0';
  
  // Sync statuses
  static const String syncStatusPending = 'pending';
  static const String syncStatusSynced = 'synced';
  static const String syncStatusUpdated = 'updated';
  static const String syncStatusDeleted = 'deleted';
  
  // Operation types
  static const String operationCreate = 'create';
  static const String operationUpdate = 'update';
  static const String operationDelete = 'delete';
  
  // Entity types
  static const String entityUser = 'User';
  static const String entityOrder = 'Order';
  static const String entityProduct = 'Product';
  
  // Roles
  static const String roleAdmin = 'admin';
  static const String roleServer = 'server';
  
  // Storage keys
  static const String storageToken = 'auth_token';
  static const String storageCurrentUser = 'current_user';
  static const String storageLastSyncTime = 'last_sync_time';
  
  // Timeouts
  static const Duration sessionTimeout = Duration(minutes: 5);
  static const Duration syncInterval = Duration(minutes: 1);
  static const Duration connectionCheckInterval = Duration(seconds: 5);
  
  // API endpoints
  static const String apiUrl = 'http://your-laravel-api.com/api';
}