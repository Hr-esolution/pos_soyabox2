# pos_soyabox

# POS Soyabox Application

A Flutter Point of Sale (POS) application designed for offline-first operation with desktop support, specifically tailored to replicate the functionality of the soyabox.ma POS system.

## Features

- **Offline-first**: Full functionality available without internet connection
- **Desktop Support**: Optimized for Windows Desktop usage
- **Laravel Backend Integration**: Seamless synchronization with existing Laravel backend
- **Security**: PIN-based authentication and locking system
- **Multi-service Types**: Support for on-site, pickup, and delivery orders
- **Real-time Sync**: Automatic synchronization when connectivity is restored
- **Modern UI**: Glassmorphism design with responsive layout

## Architecture

The application follows a modular architecture using GetX for state management and Isar for local storage:

```
lib/
├── app/
│   ├── bindings/
│   ├── routes/
│   └── theme/
├── modules/
│   └── pos/
│       ├── controllers/
│       ├── views/
│       └── models/
└── data/
    ├── local/
    └── remote/
```

### Models
- `Product`: Store product information
- `Category`: Product categorization
- `TableModel`: Table management for dine-in service
- `CartItem`: Items in the shopping cart
- `OfflineOrder`: Orders stored locally before sync

### Controllers
- `CartController`: Manages shopping cart operations
- `SyncController`: Handles offline data synchronization
- `AuthController`: PIN-based authentication
- `PosController`: Main POS business logic

## Setup Instructions

1. **Install Dependencies**
```bash
flutter pub get
```

2. **Generate Isar Code**
```bash
dart run build_runner build
```

3. **Run the Application**
```bash
flutter run -d windows
```

## Key Functionalities

### Authentication
- PIN-based locking system (6-digit PIN)
- Automatic lock after each order
- Secure PIN storage using SHA-256 hashing

### Service Types
1. **On-site**: Select from available tables
2. **Pickup**: Customer details required
3. **Delivery**: Complete address information needed

### Offline Operation
- All orders stored locally when offline
- Automatic sync when connectivity restored
- Visual indicators for online/offline status
- Manual sync option available

### Data Synchronization
- Uses connectivity_plus to detect network status
- Queued order processing
- Exponential backoff for failed sync attempts

## API Integration

The application connects to the existing Laravel backend via:
- `POST /api/pos/orders/store` for submitting orders

## Security

- Local PIN verification (no server communication for unlocking)
- SHA-256 hashed PIN storage
- Secure local data storage with Isar

## Platform Support

- Windows Desktop (primary target)
- Potential for Android/iOS expansion

## Development Notes

- Uses GetX for state management (without Obx, using GetBuilder/Get.put)
- Isar as the local database solution
- Responsive UI design for various screen sizes
- French language interface (as per original requirements)

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# pos_soyabox2
