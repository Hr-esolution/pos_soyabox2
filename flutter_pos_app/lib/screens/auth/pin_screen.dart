import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/session_controller.dart';
import '../../constants/app_routes.dart';

class PinScreen extends StatelessWidget {
  final SessionController sessionController = Get.find();
  final TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter PIN'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              'Enter Your PIN',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 40),
            TextField(
              controller: _pinController,
              decoration: InputDecoration(
                labelText: 'PIN',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pin),
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
              maxLength: 4,
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _verifyPin(),
                child: Text('UNLOCK'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }

  void _verifyPin() async {
    if (_pinController.text.length != 4) {
      Get.snackbar('Error', 'PIN must be 4 digits');
      return;
    }

    final isValid = await sessionController.unlockWithPin(_pinController.text);
    
    if (isValid) {
      Get.snackbar('Success', 'Access granted!');
      // Navigate to appropriate screen based on user role
      if (sessionController.currentUser?.isAdmin == true) {
        Get.offAllNamed(AppRoutes.adminMenu);
      } else {
        Get.offAllNamed(AppRoutes.serverMenu);
      }
    } else {
      Get.snackbar('Error', 'Invalid PIN');
    }
  }
}