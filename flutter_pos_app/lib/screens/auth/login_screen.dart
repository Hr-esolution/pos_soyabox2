import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../constants/app_routes.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.find();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              'POS System Login',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 40),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            SizedBox(height: 30),
            Obx(() {
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: authController.isLoading.value
                      ? null
                      : () => _performLogin(),
                  child: authController.isLoading.value
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('LOGIN'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              );
            }),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Navigate to PIN screen
                Get.toNamed(AppRoutes.pin);
              },
              child: Text('Access with PIN instead'),
            ),
          ],
        ),
      ),
    );
  }

  void _performLogin() async {
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter both phone and password');
      return;
    }

    final success = await authController.login(
      _phoneController.text,
      _passwordController.text,
    );

    if (success) {
      Get.snackbar('Success', 'Login successful!');
      // Navigate to appropriate screen based on user role
      if (authController.currentUser?.isAdmin == true) {
        Get.offAllNamed(AppRoutes.userManagement);
      } else {
        // Navigate to server menu for non-admin users
        Get.offAllNamed(AppRoutes.home);
      }
    } else {
      Get.snackbar('Error', 'Invalid credentials');
    }
  }
}