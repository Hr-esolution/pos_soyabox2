import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../data/local/isar_service.dart';
import '../models/offline_order.dart';
import '../models/cart_item.dart';
import 'cart_controller.dart';
import 'sync_controller.dart';

class PosController extends GetxController {
  final CartController cartController = Get.find();
  final SyncController syncController = Get.find();
  
  var fulfillmentType = ''.obs;
  var selectedTableNumber = ''.obs;
  var customerName = ''.obs;
  var customerPhone = ''.obs;
  var deliveryAddress = ''.obs;
  
  void setFulfillmentType(String type) {
    fulfillmentType.value = type;
  }
  
  void setSelectedTable(String tableNumber) {
    selectedTableNumber.value = tableNumber;
  }
  
  Future<void> saveOrder() async {
    try {
      // Create offline order
      OfflineOrder order = OfflineOrder(
        fulfillmentType: fulfillmentType.value,
        tableNumber: selectedTableNumber.value.isEmpty ? null : selectedTableNumber.value,
        customerName: customerName.value.isEmpty ? null : customerName.value,
        customerPhone: customerPhone.value.isEmpty ? null : customerPhone.value,
        deliveryAddress: deliveryAddress.value.isEmpty ? null : deliveryAddress.value,
        items: List.from(cartController.items),
      );
      
      // Save to local database
      await IsarService.addOfflineOrder(order);
      
      // Try immediate sync if online
      if (syncController.isOnline.value) {
        await syncController.syncPendingOrders();
      }
      
      // Clear cart after saving
      cartController.clearCart();
      
      // Reset form
      resetForm();
      
      return true;
    } catch (e) {
      print('Error saving order: $e');
      return false;
    }
  }
  
  void resetForm() {
    fulfillmentType.value = '';
    selectedTableNumber.value = '';
    customerName.value = '';
    customerPhone.value = '';
    deliveryAddress.value = '';
  }
  
  bool validateForm() {
    if (fulfillmentType.value.isEmpty) return false;
    
    if (fulfillmentType.value == 'on_site') {
      return selectedTableNumber.value.isNotEmpty && cartController.items.isNotEmpty;
    } else if (fulfillmentType.value == 'pickup') {
      return customerName.value.isNotEmpty && 
             customerPhone.value.isNotEmpty && 
             cartController.items.isNotEmpty;
    } else if (fulfillmentType.value == 'delivery') {
      return customerName.value.isNotEmpty && 
             customerPhone.value.isNotEmpty && 
             deliveryAddress.value.isNotEmpty && 
             cartController.items.isNotEmpty;
    }
    
    return false;
  }
}