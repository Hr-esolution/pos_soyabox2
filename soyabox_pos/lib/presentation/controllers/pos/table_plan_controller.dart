import 'package:get/get.dart';
import '../../../data/models/table_model.dart';
import '../../../data/repositories/pos_repository.dart';

class TablePlanController extends GetxController {
  final PosRepository _repository = Get.find<PosRepository>();
  final List<TableModel> _tables = <TableModel>[].obs;
  final RxBool _isLoading = false.obs;

  List<TableModel> get tables => _tables;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    fetchTables();
  }

  Future<void> fetchTables() async {
    _isLoading.value = true;
    try {
      final data = await _repository.getTables();
      _tables.assignAll(data);
    } catch (e) {
      Get.snackbar("Error", "Failed to load tables: $e");
    } finally {
      _isLoading.value = false;
    }
  }

  void selectTable(TableModel table) {
    // Navigate to POS screen with selected table
    Get.toNamed('/pos', arguments: {
      'fulfillmentType': 'surplace',
      'tableNumber': table.number,
    });
  }
}

class TablePlanBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TablePlanController>(() => TablePlanController());
  }
}