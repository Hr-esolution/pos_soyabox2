import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../../data/local/isar_service.dart';
import '../../data/remote/api_client.dart';
import '../models/offline_order.dart';

class SyncController extends GetxController {
  var isOnline = false.obs;
  var pendingCount = 0.obs;
  Timer? _connectivityTimer;

  @override
  void onInit() {
    super.onInit();
    _checkConnectivity();
    _startConnectivityMonitoring();
  }

  @override
  void onClose() {
    _connectivityTimer?.cancel();
    super.onClose();
  }

  void _startConnectivityMonitoring() {
    _connectivityTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _checkConnectivity();
    });
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    isOnline.value = connectivityResult != ConnectivityResult.none;
    
    if (isOnline.value) {
      // Update pending count when online
      List<OfflineOrder> unsyncedOrders = await IsarService.getUnsyncedOrders();
      pendingCount.value = unsyncedOrders.length;
      
      // Try to sync pending orders
      if (unsyncedOrders.isNotEmpty) {
        await syncPendingOrders();
      }
    } else {
      // Just update pending count when offline
      List<OfflineOrder> unsyncedOrders = await IsarService.getUnsyncedOrders();
      pendingCount.value = unsyncedOrders.length;
    }
  }

  Future<void> syncPendingOrders() async {
    try {
      List<OfflineOrder> unsyncedOrders = await IsarService.getUnsyncedOrders();
      
      for (OfflineOrder order in unsyncedOrders) {
        try {
          // Prepare payload for API
          Map<String, dynamic> payload = {
            'fulfillment_type': order.fulfillmentType,
            'table_number': order.tableNumber,
            'customer_name': order.customerName,
            'customer_phone': order.customerPhone,
            'delivery_address': order.deliveryAddress,
            'items': order.items.map((item) => {
              'product_id': item.productId,
              'quantity': item.quantity,
            }).toList(),
          };

          // Send to API
          await ApiClient.storeOrder(payload);
          
          // Mark as synced
          await IsarService.markOrderAsSynced(order.uuid);
          
          // Update pending count
          List<OfflineOrder> remainingUnsynced = await IsarService.getUnsyncedOrders();
          pendingCount.value = remainingUnsynced.length;
        } catch (e) {
          // If sync fails, continue with next order
          print('Failed to sync order ${order.uuid}: $e');
        }
      }
    } catch (e) {
      print('Error syncing pending orders: $e');
    }
  }

  Future<void> forceSync() async {
    await _checkConnectivity();
  }

  Future<int> getPendingCount() async {
    List<OfflineOrder> unsyncedOrders = await IsarService.getUnsyncedOrders();
    return unsyncedOrders.length;
  }
}