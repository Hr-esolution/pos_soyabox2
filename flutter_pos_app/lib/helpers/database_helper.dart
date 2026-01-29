import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../models/user.dart';
import '../models/sync_operation.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pos_database.db');
    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createTables,
      ),
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Create users_local table
    await db.execute('''
      CREATE TABLE users_local (
        local_id TEXT PRIMARY KEY,
        server_id TEXT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        role TEXT NOT NULL,
        pin TEXT NOT NULL,
        is_active INTEGER NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending'
      )
    ''');

    // Create sync_operations table
    await db.execute('''
      CREATE TABLE sync_operations (
        id TEXT PRIMARY KEY,
        entity_type TEXT NOT NULL,
        operation_type TEXT NOT NULL,
        data TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL,
        synced_at TEXT,
        error_message TEXT,
        retry_count INTEGER DEFAULT 0,
        next_retry_at TEXT,
        is_completed INTEGER DEFAULT 0
      )
    ''');
  }

  // User operations
  Future<int> insertUserLocal(User user, {String? localId, String syncStatus = 'pending'}) async {
    final db = await database;
    String userId = localId ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    return await db.insert('users_local', {
      'local_id': userId,
      'server_id': user.id,
      'name': user.name,
      'phone': user.phone,
      'role': user.role,
      'pin': user.pin,
      'is_active': user.isActive ? 1 : 0,
      'updated_at': user.updatedAt.toIso8601String(),
      'sync_status': syncStatus,
    });
  }

  Future<int> updateUserLocal(String localId, User user) async {
    final db = await database;
    return await db.update(
      'users_local',
      {
        'name': user.name,
        'phone': user.phone,
        'role': user.role,
        'pin': user.pin,
        'is_active': user.isActive ? 1 : 0,
        'updated_at': user.updatedAt.toIso8601String(),
        'sync_status': 'updated',
      },
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  Future<int> deactivateUserLocal(String localId) async {
    final db = await database;
    return await db.update(
      'users_local',
      {
        'is_active': 0,
        'sync_status': 'deleted',
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  Future<List<User>> getUsersLocal() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users_local', orderBy: 'name');

    return List.generate(maps.length, (i) {
      return User(
        id: maps[i]['server_id'],
        name: maps[i]['name'],
        phone: maps[i]['phone'],
        role: maps[i]['role'],
        pin: maps[i]['pin'],
        isActive: maps[i]['is_active'] == 1,
        updatedAt: DateTime.parse(maps[i]['updated_at']),
      );
    });
  }

  Future<User?> getUserByLocalId(String localId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users_local',
      where: 'local_id = ?',
      whereArgs: [localId],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return User(
        id: map['server_id'],
        name: map['name'],
        phone: map['phone'],
        role: map['role'],
        pin: map['pin'],
        isActive: map['is_active'] == 1,
        updatedAt: DateTime.parse(map['updated_at']),
      );
    }
    return null;
  }

  Future<User?> getUserByPin(String pin) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users_local',
      where: 'pin = ? AND is_active = 1',
      whereArgs: [pin],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return User(
        id: map['server_id'],
        name: map['name'],
        phone: map['phone'],
        role: map['role'],
        pin: map['pin'],
        isActive: map['is_active'] == 1,
        updatedAt: DateTime.parse(map['updated_at']),
      );
    }
    return null;
  }

  // Sync operations
  Future<int> insertSyncOperation(SyncOperation operation) async {
    final db = await database;
    String operationId = operation.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    return await db.insert('sync_operations', {
      'id': operationId,
      'entity_type': operation.entityType,
      'operation_type': operation.operationType,
      'data': jsonEncode(operation.data),
      'metadata': operation.metadata != null ? jsonEncode(operation.metadata) : null,
      'created_at': operation.createdAt.toIso8601String(),
      'synced_at': operation.syncedAt?.toIso8601String(),
      'error_message': operation.errorMessage,
      'retry_count': operation.retryCount,
      'next_retry_at': operation.nextRetryAt?.toIso8601String(),
      'is_completed': operation.isCompleted ? 1 : 0,
    });
  }

  Future<List<SyncOperation>> getPendingSyncOperations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sync_operations',
      where: 'is_completed = 0',
      orderBy: 'created_at ASC',
    );

    return List.generate(maps.length, (i) {
      final data = jsonDecode(maps[i]['data'] as String);
      
      final metadata = maps[i]['metadata'] != null 
          ? jsonDecode(maps[i]['metadata'] as String) 
          : null;

      return SyncOperation(
        id: maps[i]['id'],
        entityType: maps[i]['entity_type'],
        operationType: maps[i]['operation_type'],
        data: data,
        metadata: metadata,
        createdAt: DateTime.parse(maps[i]['created_at']),
        syncedAt: maps[i]['synced_at'] != null ? DateTime.parse(maps[i]['synced_at']) : null,
        errorMessage: maps[i]['error_message'],
        retryCount: maps[i]['retry_count'],
        nextRetryAt: maps[i]['next_retry_at'] != null ? DateTime.parse(maps[i]['next_retry_at']) : null,
        isCompleted: maps[i]['is_completed'] == 1,
      );
    });
  }

  Future<int> markSyncOperationAsCompleted(String operationId) async {
    final db = await database;
    return await db.update(
      'sync_operations',
      {'is_completed': 1, 'synced_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [operationId],
    );
  }

  Future<int> updateSyncOperationRetry(String operationId, {String? errorMessage}) async {
    final db = await database;
    return await db.update(
      'sync_operations',
      {
        'retry_count': 1, // Increment retry count
        'error_message': errorMessage,
        'next_retry_at': DateTime.now().add(Duration(minutes: 5)).toIso8601String(), // Retry in 5 minutes
      },
      where: 'id = ?',
      whereArgs: [operationId],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}