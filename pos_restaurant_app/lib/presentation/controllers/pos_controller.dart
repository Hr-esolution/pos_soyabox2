import 'package:get/get.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/table_model.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/pos_repository.dart';

class PosController extends GetxController {
  final PosRepository _repository = PosRepository();
  
  // État des données
  var isLoading = false.obs;
  var tables = <Table>[].obs;
  var categories = <Category>[].obs;
  var products = <Product>[].obs;
  var filteredProducts = <Product>[].obs;
  
  // Panier
  var cartItems = <OrderItem>[].obs;
  var selectedCategoryId = 0.obs;
  var selectedTable = <String, dynamic>{}.obs;
  var fulfillmentType = ''.obs; // 'surplace', 'emporter', 'livraison'
  
  // Données client pour emporter/livraison
  var customerName = ''.obs;
  var customerPhone = ''.obs;
  var customerAddress = ''.obs;
  
  // Initialisation
  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }
  
  // Chargement des données initiales
  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;
      
      // Charger les tables, catégories et produits
      await Future.wait([
        loadTables(),
        loadCategories(),
        loadProducts(),
      ]);
      
      // Par défaut, sélectionner la catégorie "Tous"
      selectCategory(0);
    } finally {
      isLoading.value = false;
    }
  }
  
  // Charger les tables
  Future<void> loadTables() async {
    try {
      tables.assignAll(await _repository.getTables());
    } catch (e) {
      print('Erreur lors du chargement des tables: $e');
    }
  }
  
  // Charger les catégories
  Future<void> loadCategories() async {
    try {
      categories.assignAll(await _repository.getCategories());
    } catch (e) {
      print('Erreur lors du chargement des catégories: $e');
    }
  }
  
  // Charger les produits
  Future<void> loadProducts() async {
    try {
      products.assignAll(await _repository.getProducts());
      filteredProducts.assignAll(products);
    } catch (e) {
      print('Erreur lors du chargement des produits: $e');
    }
  }
  
  // Filtrer les produits par catégorie
  void selectCategory(int categoryId) {
    selectedCategoryId.value = categoryId;
    
    if (categoryId == 0) {
      // Tous les produits
      filteredProducts.assignAll(products);
    } else {
      // Produits de la catégorie sélectionnée
      filteredProducts.assignAll(
        products.where((product) => product.categoryId == categoryId).toList()
      );
    }
  }
  
  // Ajouter un produit au panier
  void addToCart(Product product) {
    // Vérifier si le produit est déjà dans le panier
    int existingIndex = cartItems.indexWhere((item) => item.productId == product.id);
    
    if (existingIndex >= 0) {
      // Incrémenter la quantité
      OrderItem existingItem = cartItems[existingIndex];
      cartItems[existingIndex] = OrderItem(
        productId: existingItem.productId,
        quantity: existingItem.quantity + 1,
        unitPrice: existingItem.unitPrice,
      );
    } else {
      // Ajouter le nouveau produit
      cartItems.add(OrderItem(
        productId: product.id,
        quantity: 1,
        unitPrice: product.price,
      ));
    }
  }
  
  // Mettre à jour la quantité d'un article dans le panier
  void updateCartItemQuantity(int productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(productId);
      return;
    }
    
    int index = cartItems.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      cartItems[index] = OrderItem(
        productId: cartItems[index].productId,
        quantity: newQuantity,
        unitPrice: cartItems[index].unitPrice,
      );
    }
  }
  
  // Supprimer un article du panier
  void removeFromCart(int productId) {
    cartItems.removeWhere((item) => item.productId == productId);
  }
  
  // Calculer le total du panier
  double get cartTotal {
    return cartItems.fold(0, (sum, item) => sum + (item.unitPrice * item.quantity));
  }
  
  // Calculer le nombre total d'articles dans le panier
  int get cartItemCount {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }
  
  // Valider la commande
  Future<bool> validateOrder() async {
    if (cartItems.isEmpty) {
      return false; // Panier vide
    }
    
    // Vérifier les champs obligatoires selon le type de commande
    if (fulfillmentType.value == 'emporter' || fulfillmentType.value == 'livraison') {
      if (customerName.value.isEmpty || customerPhone.value.isEmpty) {
        return false; // Informations client requises
      }
      
      if (fulfillmentType.value == 'livraison' && customerAddress.value.isEmpty) {
        return false; // Adresse requise pour la livraison
      }
    }
    
    try {
      isLoading.value = true;
      
      // Créer la commande
      final order = Order(
        channel: 'pos',
        customerName: customerName.value.isNotEmpty ? customerName.value : null,
        customerPhone: customerPhone.value.isNotEmpty ? customerPhone.value : null,
        fulfillmentType: fulfillmentType.value,
        status: 'pending',
        totalPrice: cartTotal,
        tableNumber: selectedTable.containsKey('table_number') ? selectedTable['table_number'] : null,
        deliveryAddress: fulfillmentType.value == 'livraison' ? customerAddress.value : null,
        items: cartItems.toList(),
      );
      
      // Envoyer la commande
      await _repository.createOrder(order);
      
      // Réinitialiser le panier après validation réussie
      cartItems.clear();
      customerName.value = '';
      customerPhone.value = '';
      customerAddress.value = '';
      
      return true;
    } catch (e) {
      print('Erreur lors de la validation de la commande: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Sélectionner une table
  void selectTable(Table table) {
    selectedTable.addAll({
      'id': table.id,
      'name': table.name,
      'number': table.tableNumber,
      'status': table.status,
    });
  }
  
  // Définir le type de commande
  void setFulfillmentType(String type) {
    fulfillmentType.value = type;
  }
}