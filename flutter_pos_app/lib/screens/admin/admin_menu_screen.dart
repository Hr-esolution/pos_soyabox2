import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_routes.dart';

class AdminMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Menu'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Implement logout
              Get.back();
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(20.0),
        crossAxisSpacing: 20.0,
        mainAxisSpacing: 20.0,
        children: [
          _buildMenuCard(
            icon: Icons.people,
            title: 'User Management',
            color: Colors.blue,
            onTap: () => Get.toNamed(AppRoutes.userManagement),
          ),
          _buildMenuCard(
            icon: Icons.calculate,
            title: 'Accounting',
            color: Colors.green,
            onTap: () => Get.toNamed(AppRoutes.accounting),
          ),
          _buildMenuCard(
            icon: Icons.inventory,
            title: 'Inventory',
            color: Colors.orange,
            onTap: () => Get.toNamed(AppRoutes.home),
          ),
          _buildMenuCard(
            icon: Icons.receipt,
            title: 'Reports',
            color: Colors.purple,
            onTap: () => Get.toNamed(AppRoutes.orders),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: color,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}