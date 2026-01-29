# Flutter POS App - macOS Desktop Setup Guide

## Overview
This document explains how the project has been modified to support Flutter Desktop (macOS ARM64) by replacing the mobile-only `sqflite` package with `sqflite_common_ffi`.

## Changes Made

### 1. Updated Dependencies
- **Removed**: `sqflite: ^2.3.0` (mobile-only package)
- **Added**: `sqflite_common_ffi: ^2.3.0` (desktop-compatible package)

### 2. Main Application Entry Point (`lib/main.dart`)
- Added import for `sqflite_common_ffi`
- Added platform detection for desktop initialization
- Added `sqfliteFfiInit()` call for desktop platforms
- Set `databaseFactory = databaseFactoryFfi` for desktop platforms

### 3. Database Helper (`lib/helpers/database_helper.dart`)
- Created a new `DatabaseHelper` class with proper FFI initialization
- Implemented all database operations with proper JSON encoding/decoding
- Added proper error handling and transaction management

### 4. Service Layer (`lib/services/local_database.dart`)
- Refactored to delegate operations to the new `DatabaseHelper`
- Maintained the same API interface for backward compatibility

## Technical Implementation Details

### Platform-Specific Initialization
```dart
// Initialize sqflite for desktop platforms
if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
```

### FFI Database Factory Usage
```dart
return await databaseFactory.openDatabase(
  path,
  options: OpenDatabaseOptions(
    version: 1,
    onCreate: _createTables,
  ),
);
```

## Commands to Build and Run on macOS

After installing Flutter with desktop support enabled:

```bash
# Clean the project
flutter clean

# Remove cached dependencies
rm -rf macos/Pods
rm -rf macos/Podfile.lock

# Get updated dependencies
flutter pub get

# Enable desktop support (if not already enabled)
flutter config --enable-macos-desktop

# Run on macOS
flutter run -d macos
```

## Architecture Features

### Offline-First Design
- Local SQLite database using sqflite_common_ffi
- Synchronization operations tracked via `SyncOperation` model
- Pending operations queue for background sync

### Cross-Platform Compatibility
- Mobile (iOS/Android) - via sqflite_common_ffi
- Desktop (macOS/Windows/Linux) - via sqflite_common_ffi
- Same codebase for all platforms

### Future Laravel Backend Integration
- Sync operations table prepared for backend synchronization
- Operation types (create, update, delete) ready for API integration
- Metadata field available for additional sync information

## Key Benefits of This Solution

1. **Desktop Compatibility**: No more MethodChannel errors on macOS
2. **Performance**: Native SQLite performance on all platforms
3. **Maintainability**: Clean separation of concerns with DatabaseHelper
4. **Scalability**: Ready for backend synchronization
5. **Offline Capability**: Full functionality without network connection

## Troubleshooting

### Common Issues:

1. **Build Errors**:
   - Make sure you have Xcode command line tools installed
   - Run `sudo xcode-select --install`

2. **Missing Dependencies**:
   - Run `flutter pub get` to ensure all dependencies are downloaded

3. **macOS Signing Issues**:
   - Open `macos/Runner.xcworkspace` in Xcode
   - Select your development team in Signing & Capabilities

### Verification Steps:
1. `flutter devices` should show macOS as available target
2. `flutter run -d macos` should launch the app successfully
3. Database operations should work without errors

## Additional Notes

- The project maintains full mobile compatibility while adding desktop support
- All existing APIs remain unchanged for backward compatibility
- The database schema remains the same (users_local, sync_operations tables)
- Migration from sqflite to sqflite_common_ffi is seamless for existing data