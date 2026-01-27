import 'dart:async';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/sync_operation.dart';
import '../models/user.dart';
import '../services/local_database.dart';
import '../services/api_service.dart';
import '../constants/app_constants.dart';

class SyncService extends GetxService {
  final LocalDatabase _localDatabase = LocalDatabase();
  final ApiService _apiService = ApiService();
  Timer? _syncTimer;

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

  Future<void> startPeriodicSync() async {
    _syncTimer = Timer.periodic(AppConstants.syncInterval, (timer) async {
      if (await isConnected()) {
        await performSync();
      }
    });
  }

  Future<bool> isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> performSync() async {
    try {
      // Push pending operations to server
      await pushPendingOperations();
      
      // Pull updates from server
      await pullServerUpdates();
    } catch (e) {
      print('Sync error: $e');
    }
  }

  Future<void> pushPendingOperations() async {
    final pendingOperations = await _localDatabase.getPendingSyncOperations();
    
    if (pendingOperations.isEmpty) return;

    for (final operation in pendingOperations) {
      try {
        bool success = false;
        
        // Process the operation based on type and entity
        switch (operation.entityType) {
          case AppConstants.entityUser:
            success = await _processUserOperation(operation);
            break;
          case AppConstants.entityOrder:
            success = await _processOrderOperation(operation);
            break;
          case AppConstants.entityProduct:
            success = await _processProductOperation(operation);
            break;
        }

        if (success) {
          await _localDatabase.markSyncOperationAsCompleted(operation.id!);
        } else {
          await _localDatabase.updateSyncOperationError(operation.id!, 'Failed to sync operation');
        }
      } catch (e) {
        await _localDatabase.updateSyncOperationError(operation.id!, e.toString());
      }
    }
  }

  Future<bool> _processUserOperation(SyncOperation operation) async {
    // Parse the operation data
    final userData = operation.data; // This should be parsed from the JSON string
    
    try {
      switch (operation.operationType) {
        case AppConstants.operationCreate:
          // For create operations, parse the user data and send to API
          // This is simplified - in reality you'd need to parse the JSON string
          // and extract the proper user object
          break;
        case AppConstants.operationUpdate:
          // For update operations
          break;
        case AppConstants.operationDelete:
          // For delete operations
          break;
      }
      return true;
    } catch (e) {
      print('Error processing user operation: $e');
      return false;
    }
  }

  Future<bool> _processOrderOperation(SyncOperation operation) async {
    try {
      // Similar logic for orders
      return true;
    } catch (e) {
      print('Error processing order operation: $e');
      return false;
    }
  }

  Future<bool> _processProductOperation(SyncOperation operation) async {
    try {
      // Similar logic for products
      return true;
    } catch (e) {
      print('Error processing product operation: $e');
      return false;
    }
  }

  Future<void> pullServerUpdates() async {
    // This would involve calling the API to get the latest data
    // and comparing with local data to identify conflicts
    // For now, just a placeholder
  }

  Future<void> syncUsers() async {
    // Specific method to sync user data
    try {
      // Get current token from somewhere (auth controller)
      // final token = // get from auth controller
      
      // Get pending user operations
      final pendingOperations = await _localDatabase.getPendingSyncOperations();
      final userOperations = pendingOperations
          .where((op) => op.entityType == AppConstants.entityUser)
          .toList();

      for (final operation in userOperations) {
        try {
          // Parse the user data from the operation
          // This is a simplified approach - in practice you'd need to parse the JSON string
          // and convert it back to a user object
          final Map<String, dynamic> userData = {};
          
          bool success = false;
          switch (operation.operationType) {
            case AppConstants.operationCreate:
              // final result = await _apiService.createUser(userData, token);
              // success = result.success;
              break;
            case AppConstants.operationUpdate:
              // final result = await _apiService.updateUser(userData['id'], userData, token);
              // success = result.success;
              break;
            case AppConstants.operationDelete:
              // final result = await _apiService.deleteUser(userData['id'], token);
              // success = result.success;
              break;
          }

          if (success) {
            await _localDatabase.markSyncOperationAsCompleted(operation.id!);
          } else {
            await _localDatabase.updateSyncOperationError(operation.id!, 'Failed to sync user operation');
          }
        } catch (e) {
          await _localDatabase.updateSyncOperationError(operation.id!, e.toString());
        }
      }
    } catch (e) {
      print('Error syncing users: $e');
    }
  }

  Future<void> queueSyncOperation(String operationType, String entityType, Object data) async {
    final operation = SyncOperation(
      operationType: operationType,
      entityType: entityType,
      data: data.toString(), // In a real implementation, you'd serialize this properly
      createdAt: DateTime.now(),
      isCompleted: false,
    );
    
    await _localDatabase.insertSyncOperation(operation);
  }

  Future<void> forceSync() async {
    await performSync();
  }
}