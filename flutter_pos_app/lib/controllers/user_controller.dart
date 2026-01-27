import 'package:get/get.dart';
import '../models/user.dart';
import '../services/local_database.dart';
import '../services/api_service.dart';
import '../models/sync_operation.dart';

class UserController extends GetxController {
  final LocalDatabase _localDb = LocalDatabase();
  final ApiService _apiService = ApiService();
  
  final RxList<User> _users = <User>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  List<User> get users => _users.toList();
  RxList<User> get usersObs => _users;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    loadLocalUsers();
  }

  Future<void> loadLocalUsers() async {
    _isLoading.value = true;
    try {
      final localUsers = await _localDb.getUsersLocal();
      _users.assignAll(localUsers);
    } catch (e) {
      _errorMessage.value = 'Error loading local users: $e';
      print(_errorMessage.value);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> syncUsersFromApi() async {
    if (!_apiService.isConnected) return;
    
    try {
      final serverUsers = await _apiService.getUsers();
      
      // Update local database with server data
      for (final serverUser in serverUsers) {
        final existingUser = _users.firstWhereOrNull((user) => user.id == serverUser.id);
        
        if (existingUser != null) {
          // Check if we need to update based on updated_at timestamp
          if (serverUser.updatedAt.isAfter(existingUser.updatedAt)) {
            // Update local user
            await _localDb.updateUserLocal(
              _findLocalIdForServerUser(serverUser.id!), 
              serverUser
            );
          }
        } else {
          // Add new user locally
          await _localDb.insertUserLocal(serverUser, syncStatus: 'synced');
        }
      }
      
      // Reload local users after sync
      await loadLocalUsers();
    } catch (e) {
      _errorMessage.value = 'Error syncing users: $e';
      print(_errorMessage.value);
    }
  }

  // Find the local ID for a server user by searching the database
  Future<String> _findLocalIdForServerUser(String serverUserId) async {
    // This is a simplified approach - in a real implementation, you would 
    // store the mapping between server and local IDs
    final db = await _localDb.database;
    final result = await db.query(
      'users_local',
      columns: ['local_id'],
      where: 'server_id = ?',
      whereArgs: [serverUserId],
    );
    
    if (result.isNotEmpty) {
      return result.first['local_id'] as String;
    }
    throw Exception('Local ID not found for server user: $serverUserId');
  }

  Future<bool> createUserLocal(User user) async {
    _isLoading.value = true;
    try {
      // Insert user into local database
      await _localDb.insertUserLocal(user);
      
      // Create sync operation for later sync to server
      final syncOp = SyncOperation(
        entityType: 'User',
        operationType: 'create',
        data: user.toMap(),
        createdAt: DateTime.now(),
      );
      await _localDb.insertSyncOperation(syncOp);
      
      // Reload users
      await loadLocalUsers();
      
      return true;
    } catch (e) {
      _errorMessage.value = 'Error creating user: $e';
      print(_errorMessage.value);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateUserLocal(String localId, User user) async {
    _isLoading.value = true;
    try {
      // Update user in local database
      await _localDb.updateUserLocal(localId, user);
      
      // Create sync operation for later sync to server
      final syncOp = SyncOperation(
        entityType: 'User',
        operationType: 'update',
        data: user.toMap(),
        createdAt: DateTime.now(),
      );
      await _localDb.insertSyncOperation(syncOp);
      
      // Reload users
      await loadLocalUsers();
      
      return true;
    } catch (e) {
      _errorMessage.value = 'Error updating user: $e';
      print(_errorMessage.value);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> deleteUserLocal(String localId) async {
    _isLoading.value = true;
    try {
      // Deactivate user in local database (soft delete)
      await _localDb.deactivateUserLocal(localId);
      
      // Get the user to include in sync operation
      final user = await _localDb.getUserByLocalId(localId);
      if (user != null) {
        // Create sync operation for later sync to server
        final syncOp = SyncOperation(
          entityType: 'User',
          operationType: 'delete',
          data: {'id': user.id},
          createdAt: DateTime.now(),
        );
        await _localDb.insertSyncOperation(syncOp);
      }
      
      // Reload users
      await loadLocalUsers();
      
      return true;
    } catch (e) {
      _errorMessage.value = 'Error deleting user: $e';
      print(_errorMessage.value);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<User?> getUserByPin(String pin) async {
    return await _localDb.getUserByPin(pin);
  }

  Future<void> refreshData() async {
    await loadLocalUsers();
    if (_apiService.isConnected) {
      await syncUsersFromApi();
    }
  }
}