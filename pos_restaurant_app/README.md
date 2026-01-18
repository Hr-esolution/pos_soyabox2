# Système de Caisse Restaurant (POS)

Une application mobile Flutter pour la gestion des commandes dans un restaurant, avec interface moderne, gestion des tables, catégories de produits, panier dynamique, validation de commande et intégration à une API backend existante.

## 🚀 Fonctionnalités

- **Interface mobile-first** : Optimisée pour iOS et Android
- **Gestion des types de commande** : Sur place, à emporter, livraison
- **Plan des tables** : Visualisation et sélection des tables avec statut
- **Catalogue de produits** : Par catégorie avec images et prix
- **Panier dynamique** : Ajout/suppression/modification des articles
- **Validation de commande** : Intégration avec l'API backend
- **Internationalisation** : Français, Anglais, Arabe avec support RTL
- **Design moderne** : Thème selon Pantone 2025 (rouge vif #c92a2a, rose #ff6b6b)

## 🏗️ Architecture

L'application suit une architecture MVC avec GetX :

```
lib/
├── main.dart
├── app/
│   ├── routes/
│   │   ├── app_pages.dart
│   │   └── app_routes.dart
│   └── themes/
│       └── app_theme.dart
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
│   │   ├── pos_controller.dart
│   │   └── settings_controller.dart
│   └── views/
│       ├── pos/
│       │   ├── widgets/
│       │   │   └── cart_drawer.dart
│       │   ├── choice_screen.dart
│       │   ├── table_plan_screen.dart
│       │   └── pos_screen.dart
│       └── settings/
│           └── settings_screen.dart
└── localization/
    ├── locale_keys.dart
    └── assets/
        ├── fr.json
        ├── en.json
        └── ar.json
```

## 🛠️ Technologies Utilisées

- **Flutter** : Framework multiplateforme
- **GetX** : Gestion d'état, routage, injection de dépendances
- **HTTP** : Communication avec l'API backend
- **Shared Preferences** : Stockage local des préférences
- **Flutter Localizations** : Support multilingue
- **Cached Network Image** : Gestion optimisée des images
- **ESC POS Printer** : Impression thermique (à implémenter)

## 📋 Configuration Requise

- Flutter SDK 3.0.0 ou supérieur
- Android SDK (pour Android)
- Xcode (pour iOS)

## 📦 Installation

1. Clonez le dépôt
2. Exécutez `flutter pub get` pour installer les dépendances
3. Configurez l'URL de votre backend dans `lib/core/constants/api_endpoints.dart`
4. Lancez l'application avec `flutter run`

## 🔧 Configuration de l'API Backend

Modifiez l'URL de base dans `lib/core/constants/api_endpoints.dart` :

```dart
static const String baseUrl = 'https://votre-api.com/api';
```

## 🌐 Internationalisation

L'application prend en charge trois langues :
- Français (par défaut)
- Anglais
- Arabe (avec support RTL)

Les fichiers de traduction se trouvent dans `lib/localization/assets/`.

## 📱 Fonctionnalités Spécifiques

### Gestion des Tables
- Visualisation des tables avec statut (disponible, réservée, occupée)
- Sélection intuitive des tables pour les commandes sur place

### Gestion des Commandes
- Trois types de commandes : sur place, à emporter, livraison
- Validation avec vérification des champs requis
- Intégration avec l'API backend

### Panier Dynamique
- Ajout/suppression d'articles
- Modification des quantités
- Calcul automatique du total

### Sécurité
- Verrouillage automatique après commande
- Gestion des rôles utilisateur (à implémenter dans le backend)

## 🎨 Design

- Couleurs primaires selon Pantone 2025 (rouge vif #c92a2a, rose #ff6b6b)
- Deux thèmes : clair et sombre
- Composants arrondis avec ombres subtiles
- Responsive design pour tous les formats d'écran

## 📞 Support

Pour toute question ou problème, veuillez contacter l'équipe de développement.

---

© 2026 - Système de Caisse Restaurant