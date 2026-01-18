# SoYaBox POS

A Flutter Point of Sale application for restaurants with multi-language support (French, English, Arabic).

## Features

- **Multi-language Support**: French, English, and Arabic with RTL support
- **Three Service Types**:
  - Sur place (On-site dining)
  - À emporter (Take away)
  - Livraison (Delivery)
- **Interactive Table Plan**: Visual representation of restaurant tables with status indicators
- **POS System**: Category-based product browsing and cart management
- **Order Management**: Complete order processing with validation
- **Modern UI**: Following the Pantone 2025 color scheme (red and pink accents)

## Architecture

The application follows the MVC pattern with GetX for state management:

- **Models**: Data models for entities (User, Table, Category, Product, Order)
- **Repositories**: Data access layer with API integration
- **Controllers**: Business logic with GetX reactive programming
- **Views**: Presentation layer with clean separation

## Technical Implementation

- **State Management**: GetX (GetBuilder, ValueNotifier)
- **Routing**: GetX navigation system
- **Dependency Injection**: GetX service locator
- **API Integration**: GetConnect for HTTP requests
- **Localization**: Flutter's built-in internationalization with custom locale handling
- **UI Components**: Material Design with custom styling

## Project Structure

```
lib/
├── main.dart
├── app/
│   ├── routes/
│   │   ├── app_pages.dart
│   │   └── app_routes.dart
├── core/
│   ├── constants/
│   │   └── api_endpoints.dart
│   └── utils/
│       └── app_snackbar.dart
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── table_model.dart
│   │   ├── category_model.dart
│   │   ├── product_model.dart
│   │   └── order_model.dart
│   ├── repositories/
│   │   └── pos_repository.dart
│   └── services/
│       └── api_service.dart
├── presentation/
│   ├── controllers/
│   │   └── pos/
│   │       ├── choice_controller.dart
│   │       ├── table_plan_controller.dart
│   │       └── pos_controller.dart
│   └── views/
│       └── pos/
│           ├── choice_screen.dart
│           ├── table_plan_screen.dart
│           └── pos_screen.dart
└── localization/
    ├── locale_keys.dart
    └── assets/
        ├── fr.json
        ├── en.json
        └── ar.json
```

## Setup Instructions

1. Clone the repository
2. Run `flutter pub get`
3. Configure your API endpoint in `lib/data/services/api_service.dart`
4. Run the application with `flutter run`

## API Integration

The application integrates with an existing Laravel API backend. The endpoints include:
- Authentication: `/api/login`
- Tables: `/api/tables`
- Categories: `/api/categories`
- Products: `/api/products`
- Orders: `/api/pos/orders/store`

## Localization

The app supports three languages:
- French (default)
- English
- Arabic (with RTL support)

Language files are located in `lib/localization/assets/` and managed through Flutter's internationalization framework.

## Security Features

- PIN-based locking after each order
- Role-based access control (admin/super admin only for order modifications)
- Secure API communication

## Additional Features

- Sound toggle functionality with persistence
- Thermal printer support for receipts
- Responsive design for various screen sizes
- Anti-double-click protection for product selection