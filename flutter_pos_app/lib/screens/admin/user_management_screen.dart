import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_controller.dart';
import '../../models/user.dart';
import '../../widgets/loading_overlay.dart';
import '../../constants/app_constants.dart';

class UserManagementScreen extends StatelessWidget {
  final UserController userController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (userController.isLoading.value) {
          return LoadingOverlay();
        }

        return Column(
          children: [
            // Add User Button
            Padding(
              padding: EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _showAddUserDialog(context),
                child: Text('Add Server'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            
            // Users List
            Expanded(
              child: ListView.builder(
                itemCount: userController.users.length,
                itemBuilder: (context, index) {
                  final user = userController.users[index];
                  return _buildUserCard(user, index);
                },
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildUserCard(User user, int index) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.isAdmin ? Colors.red : Colors.green,
          child: Text(
            user.name.substring(0, 1).toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(user.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: ${user.phone}'),
            Text('Role: ${user.role.toUpperCase()}'),
            Text('PIN: ${'*' * AppConstants.minPinLength}'), // Mask the PIN
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditUserDialog(user),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDeleteUser(user),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController pinController = TextEditingController();
    final roleController = Get.put(Get.find<UserController>());
    
    showDialog(
      context: context,
      builder: (context) {
        String selectedRole = 'server'; // Default to server role
        
        return AlertDialog(
          title: Text('Add New Server'),
          content: SingleChildScrollView(
            child: Column(
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
                  decoration: InputDecoration(labelText: 'PIN (${AppConstants.minPinLength} digits)'),
                  keyboardType: TextInputType.number,
                  maxLength: AppConstants.minPinLength,
                ),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: ['admin', 'server']
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) selectedRole = value;
                  },
                  decoration: InputDecoration(labelText: 'Role'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            Obx(() {
              final isLoading = roleController.isLoading.value;
              return ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (nameController.text.isEmpty ||
                            phoneController.text.isEmpty ||
                            pinController.text.length != AppConstants.minPinLength) {
                          Get.snackbar('Error', 'Please fill all fields correctly');
                          return;
                        }

                        final newUser = User(
                          name: nameController.text,
                          phone: phoneController.text,
                          role: selectedRole,
                          pin: pinController.text,
                          isActive: true,
                          updatedAt: DateTime.now(),
                        );

                        final success = await roleController.createUserLocal(newUser);
                        if (success) {
                          Get.snackbar('Success', AppConstants.userCreated);
                          Navigator.pop(context);
                        } else {
                          Get.snackbar('Error', 'Failed to create user');
                        }
                      },
                child: isLoading ? CircularProgressIndicator() : Text('Save'),
              );
            }),
          ],
        );
      },
    );
  }

  void _showEditUserDialog(User user) {
    final TextEditingController nameController = TextEditingController(text: user.name);
    final TextEditingController phoneController = TextEditingController(text: user.phone);
    final TextEditingController pinController = TextEditingController(text: user.pin);
    final roleController = Get.find<UserController>();
    
    showDialog(
      context: Get.context!,
      builder: (context) {
        String selectedRole = user.role;
        
        return AlertDialog(
          title: Text('Edit User'),
          content: SingleChildScrollView(
            child: Column(
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
                  decoration: InputDecoration(labelText: 'PIN (${AppConstants.minPinLength} digits)'),
                  keyboardType: TextInputType.number,
                  maxLength: AppConstants.minPinLength,
                ),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: ['admin', 'server']
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) selectedRole = value;
                  },
                  decoration: InputDecoration(labelText: 'Role'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            Obx(() {
              final isLoading = roleController.isLoading.value;
              return ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (nameController.text.isEmpty ||
                            phoneController.text.isEmpty ||
                            pinController.text.length != AppConstants.minPinLength) {
                          Get.snackbar('Error', 'Please fill all fields correctly');
                          return;
                        }

                        // For now, we'll need to implement a way to find the local ID
                        // Since we don't have direct access to local ID in the user object,
                        // we'll need to find it by querying the database
                        // This is a simplified approach
                        final updatedUser = user.copyWith(
                          name: nameController.text,
                          phone: phoneController.text,
                          role: selectedRole,
                          pin: pinController.text,
                          updatedAt: DateTime.now(),
                        );

                        // Note: We need to find the local ID to update the user
                        // This requires a database query to find the local ID based on server ID
                        // For now, we'll skip the update until we have a better solution
                        Get.snackbar('Info', 'Update functionality needs implementation');
                        Navigator.pop(context);
                      },
                child: isLoading ? CircularProgressIndicator() : Text('Update'),
              );
            }),
          ],
        );
      },
    );
  }

  void _confirmDeleteUser(User user) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deactivation'),
        content: Text('Are you sure you want to deactivate ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          Obx(() {
            final isLoading = Get.find<UserController>().isLoading.value;
            return ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      // Note: We need the local ID to deactivate the user
                      // For now, showing a message
                      Get.snackbar('Info', 'Deactivate functionality needs implementation');
                      Navigator.pop(context);
                    },
              child: isLoading ? CircularProgressIndicator() : Text('Deactivate'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            );
          }),
        ],
      ),
    );
  }
}