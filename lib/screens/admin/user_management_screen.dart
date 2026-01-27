import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_controller.dart';
import '../../models/user.dart';
import '../../constants/app_constants.dart';

class UserManagementScreen extends StatelessWidget {
  final userController = Get.find<UserController>();

  UserManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add User Button
            ElevatedButton(
              onPressed: () => _showAddUserDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text('Add Server'),
            ),
            SizedBox(height: 16),
            
            // Users List
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: userController.users.length,
                itemBuilder: (context, index) {
                  final user = userController.users[index];
                  
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: user.role == AppConstants.roleAdmin 
                            ? Colors.red 
                            : Colors.blue,
                        child: Text(
                          user.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(user.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${user.phone} • ${user.role.toUpperCase()}'),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: user.isActive ? Colors.green : Colors.grey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  user.isActive ? 'ACTIVE' : 'INACTIVE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  user.syncStatus.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (String action) {
                          if (action == 'edit') {
                            _showEditUserDialog(context, user);
                          } else if (action == 'toggle') {
                            _toggleUserStatus(user);
                          } else if (action == 'delete') {
                            _confirmDeleteUser(context, user);
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          PopupMenuItem<String>(
                            value: 'toggle',
                            child: Text(user.isActive ? 'Deactivate' : 'Activate'),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final pinController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Server'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: pinController,
              decoration: InputDecoration(labelText: 'PIN (4 digits)'),
              keyboardType: TextInputType.number,
              maxLength: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty &&
                  pinController.text.length == 4) {
                
                final success = await userController.createUserLocal(
                  name: nameController.text,
                  phone: phoneController.text,
                  role: AppConstants.roleServer,
                  pin: pinController.text,
                );
                
                if (success) {
                  Get.snackbar('Success', 'Server added successfully');
                  Navigator.pop(context);
                } else {
                  Get.snackbar('Error', 'Failed to add server');
                }
              } else {
                Get.snackbar('Error', 'Please fill all fields correctly');
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, User user) {
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);
    final pinController = TextEditingController(text: user.pin);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: pinController,
              decoration: InputDecoration(labelText: 'PIN (4 digits)'),
              keyboardType: TextInputType.number,
              maxLength: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty &&
                  pinController.text.length == 4) {
                
                final updatedUser = user.copyWith(
                  name: nameController.text,
                  phone: phoneController.text,
                  pin: pinController.text,
                );
                
                final success = await userController.updateUserLocal(updatedUser);
                
                if (success) {
                  Get.snackbar('Success', 'User updated successfully');
                  Navigator.pop(context);
                } else {
                  Get.snackbar('Error', 'Failed to update user');
                }
              } else {
                Get.snackbar('Error', 'Please fill all fields correctly');
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _toggleUserStatus(User user) async {
    final updatedUser = user.copyWith(isActive: !user.isActive);
    final success = await userController.updateUserLocal(updatedUser);
    
    if (success) {
      Get.snackbar('Success', user.isActive 
          ? 'User activated successfully' 
          : 'User deactivated successfully');
    } else {
      Get.snackbar('Error', 'Failed to update user status');
    }
  }

  void _confirmDeleteUser(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await userController.deleteUserLocal(user.localId!);
              
              if (success) {
                Get.snackbar('Success', 'User deleted successfully');
                Navigator.pop(context);
              } else {
                Get.snackbar('Error', 'Failed to delete user');
              }
            },
            child: Text('Yes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}