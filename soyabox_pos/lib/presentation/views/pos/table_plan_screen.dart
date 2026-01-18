import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/pos/table_plan_controller.dart';
import '../../../data/models/table_model.dart';

class TablePlanScreen extends StatelessWidget {
  const TablePlanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TablePlanController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Table'),
        centerTitle: true,
        backgroundColor: const Color(0xFFc92a2a),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.tables.isEmpty) {
          return const Center(child: Text('No tables available'));
        }
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: controller.tables.length,
            itemBuilder: (context, index) {
              final table = controller.tables[index];
              return _buildTableCard(table, controller);
            },
          ),
        );
      }),
    );
  }

  Widget _buildTableCard(TableModel table, TablePlanController controller) {
    Color cardColor;
    String statusText;
    
    switch (table.status) {
      case TableStatus.available:
        cardColor = Colors.green.shade300;
        statusText = 'Available';
        break;
      case TableStatus.reserved:
        cardColor = Colors.orange.shade300;
        statusText = 'Reserved';
        break;
      case TableStatus.occupied:
        cardColor = Colors.red.shade300;
        statusText = 'Occupied';
        break;
    }

    bool isClickable = table.status == TableStatus.available;

    return GestureDetector(
      onTap: isClickable ? () => controller.selectTable(table) : null,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isClickable ? Colors.black26 : Colors.grey,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black26, width: 2),
              ),
              child: Center(
                child: Text(
                  table.number,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isClickable ? Colors.black87 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}