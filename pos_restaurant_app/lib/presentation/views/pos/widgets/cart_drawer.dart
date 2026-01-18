import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/pos_controller.dart';

class CartDrawer extends StatelessWidget {
  final PosController controller;

  const CartDrawer({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        children: [
          // En-tête du panier
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(
              'Panier'.tr,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Total du panier
          Container(
            padding: const EdgeInsets.all(16),
            child: Obx(() => Text(
              'Total: ${controller.cartTotal.toStringAsFixed(2)} DH',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            )),
          ),
          
          // Liste des articles du panier
          Expanded(
            child: Obx(() {
              if (controller.cartItems.isEmpty) {
                return const Center(
                  child: Text(
                    'Votre panier est vide',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.cartItems.length,
                itemBuilder: (context, index) {
                  final item = controller.cartItems[index];
                  
                  // Trouver le produit correspondant
                  final product = controller.products.firstWhere(
                    (p) => p.id == item.productId,
                    orElse: () => controller.products.firstWhere(
                      (p) => p.id == item.productId,
                      orElse: () => Product(id: 0, name: 'Produit inconnu', price: 0.0),
                    ),
                  );
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Icône du produit
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.fastfood,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // Détails du produit
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${item.unitPrice.toStringAsFixed(2)} DH/unité',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Contrôles de quantité
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  controller.updateCartItemQuantity(
                                    item.productId,
                                    item.quantity - 1,
                                  );
                                },
                                icon: const Icon(Icons.remove),
                                color: Theme.of(context).primaryColor,
                                splashRadius: 20,
                              ),
                              Container(
                                width: 30,
                                alignment: Alignment.center,
                                child: Text(
                                  item.quantity.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  controller.updateCartItemQuantity(
                                    item.productId,
                                    item.quantity + 1,
                                  );
                                },
                                icon: const Icon(Icons.add),
                                color: Theme.of(context).primaryColor,
                                splashRadius: 20,
                              ),
                            ],
                          ),
                          
                          const SizedBox(width: 8),
                          
                          // Bouton de suppression
                          IconButton(
                            onPressed: () {
                              controller.removeFromCart(item.productId);
                            },
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            splashRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          
          // Bouton de validation
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value 
                  ? null 
                  : () async {
                      if (await controller.validateOrder()) {
                        Get.snackbar(
                          'Succès',
                          'Commande validée avec succès !',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                        Get.back(); // Fermer le drawer
                        Get.back(); // Retourner à l'écran précédent
                      } else {
                        Get.snackbar(
                          'Erreur',
                          'Veuillez vérifier les informations de la commande',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : Text(
                      'Valider la commande'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}