import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/pos_controller.dart';

class TablePlanScreen extends StatelessWidget {
  const TablePlanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PosController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan des Tables'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sélectionnez une table'.tr,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (controller.tables.isEmpty) {
                  return const Center(child: Text('Aucune table disponible'));
                }
                
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: controller.tables.length,
                  itemBuilder: (context, index) {
                    final table = controller.tables[index];
                    
                    Color statusColor;
                    IconData statusIcon;
                    
                    switch (table.status.toLowerCase()) {
                      case 'available':
                      case 'disponible':
                        statusColor = Colors.green;
                        statusIcon = Icons.check_circle;
                        break;
                      case 'reserved':
                      case 'réservée':
                        statusColor = Colors.orange;
                        statusIcon = Icons.warning;
                        break;
                      case 'occupied':
                      case 'occupée':
                        statusColor = Colors.red;
                        statusIcon = Icons.cancel;
                        break;
                      default:
                        statusColor = Colors.grey;
                        statusIcon = Icons.help;
                    }
                    
                    bool isClickable = table.status.toLowerCase() == 'available' || 
                                      table.status.toLowerCase() == 'disponible';
                    
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isClickable ? Theme.of(context).primaryColor : Colors.grey.shade300,
                          width: isClickable ? 2 : 1,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: isClickable 
                          ? () {
                              controller.selectTable(table);
                              Get.toNamed('/pos');
                            } 
                          : null,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                statusIcon,
                                color: statusColor,
                                size: 30,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                table.tableNumber ?? table.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isClickable ? Colors.black : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                table.status.tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}