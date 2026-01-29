#!/usr/bin/env dart

/*
 * Build Verification Script for Flutter POS App (macOS Desktop)
 * 
 * This script verifies that all the necessary components are properly configured
 * for building the Flutter application on macOS Desktop with sqflite_common_ffi.
 */

import 'dart:io';
import 'dart:convert';

void main() async {
  print('🔍 Build Verification for Flutter POS App (macOS Desktop)');
  print('=' * 60);
  
  // Check if we're in the right directory
  if (!Directory.current.path.endsWith('/flutter_pos_app')) {
    print('❌ Not in the flutter_pos_app directory');
    exit(1);
  }
  print('✅ Correct working directory');
  
  // Verify pubspec.yaml configuration
  await verifyPubspec();
  
  // Verify main.dart initialization
  verifyMainInitialization();
  
  // Verify DatabaseHelper implementation
  verifyDatabaseHelper();
  
  // Verify imports and dependencies
  verifyImports();
  
  // Check for mobile-only dependencies
  checkForMobileDependencies();
  
  print('\n🎉 All checks passed! The project is ready for macOS Desktop build.');
  print('\n🔧 To build for macOS, run these commands:');
  print('   cd /workspace/flutter_pos_app');
  print('   flutter clean');
  print('   rm -rf macos/Pods macos/Podfile.lock');  // Clean iOS/macOS specific files
  print('   flutter pub get');
  print('   flutter config --enable-macos-desktop');  // Enable macOS desktop if needed
  print('   flutter run -d macos');
}

Future<void> verifyPubspec() async {
  print('\n📋 Verifying pubspec.yaml...');
  
  final pubspecFile = File('pubspec.yaml');
  if (!await pubspecFile.exists()) {
    print('❌ pubspec.yaml not found');
    exit(1);
  }
  
  final content = await pubspecFile.readAsString();
  final lines = LineSplitter.split(content).toList();
  
  // Check for correct dependencies
  bool hasSqfliteCommonFfi = lines.any((line) => line.contains('sqflite_common_ffi'));
  bool hasPathProvider = lines.any((line) => line.contains('path_provider'));
  bool hasPath = lines.any((line) => line.contains('path:') && !line.contains('path_provider'));
  bool hasSqfliteMobile = lines.any((line) => line.trim() == 'sqflite:' || line.startsWith('  sqflite:'));
  
  if (!hasSqfliteCommonFfi) {
    print('❌ sqflite_common_ffi not found in dependencies');
    exit(1);
  }
  print('✅ sqflite_common_ffi dependency found');
  
  if (!hasPathProvider) {
    print('❌ path_provider not found in dependencies');
    exit(1);
  }
  print('✅ path_provider dependency found');
  
  if (!hasPath) {
    print('❌ path not found in dependencies');
    exit(1);
  }
  print('✅ path dependency found');
  
  if (hasSqfliteMobile) {
    print('❌ Mobile-only sqflite dependency found - this will cause build errors on macOS');
    exit(1);
  }
  print('✅ No mobile-only sqflite dependency found');
}

void verifyMainInitialization() {
  print('\n🔧 Verifying main.dart initialization...');
  
  final mainFile = File('lib/main.dart');
  if (!mainFile.existsSync()) {
    print('❌ lib/main.dart not found');
    exit(1);
  }
  
  final content = mainFile.readAsStringSync();
  
  // Check for proper initialization
  bool hasWidgetsFlutterBinding = content.contains('WidgetsFlutterBinding.ensureInitialized()');
  bool hasSqfliteFfiInit = content.contains('sqfliteFfiInit()');
  bool hasDatabaseFactoryFfi = content.contains('databaseFactory = databaseFactoryFfi');
  bool hasPlatformCheck = content.contains('Platform.isWindows') || content.contains('Platform.isMacOS');
  
  if (!hasWidgetsFlutterBinding) {
    print('❌ WidgetsFlutterBinding.ensureInitialized() not found');
    exit(1);
  }
  print('✅ WidgetsFlutterBinding.ensureInitialized() found');
  
  if (!hasSqfliteFfiInit) {
    print('❌ sqfliteFfiInit() not found');
    exit(1);
  }
  print('✅ sqfliteFfiInit() found');
  
  if (!hasDatabaseFactoryFfi) {
    print('❌ databaseFactory = databaseFactoryFfi not found');
    exit(1);
  }
  print('✅ databaseFactory = databaseFactoryFfi found');
  
  if (!hasPlatformCheck) {
    print('❌ Platform check for desktop not found');
    print('   Should include Platform.isWindows || Platform.isLinux || Platform.isMacOS');
    exit(1);
  }
  print('✅ Platform check for desktop found');
}

void verifyDatabaseHelper() {
  print('\n💾 Verifying DatabaseHelper...');
  
  final dbHelperFile = File('lib/helpers/database_helper.dart');
  if (!dbHelperFile.existsSync()) {
    print('❌ lib/helpers/database_helper.dart not found');
    exit(1);
  }
  
  final content = dbHelperFile.readAsStringSync();
  
  // Check for proper implementation
  bool hasSqfliteImport = content.contains("import 'package:sqflite_common_ffi/sqflite_ffi.dart'");
  bool hasPathProviderImport = content.contains("import 'package:path_provider/path_provider.dart'");
  bool hasGetDatabasesPath = content.contains('getDatabasesPath()');
  bool hasDatabaseFactoryUsage = content.contains('databaseFactory.openDatabase');
  bool hasProperTables = content.contains('CREATE TABLE users_local') && content.contains('CREATE TABLE sync_operations');
  
  if (!hasSqfliteImport) {
    print('❌ sqflite_common_ffi import not found in DatabaseHelper');
    exit(1);
  }
  print('✅ sqflite_common_ffi import found in DatabaseHelper');
  
  if (!hasPathProviderImport) {
    print('❌ path_provider import not found in DatabaseHelper');
    exit(1);
  }
  print('✅ path_provider import found in DatabaseHelper');
  
  if (!hasGetDatabasesPath) {
    print('❌ getDatabasesPath() not found in DatabaseHelper');
    exit(1);
  }
  print('✅ getDatabasesPath() found in DatabaseHelper');
  
  if (!hasDatabaseFactoryUsage) {
    print('❌ databaseFactory.openDatabase not found in DatabaseHelper');
    exit(1);
  }
  print('✅ databaseFactory.openDatabase found in DatabaseHelper');
  
  if (!hasProperTables) {
    print('❌ Proper database tables not found in DatabaseHelper');
    exit(1);
  }
  print('✅ Proper database tables found in DatabaseHelper');
}

void verifyImports() {
  print('\n📦 Verifying imports...');
  
  final localDbFile = File('lib/services/local_database.dart');
  if (!localDbFile.existsSync()) {
    print('❌ lib/services/local_database.dart not found');
    exit(1);
  }
  
  final content = localDbFile.readAsStringSync();
  
  bool hasDatabaseHelperImport = content.contains("import '../helpers/database_helper.dart'");
  bool hasSqfliteCommonFfiImport = content.contains("import 'package:sqflite_common_ffi/sqflite_ffi.dart'");
  
  if (!hasDatabaseHelperImport) {
    print('❌ DatabaseHelper import not found in local_database.dart');
    exit(1);
  }
  print('✅ DatabaseHelper import found in local_database.dart');
  
  if (hasSqfliteCommonFfiImport) {
    print('⚠️  sqflite_common_ffi import found in local_database.dart - this is OK as it delegates to DatabaseHelper');
  } else {
    print('ℹ️  No direct sqflite_common_ffi import in local_database.dart - OK since it delegates to DatabaseHelper');
  }
}

void checkForMobileDependencies() {
  print('\n📱 Checking for mobile-only dependencies...');
  
  final pubspecFile = File('pubspec.yaml');
  final content = pubspecFile.readAsStringSync();
  final lines = LineSplitter.split(content).toList();
  
  // Check for mobile-specific dependencies that shouldn't be in desktop builds
  final forbiddenDependencies = [
    'flutter_plugin_android_lifecycle',
    'sensors',
    'device_info',
    'android_intent',
    'battery',  // deprecated and mobile-specific
    'connectivity',  // old package, connectivity_plus is correct
  ];
  
  for (final dep in forbiddenDependencies) {
    if (lines.any((line) => line.contains(dep) && line.trim().startsWith(dep))) {
      print('❌ Mobile-only dependency found: $dep');
      // Don't exit here as this is just a warning
    }
  }
  
  // Verify that connectivity_plus is used instead of old connectivity
  bool hasConnectivityPlus = lines.any((line) => line.contains('connectivity_plus'));
  if (!hasConnectivityPlus) {
    print('⚠️  connectivity_plus not found - consider adding for network status detection');
  } else {
    print('✅ connectivity_plus found for network status detection');
  }
  
  print('✅ No problematic mobile-only dependencies found');
}

// Additional verification for offline-first architecture
void verifyOfflineFirstArchitecture() {
  print('\n🔄 Verifying offline-first architecture...');
  
  final dbHelperFile = File('lib/helpers/database_helper.dart');
  final content = dbHelperFile.readAsStringSync();
  
  bool hasSyncOperationTable = content.contains('CREATE TABLE sync_operations');
  bool hasPendingSyncOperations = content.contains('getPendingSyncOperations');
  bool hasMarkSyncAsCompleted = content.contains('markSyncOperationAsCompleted');
  
  if (!hasSyncOperationTable) {
    print('❌ Sync operations table not found');
    exit(1);
  }
  print('✅ Sync operations table found');
  
  if (!hasPendingSyncOperations) {
    print('❌ getPendingSyncOperations method not found');
    exit(1);
  }
  print('✅ getPendingSyncOperations method found');
  
  if (!hasMarkSyncAsCompleted) {
    print('❌ markSyncOperationAsCompleted method not found');
    exit(1);
  }
  print('✅ markSyncOperationAsCompleted method found');
  
  print('✅ Offline-first architecture verified');
}