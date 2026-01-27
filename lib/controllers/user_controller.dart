import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../services/local_database.dart';
import '../models/sync_operation.dart';
import '../constants/app_constants.dart';
import '../services/api_service.dart';

class UserController extends GetxController {
  final RxList<User> users = <User>[].obs;
  final LocalDatabase _localDatabase = LocalDatabase();
  final ApiService _apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    loadLocalUsers();
  }

  Future<void> loadLocalUsers() async {
    try {
      final localUsers = await _localDatabase.getUsersLocal();
      users.assignAll(localUsers);
    } catch (e) {
      print('Error loading local users: $e');
    }
  }

  Future<bool> createUserLocal({
    required String name,
    required String phone,
    required String role,
    required String pin,
  }) async {
    try {
      final user = User(
        localId: Uuid().v4(),
        name: name,
        phone: phone,
        role: role,
        pin: pin,
        isActive: true,
        updatedAt: DateTime.now(),
        syncStatus: AppConstants.syncStatusPending,
      );

      await _localDatabase.insertUserLocal(user);
      
      // Add to sync operations
      final syncOp = SyncOperation(
        operationType: AppConstants.operationCreate,
        entityType: AppConstants.entityUser,
        data: user.toJson().toString(),
        createdAt: DateTime.now(),
      );
      await _localDatabase.insertSyncOperation(syncOp);
      
      users.add(user);
      return true;
    } catch (e) {
      print('Error creating local user: $e');
      return false;
    }
  }

  Future<bool> updateUserLocal(User user) async {
    try {
      final updatedUser = user.copyWith(
        updatedAt: DateTime.now(),
        syncStatus: AppConstants.syncStatusUpdated,
      );

      await _localDatabase.updateUserLocal(updatedUser);
      
      // Add to sync operations
      final syncOp = SyncOperation(
        operationType: AppConstants.operationUpdate,
        entityType: AppConstants.entityUser,
        data: updatedUser.toJson().toString(),
        createdAt: DateTime.now(),
      );
      await _localDatabase.insertSyncOperation(syncOp);
      
      final index = users.indexWhere((u) => u.localId == user.localId);
      if (index != -1) {
        users[index] = updatedUser;
      }
      
      return true;
    } catch (e) {
      print('Error updating local user: $e');
      return false;
    }
  }

  Future<bool> deleteUserLocal(String localId) async {
    try {
      final user = users.firstWhere((u) => u.localId == localId);
      final updatedUser = user.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
        syncStatus: AppConstants.syncStatusDeleted,
      );

      await _localDatabase.updateUserLocal(updatedUser);
      
      // Add to sync operations
      final syncOp = SyncOperation(
        operationType: AppConstants.operationDelete,
        entityType: AppConstants.entityUser,
        data: updatedUser.toJson().toString(),
        createdAt: DateTime.now(),
      );
      await _localDatabase.insertSyncOperation(syncOp);
      
      users.removeWhere((u) => u.localId == localId);
      return true;
    } catch (e) {
      print('Error deleting local user: $e');
      return false;
    }
  }

  Future<void> syncUsersFromApi() async {
    try {
      final response = await _apiService.getUsers();
      if (response.success) {
        final serverUsers = response.data as List<User>;
        
        for (final serverUser in serverUsers) {
          final existingLocalUser = await _localDatabase.getUserLocalByServerId(serverUser.serverId!);
          
          if (existingLocalUser == null) {
            // New user from server, add locally
            final localUser = User(
              localId: Uuid().v4(),
              serverId: serverUser.serverId,
              name: serverUser.name,
              phone: serverUser.phone,
              role: serverUser.role,
              pin: serverUser.pin,
              isActive: serverUser.isActive,
              updatedAt: serverUser.updatedAt,
              syncStatus: AppConstants.syncStatusSynced,
            );
            await _localDatabase.insertUserLocal(localUser);
          } else {
            // Update existing user if server is newer
            if (serverUser.updatedAt.isAfter(existingLocalUser.updatedAt)) {
              final updatedUser = existingLocalUser.copyWith(
                serverId: serverUser.serverId,
                name: serverUser.name,
                phone: serverUser.phone,
                role: serverUser.role,
                pin: serverUser.pin,
                isActive: serverUser.isActive,
                updatedAt: serverUser.updatedAt,
                syncStatus: AppConstants.syncStatusSynced,
              );
              await _localDatabase.updateUserLocal(updatedUser);
            }
          }
        }
        
        // Reload local users
        loadLocalUsers();
      }
    } catch (e) {
      print('Error syncing users from API: $e');
    }
  }

  User? getCurrentUser() {
    // Implementation depends on how current user is stored
    // This is just a placeholder - would typically get from auth controller
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  List<User> getActiveServers() {
    return users.where((user) => user.isServer && user.isActive).toList();
  }

  List<User> getActiveAdmins() {
    return users.where((user) => user.isAdmin && user.isActive).toList();
  }
}