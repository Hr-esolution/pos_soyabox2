import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pos_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/sync_controller.dart';
import '../models/product.dart';

class NewOrderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final posController = Get.find<PosController>();
    final cartController = Get.find<CartController>();
    final syncController = Get.find<SyncController>();
    
    // Sample products data - in real app this would come from Isar
    List<Product> products = [
      Product(name: 'Pizza Margherita', price: 89.0, categoryId: 1),
      Product(name: 'Pizza Pepperoni', price: 99.0, categoryId: 1),
      Product(name: 'Pizza Végétarienne', price: 95.0, categoryId: 1),
      Product(name: 'Coca Cola', price: 12.0, categoryId: 2),
      Product(name: 'Sprite', price: 12.0, categoryId: 2),
      Product(name: 'Eau minérale', price: 8.0, categoryId: 2),
      Product(name: 'Salade César', price: 45.0, categoryId: 3),
      Product(name: 'Hamburger', price: 65.0, categoryId: 1),
    ];
    
    // Sample categories data
    List<String> categories = ['Pizzas', 'Boissons', 'Salades', 'Desserts'];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Nouvelle Commande'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          // Online/Offline indicator
          Obx(() => Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: syncController.isOnline.value ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              syncController.isOnline.value ? 'ONLINE' : 'OFFLINE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          )),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[50]!,
                Colors.blue[50]!,
              ],
            ),
          ),
          child: Row(
            children: [
              // Left Panel: Categories and Products
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Categories Horizontal List
                    Container(
                      height: 80,
                      padding: EdgeInsets.all(10),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: index == 0 ? Colors.blue : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  categories[index],
                                  style: TextStyle(
                                    color: index == 0 ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Products Grid
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            Product product = products[index];
                            
                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: InkWell(
                                onTap: () {
                                  cartController.addItem(product);
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Product Image Placeholder
                                      Container(
                                        height: 80,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.fastfood,
                                          size: 40,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      // Product Name
                                      Text(
                                        product.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 5),
                                      // Price
                                      Text(
                                        '${product.price.toStringAsFixed(2)} DH',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Right Panel: Cart and Customer Info
              Container(
                width: 350,
                color: Colors.white,
                child: Column(
                  children: [
                    // Cart Header
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(15),
                      color: Colors.grey[100],
                      child: Row(
                        children: [
                          Icon(Icons.shopping_cart, color: Colors.blue),
                          SizedBox(width: 10),
                          Text(
                            'Panier',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Obx(() => Text(
                            'Items: ${cartController.items.length}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          )),
                        ],
                      ),
                    ),
                    
                    // Cart Items
                    Expanded(
                      child: Obx(() => ListView.builder(
                        itemCount: cartController.items.length,
                        itemBuilder: (context, index) {
                          var item = cartController.items[index];
                          
                          // Find the product name from our sample data
                          String productName = 'Produit inconnu';
                          double unitPrice = 0.0;
                          for (var prod in products) {
                            if (prod.id == item.productId) {
                              productName = prod.name;
                              unitPrice = prod.price;
                              break;
                            }
                          }
                          
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  // Quantity Controls
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.add, size: 18),
                                        onPressed: () => cartController.updateQuantity(index, 1),
                                        iconSize: 16,
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(minWidth: 30, minHeight: 30),
                                      ),
                                      Text('${item.quantity}'),
                                      IconButton(
                                        icon: Icon(Icons.remove, size: 18),
                                        onPressed: () => cartController.updateQuantity(index, -1),
                                        iconSize: 16,
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(minWidth: 30, minHeight: 30),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 10),
                                  
                                  // Product Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          productName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${unitPrice.toStringAsFixed(2)} DH/unité',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Total Price
                                  Text(
                                    '${(item.unitPrice * item.quantity).toStringAsFixed(2)} DH',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  
                                  // Delete Button
                                  IconButton(
                                    icon: Icon(Icons.delete, size: 18, color: Colors.red),
                                    onPressed: () => cartController.removeItem(index),
                                    iconSize: 18,
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(minWidth: 30, minHeight: 30),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )),
                    ),
                    
                    // Customer Information Form (conditional based on fulfillment type)
                    Obx(() {
                      if (posController.fulfillmentType.value == 'pickup' || 
                          posController.fulfillmentType.value == 'delivery') {
                        return Container(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Informations Client',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              
                              // Customer Name
                              TextField(
                                onChanged: (value) => posController.customerName.value = value,
                                decoration: InputDecoration(
                                  labelText: 'Nom complet',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              
                              // Phone Number
                              TextField(
                                onChanged: (value) => posController.customerPhone.value = value,
                                decoration: InputDecoration(
                                  labelText: 'Numéro de téléphone',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                              SizedBox(height: 10),
                              
                              // Delivery Address (only for delivery)
                              if (posController.fulfillmentType.value == 'delivery')
                                TextField(
                                  onChanged: (value) => posController.deliveryAddress.value = value,
                                  decoration: InputDecoration(
                                    labelText: 'Adresse de livraison',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  maxLines: 3,
                                ),
                            ],
                          ),
                        );
                      }
                      return Container(); // Empty container if not pickup/delivery
                    }),
                    
                    // Table Info (for on_site)
                    Obx(() {
                      if (posController.fulfillmentType.value == 'on_site' && 
                          posController.selectedTableNumber.value.isNotEmpty) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: Row(
                            children: [
                              Icon(Icons.table_restaurant, color: Colors.blue),
                              SizedBox(width: 10),
                              Text(
                                'Table: ${posController.selectedTableNumber.value}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return Container();
                    }),
                    
                    // Summary and Action Buttons
                    Container(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        children: [
                          // Total
                          Obx(() => Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                                Text(
                                  '${cartController.total.toStringAsFixed(2)} DH',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ],
                            ),
                          )),
                          
                          SizedBox(height: 15),
                          
                          // Force Sync Button
                          Obx(() => Visibility(
                            visible: syncController.pendingCount.value > 0,
                            child: ElevatedButton(
                              onPressed: () {
                                syncController.forceSync();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[600],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.sync),
                                  SizedBox(width: 8),
                                  Text(
                                    'Forcer la synchronisation (${syncController.pendingCount.value})',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          )),
                          
                          SizedBox(height: 10),
                          
                          // Validate Order Button
                          Obx(() => ElevatedButton(
                            onPressed: posController.validateForm() 
                                ? () async {
                                    bool success = await posController.saveOrder();
                                    if (success) {
                                      Get.snackbar(
                                        'Succès',
                                        'Commande enregistrée avec succès!',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white,
                                      );
                                    } else {
                                      Get.snackbar(
                                        'Erreur',
                                        'Impossible d\'enregistrer la commande.',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: posController.validateForm() 
                                  ? Colors.green[600] 
                                  : Colors.grey[400],
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'VALIDER LA COMMANDE',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )),
                          
                          SizedBox(height: 10),
                          
                          // Back Button
                          TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: Text('Retour'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}