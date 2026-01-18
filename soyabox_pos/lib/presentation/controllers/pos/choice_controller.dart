import 'package:get/get.dart';
import '../../../data/models/order_model.dart';

class ChoiceController extends GetxController {
  final _selectedFulfillmentType = ''.obs;
  
  String get selectedFulfillmentType => _selectedFulfillmentType.value;
  
  void setSelectedFulfillmentType(String type) {
    _selectedFulfillmentType.value = type;
  }

  void goToTablePlan() {
    Get.toNamed('/table-plan');
  }

  void goToPosScreen({String? tableNumber}) {
    Get.toNamed('/pos', arguments: {
      'fulfillmentType': selectedFulfillmentType,
      'tableNumber': tableNumber,
    });
  }
}

class ChoiceBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChoiceController>(() => ChoiceController());
  }
}