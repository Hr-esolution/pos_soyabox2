import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class ChoiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    
    return Scaffold(
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
              // Logo/App Title
              Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 60,
                    color: Colors.blue,
                  ),
                ),
              ),
              
              // Title
              Text(
                'Bienvenue',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              
              SizedBox(height: 20),
              
              Text(
                'Que souhaitez-vous faire?',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              
              SizedBox(height: 80),
              
              // Choice Buttons
              Container(
                width: 350,
                child: Column(
                  children: [
                    // New Order Button
                    Container(
                      width: double.infinity,
                      height: 80,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.toNamed('/fulfillment-type');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue[800],
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
                              Icons.add_shopping_cart,
                              size: 30,
                            ),
                            SizedBox(width: 15),
                            Text(
                              'Nouvelle commande',
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
                    
                    // My Orders Button
                    Container(
                      width: double.infinity,
                      height: 80,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to my orders screen (not implemented yet)
                          print('My Orders clicked');
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
                              Icons.history,
                              size: 30,
                            ),
                            SizedBox(width: 15),
                            Text(
                              'Mes commandes',
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
              
              // Lock Button
              Padding(
                padding: EdgeInsets.all(20),
                child: ElevatedButton.icon(
                  onPressed: () {
                    authController.lock();
                    Get.offAllNamed('/lock');
                  },
                  icon: Icon(Icons.lock_outline),
                  label: Text('VERROUILLER'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[100],
                    foregroundColor: Colors.red[700],
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