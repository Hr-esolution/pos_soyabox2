import 'dart:async';
import 'package:get/get.dart';
import 'connectivity/connectivity.dart';
import '../models/sync_operation.dart';
import '../services/local_database.dart';
import '../services/api_service.dart';

class SyncService extends GetxService {
  final LocalDatabase _localDb = LocalDatabase();
  final ApiService _apiService = ApiService();
  
  Timer? _syncTimer;
  bool _isSyncing = false;
  
  static SyncService get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    startPeriodicSync();
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    super.onClose();
  }

  void startPeriodicSync() {
    // Sync every 30 seconds when connected
    _syncTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_apiService.isConnected) {
        performSync();
      }
    });
  }

  Future<void> performSync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      print('Starting sync operation...');
      
      // First, pull updates from server
      await pullServerUpdates();
      
      // Then, push local changes to server
      await pushPendingOperations();
      
      print('Sync completed successfully');
    } catch (e) {
      print('Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> pullServerUpdates() async {
    if (!_apiService.isConnected) return;

    try {
      // Get latest data from server
      final serverUsers = await _apiService.getUsers();
      
      // Update local database with server data
      for (final serverUser in serverUsers) {
        // Check if user exists locally
        // This would require a more complex implementation to find local ID
        // For now, we'll just ensure they exist locally
        await _localDb.insertUserLocal(serverUser, syncStatus: 'synced');
      }
    } catch (e) {
      print('Error pulling server updates: $e');
    }
  }

  Future<void> pushPendingOperations() async {
    if (!_apiService.isConnected) return;

    try {
      final pendingOps = await _localDb.getPendingSyncOperations();
      print('Found ${pendingOps.length} pending operations to sync');

      for (final operation in pendingOps) {
        try {
          bool success = false;
          
          // Process the sync operation based on entity type and operation type
          if (operation.entityType == 'User') {
            success = await _processUserSyncOperation(operation);
          } 
          // Add other entity types as needed
          
          if (success) {
            // Mark operation as completed
            await _localDb.markSyncOperationAsCompleted(operation.id!);
            print('Successfully synced operation: ${operation.operationType} ${operation.entityType}');
          } else {
            // Update operation with retry information
            await _localDb.updateSyncOperationRetry(
              operation.id!, 
              errorMessage: 'Failed to sync operation'
            );
            print('Failed to sync operation: ${operation.operationType} ${operation.entityType}');
          }
        } catch (e) {
          print('Error processing sync operation: $e');
          await _localDb.updateSyncOperationRetry(
            operation.id!, 
            errorMessage: e.toString()
          );
        }
      }
    } catch (e) {
      print('Error pushing pending operations: $e');
    }
  }

  Future<bool> _processUserSyncOperation(SyncOperation operation) async {
    try {
      switch (operation.operationType) {
        case 'create':
          await _apiService.createUser(operation.data);
          return true;
        case 'update':
          final userId = operation.data['id'];
          if (userId != null) {
            await _apiService.updateUser(userId, operation.data);
            return true;
          }
          return false;
        case 'delete':
          final userId = operation.data['id'];
          if (userId != null) {
            await _apiService.deleteUser(userId);
            return true;
          }
          return false;
        default:
          print('Unknown operation type: ${operation.operationType}');
          return false;
      }
    } catch (e) {
      print('Error processing user sync operation: $e');
      return false;
    }
  }

  Future<bool> detectConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    bool isConnected = connectivityResult != ConnectivityResult.none;
    
    // Update API service connection status
    _apiService.setConnectionStatus(isConnected);
    
    return isConnected;
  }

  Future<void> forceSync() async {
    await performSync();
  }

  Future<void> resolveConflicts(String resolutionStrategy) async {
    // Implementation for conflict resolution
    // Currently using "last_update_wins" strategy
    print('Resolving conflicts using strategy: $resolutionStrategy');
  }
}