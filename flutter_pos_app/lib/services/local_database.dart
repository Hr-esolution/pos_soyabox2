import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'dart:io';
import '../models/user.dart';
import '../models/sync_operation.dart';
import '../helpers/database_helper.dart';

class LocalDatabase {
  static DatabaseHelper? _databaseHelper;

  static DatabaseHelper get databaseHelper {
    _databaseHelper ??= DatabaseHelper();
    return _databaseHelper!;
  }

  // User operations - delegate to DatabaseHelper
  Future<int> insertUserLocal(User user, {String? localId, String syncStatus = 'pending'}) async {
    return await databaseHelper.insertUserLocal(user, localId: localId, syncStatus: syncStatus);
  }

  Future<int> updateUserLocal(String localId, User user) async {
    return await databaseHelper.updateUserLocal(localId, user);
  }

  Future<int> deactivateUserLocal(String localId) async {
    return await databaseHelper.deactivateUserLocal(localId);
  }

  Future<List<User>> getUsersLocal() async {
    return await databaseHelper.getUsersLocal();
  }

  Future<User?> getUserByLocalId(String localId) async {
    return await databaseHelper.getUserByLocalId(localId);
  }

  Future<User?> getUserByPin(String pin) async {
    return await databaseHelper.getUserByPin(pin);
  }

  // Sync operations - delegate to DatabaseHelper
  Future<int> insertSyncOperation(SyncOperation operation) async {
    return await databaseHelper.insertSyncOperation(operation);
  }

  Future<List<SyncOperation>> getPendingSyncOperations() async {
    return await databaseHelper.getPendingSyncOperations();
  }

  Future<int> markSyncOperationAsCompleted(String operationId) async {
    return await databaseHelper.markSyncOperationAsCompleted(operationId);
  }

  Future<int> updateSyncOperationRetry(String operationId, {String? errorMessage}) async {
    return await databaseHelper.updateSyncOperationRetry(operationId, errorMessage: errorMessage);
  }

  Future<void> close() async {
    await databaseHelper.close();
  }
}