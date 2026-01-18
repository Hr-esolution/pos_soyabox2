import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/pos_controller.dart';
import 'widgets/cart_drawer.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PosController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Restaurant'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Affichage du chiffre d'affaires du jour si disponible
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Obx(() {
              // Pour l'instant, on affiche un placeholder
              // Dans une implémentation réelle, on récupérerait cette valeur depuis le backend
              return Text(
                'CA: 0.00 DH',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              );
            }),
          ),
        ],
      ),
      drawer: CartDrawer(controller: controller),
      body: Column(
        children: [
          // Section des catégories
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 1 + controller.categories.length, // +1 pour "Tous"
                itemBuilder: (context, index) {
                  bool isSelected = controller.selectedCategoryId.value == index;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: index == 0 
                        ? Text('Tous'.tr) 
                        : Text(controller.categories[index - 1].name.tr),
                      selected: isSelected,
                      selectedColor: Theme.of(context).primaryColor,
                      onSelected: (selected) {
                        if (selected) {
                          controller.selectCategory(index);
                        }
                      },
                    ),
                  );
                },
              );
            }),
          ),
          
          // Section des produits
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.filteredProducts.isEmpty) {
                return const Center(child: Text('Aucun produit disponible'));
              }
              
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: controller.filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = controller.filteredProducts[index];
                  
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // Animation légère pour l'ajout au panier
                        controller.addToCart(product);
                        
                        // Afficher un effet visuel léger
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} ajouté au panier'),
                            duration: const Duration(milliseconds: 500),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image du produit
                          AspectRatio(
                            aspectRatio: 4 / 3,
                            child: product.image != null
                                ? CachedNetworkImage(
                                    imageUrl: product.image!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => 
                                      const Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) => 
                                      const Icon(Icons.image_not_supported),
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.fastfood,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                          
                          // Nom et prix du produit
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${product.price.toStringAsFixed(2)} DH',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      
      // Bouton flottant pour ouvrir le panier
      floatingActionButton: Obx(() {
        if (controller.cartItemCount > 0) {
          return FloatingActionButton.extended(
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
            label: Text(
              '${controller.cartItemCount} articles - ${controller.cartTotal.toStringAsFixed(2)} DH',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            icon: const Icon(Icons.shopping_cart),
            backgroundColor: Theme.of(context).primaryColor,
          );
        }
        return null;
      }),
    );
  }
}