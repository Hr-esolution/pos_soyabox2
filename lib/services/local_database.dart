import 'dart:async';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import '../models/sync_operation.dart';

part 'local_database.g.dart';

@Collection()
class IsarUser {
  Id? id;
  String? localId;
  int? serverId;
  String name = '';
  String phone = '';
  String role = '';
  String pin = '';
  bool isActive = true;
  DateTime updatedAt = DateTime.now();
  String syncStatus = 'synced';

  IsarUser({
    this.id,
    this.localId,
    this.serverId,
    required this.name,
    required this.phone,
    required this.role,
    required this.pin,
    required this.isActive,
    required this.updatedAt,
    required this.syncStatus,
  });

  factory IsarUser.fromUser(User user) {
    return IsarUser(
      id: user.localId != null ? Isar.hash(user.localId!) : null,
      localId: user.localId,
      serverId: user.serverId,
      name: user.name,
      phone: user.phone,
      role: user.role,
      pin: user.pin,
      isActive: user.isActive,
      updatedAt: user.updatedAt,
      syncStatus: user.syncStatus,
    );
  }

  User toUser() {
    return User(
      localId: localId,
      serverId: serverId,
      name: name,
      phone: phone,
      role: role,
      pin: pin,
      isActive: isActive,
      updatedAt: updatedAt,
      syncStatus: syncStatus,
    );
  }
}

@Collection()
class IsarSyncOperation {
  Id? id;
  String operationType = '';
  String entityType = '';
  String data = '';
  Map<String, dynamic>? metadata;
  DateTime createdAt = DateTime.now();
  DateTime? syncedAt;
  String? errorMessage;
  int retryCount = 0;
  DateTime? nextRetryAt;
  bool isCompleted = false;

  IsarSyncOperation({
    this.id,
    required this.operationType,
    required this.entityType,
    required this.data,
    this.metadata,
    required this.createdAt,
    this.syncedAt,
    this.errorMessage,
    required this.retryCount,
    this.nextRetryAt,
    required this.isCompleted,
  });

  factory IsarSyncOperation.fromSyncOperation(SyncOperation operation) {
    return IsarSyncOperation(
      id: operation.id != null ? operation.id : null,
      operationType: operation.operationType,
      entityType: operation.entityType,
      data: operation.data,
      metadata: operation.metadata,
      createdAt: operation.createdAt,
      syncedAt: operation.syncedAt,
      errorMessage: operation.errorMessage,
      retryCount: operation.retryCount,
      nextRetryAt: operation.nextRetryAt,
      isCompleted: operation.isCompleted,
    );
  }

  SyncOperation toSyncOperation() {
    return SyncOperation(
      id: id,
      operationType: operationType,
      entityType: entityType,
      data: data,
      metadata: metadata,
      createdAt: createdAt,
      syncedAt: syncedAt,
      errorMessage: errorMessage,
      retryCount: retryCount,
      nextRetryAt: nextRetryAt,
      isCompleted: isCompleted,
    );
  }
}

class LocalDatabase {
  static Isar? _isar;
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();

  Future<Isar> get isar async {
    if (_isar != null) return _isar!;
    _isar = await openDb();
    return _isar!;
  }

  Future<Isar> openDb() async {
    if (!await Isar.getDirectory().exists()) {
      await getApplicationDocumentsDirectory();
    }
    
    return await Isar.open(
      [IsarUserSchema, IsarSyncOperationSchema],
      directory: await getApplicationDocumentsDirectory().then((dir) => dir.path),
      inspector: true,
    );
  }

  // Users Local Operations
  Future<int> insertUserLocal(User user) async {
    final isar = await this.isar;
    final isarUser = IsarUser.fromUser(user);
    
    return await isar.writeTxn(() async {
      final id = await isar.isarUsers.put(isarUser);
      return id.toInt();
    });
  }

  Future<List<User>> getUsersLocal() async {
    final isar = await this.isar;
    final isarUsers = await isar.isarUsers.where().findAll();
    return isarUsers.map((u) => u.toUser()).toList();
  }

  Future<User?> getUserLocalById(String localId) async {
    final isar = await this.isar;
    final isarUser = await isar.isarUsers.where().filter().localIdEqualTo(localId).findFirst();
    return isarUser?.toUser();
  }

  Future<User?> getUserLocalByServerId(int serverId) async {
    final isar = await this.isar;
    final isarUser = await isar.isarUsers.where().filter().serverIdEqualTo(serverId).findFirst();
    return isarUser?.toUser();
  }

  Future<int> updateUserLocal(User user) async {
    final isar = await this.isar;
    final isarUser = IsarUser.fromUser(user);
    
    return await isar.writeTxn(() async {
      final id = await isar.isarUsers.put(isarUser);
      return id.toInt();
    });
  }

  Future<int> deleteUserLocal(String localId) async {
    final isar = await this.isar;
    
    return await isar.writeTxn(() async {
      final deleted = await isar.isarUsers.where().filter().localIdEqualTo(localId).deleteFirst();
      return deleted ? 1 : 0;
    });
  }

  // Sync Operations
  Future<int> insertSyncOperation(SyncOperation operation) async {
    final isar = await this.isar;
    final isarOperation = IsarSyncOperation.fromSyncOperation(operation);
    
    return await isar.writeTxn(() async {
      final id = await isar.isarSyncOperations.put(isarOperation);
      return id.toInt();
    });
  }

  Future<List<SyncOperation>> getPendingSyncOperations() async {
    final isar = await this.isar;
    final isarOperations = await isar.isarSyncOperations.where().filter().isCompletedEqualTo(false).sortByCreatedAt().findAll();
    return isarOperations.map((op) => op.toSyncOperation()).toList();
  }

  Future<int> markSyncOperationAsCompleted(int id) async {
    final isar = await this.isar;
    
    return await isar.writeTxn(() async {
      final operation = await isar.isarSyncOperations.where().filter().idEqualTo(id).findFirst();
      if (operation != null) {
        operation.isCompleted = true;
        operation.syncedAt = DateTime.now();
        await isar.isarSyncOperations.put(operation);
        return 1;
      }
      return 0;
    });
  }

  Future<int> updateSyncOperationError(int id, String errorMessage) async {
    final isar = await this.isar;
    
    return await isar.writeTxn(() async {
      final operation = await isar.isarSyncOperations.where().filter().idEqualTo(id).findFirst();
      if (operation != null) {
        operation.errorMessage = errorMessage;
        operation.retryCount = operation.retryCount + 1;
        operation.nextRetryAt = DateTime.now().add(Duration(minutes: 5));
        await isar.isarSyncOperations.put(operation);
        return 1;
      }
      return 0;
    });
  }

  Future<void> clearSyncOperations() async {
    final isar = await this.isar;
    await isar.writeTxn(() async {
      await isar.isarSyncOperations.clear();
    });
  }

  // Close the database
  Future<void> close() async {
    final isar = await this.isar;
    isar.close();
  }
}