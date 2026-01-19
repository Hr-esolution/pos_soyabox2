import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pos_controller.dart';

class FulfillmentTypeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final posController = Get.find<PosController>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Type de service'),
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Text(
                  'Comment souhaitez-vous récupérer votre commande?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Service Type Options
              Container(
                width: 350,
                child: Column(
                  children: [
                    // On Site Button
                    Container(
                      width: double.infinity,
                      height: 80,
                      child: ElevatedButton(
                        onPressed: () {
                          posController.setFulfillmentType('on_site');
                          Get.toNamed('/tables-plan');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.orange[700],
                          padding: EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color: Colors.orange[200]!,
                              width: 2,
                            ),
                          ),
                          shadowColor: Colors.grey[300],
                          elevation: 5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.room_service,
                              size: 30,
                            ),
                            SizedBox(width: 15),
                            Text(
                              'Sur place',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 30),
                    
                    // Pickup Button
                    Container(
                      width: double.infinity,
                      height: 80,
                      child: ElevatedButton(
                        onPressed: () {
                          posController.setFulfillmentType('pickup');
                          Get.toNamed('/new-order');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green[700],
                          padding: EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color: Colors.green[200]!,
                              width: 2,
                            ),
                          ),
                          shadowColor: Colors.grey[300],
                          elevation: 5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_mall,
                              size: 30,
                            ),
                            SizedBox(width: 15),
                            Text(
                              'À emporter',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 30),
                    
                    // Delivery Button
                    Container(
                      width: double.infinity,
                      height: 80,
                      child: ElevatedButton(
                        onPressed: () {
                          posController.setFulfillmentType('delivery');
                          Get.toNamed('/new-order');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue[700],
                          padding: EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color: Colors.blue[200]!,
                              width: 2,
                            ),
                          ),
                          shadowColor: Colors.grey[300],
                          elevation: 5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delivery_dining,
                              size: 30,
                            ),
                            SizedBox(width: 15),
                            Text(
                              'Livraison',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Spacer(),
              
              // Back Button
              Padding(
                padding: EdgeInsets.all(20),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(Icons.arrow_back),
                  label: Text('RETOUR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.grey[700],
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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