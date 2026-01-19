import 'package:get/get.dart';
import '../../modules/pos/controllers/cart_controller.dart';
import '../../modules/pos/controllers/sync_controller.dart';
import '../../modules/pos/controllers/auth_controller.dart';
import '../../modules/pos/controllers/pos_controller.dart';
import '../../data/local/isar_service.dart';

class AppBinding implements Bindings {
  @override
  void dependencies() {
    // Initialize Isar database
    IsarService.open();
    
    // Controllers
    Get.lazyPut(() => CartController());
    Get.lazyPut(() => SyncController());
    Get.lazyPut(() => AuthController());
    Get.lazyPut(() => PosController());
  }
}