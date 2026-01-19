import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pos_controller.dart';
import '../models/table_model.dart';

class TablesPlanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final posController = Get.find<PosController>();
    
    // Sample table data - in real app this would come from Isar
    List<TableModel> tables = [
      TableModel(number: 1, status: TableStatus.available),
      TableModel(number: 2, status: TableStatus.available),
      TableModel(number: 3, status: TableStatus.occupied),
      TableModel(number: 4, status: TableStatus.reserved),
      TableModel(number: 5, status: TableStatus.available),
      TableModel(number: 6, status: TableStatus.available),
      TableModel(number: 7, status: TableStatus.occupied),
      TableModel(number: 8, status: TableStatus.available),
    ];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Plan des Tables'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
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
          child: Column(
            children: [
              // Title
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Veuillez sélectionner une table',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              
              // Table Grid
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: tables.length,
                    itemBuilder: (context, index) {
                      TableModel table = tables[index];
                      
                      Color getStatusColor() {
                        switch (table.status) {
                          case TableStatus.available:
                            return Colors.green[400]!;
                          case TableStatus.reserved:
                            return Colors.orange[400]!;
                          case TableStatus.occupied:
                            return Colors.red[400]!;
                          default:
                            return Colors.grey[400]!;
                        }
                      }
                      
                      String getStatusText() {
                        switch (table.status) {
                          case TableStatus.available:
                            return 'Disponible';
                          case TableStatus.reserved:
                            return 'Réservée';
                          case TableStatus.occupied:
                            return 'Occupée';
                          default:
                            return 'Inconnue';
                        }
                      }
                      
                      return GestureDetector(
                        onTap: () {
                          if (table.status == TableStatus.available) {
                            posController.setSelectedTable(table.number.toString());
                            Get.toNamed('/new-order');
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: getStatusColor(),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chair,
                                size: 40,
                                color: Colors.white,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Table ${table.number}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                getStatusText(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Continue Button
              Padding(
                padding: EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: posController.selectedTableNumber.value.isEmpty
                      ? null
                      : () {
                          Get.toNamed('/new-order');
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: posController.selectedTableNumber.value.isEmpty
                        ? Colors.grey[400]
                        : Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Continuer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              // Back Button
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: TextButton.icon(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(Icons.arrow_back),
                  label: Text('Retour'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}