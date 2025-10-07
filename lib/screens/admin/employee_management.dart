import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_button.dart';

class EmployeeManagementScreen extends StatelessWidget {
  final AuthService authService = Get.find();
  final FirestoreService firestoreService = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Employees'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddEmployeeDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: firestoreService.getAllEmployees(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No employees found', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEmployeeDialog(context),
                    icon: Icon(Icons.add),
                    label: Text('Add Employee'),
                  ),
                ],
              ),
            );
          }

          List<UserModel> employees = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: employees.length,
            itemBuilder: (context, index) {
              UserModel employee = employees[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(employee.name[0].toUpperCase()),
                    backgroundColor: Colors.blue,
                  ),
                  title: Text(employee.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${employee.employeeId}'),
                      Text('Email: ${employee.email}'),
                      if (employee.department != null)
                        Text('Department: ${employee.department}'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                          onTap: () {
                            Navigator.pop(context);
                            _showEditEmployeeDialog(context, employee);
                          },
                        ),
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(
                            employee.isActive ? Icons.block : Icons.check_circle,
                            color: employee.isActive ? Colors.red : Colors.green,
                          ),
                          title: Text(employee.isActive ? 'Deactivate' : 'Activate'),
                          onTap: () {
                            Navigator.pop(context);
                            _toggleEmployeeStatus(employee);
                          },
                        ),
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Delete', style: TextStyle(color: Colors.red)),
                          onTap: () {
                            Navigator.pop(context);
                            _showDeleteConfirmDialog(context, employee);
                          },
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddEmployeeDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final employeeIdController = TextEditingController();
    final phoneController = TextEditingController();
    final departmentController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Employee'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Full Name *'),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email *'),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    if (!value!.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                TextFormField(
                  controller: employeeIdController,
                  decoration: InputDecoration(labelText: 'Employee ID *'),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                ),
                TextFormField(
                  controller: departmentController,
                  decoration: InputDecoration(labelText: 'Department'),
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password *'),
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    if (value!.length < 6) return '6+ characters';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                String? error = await authService.registerEmployee(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                  name: nameController.text.trim(),
                  employeeId: employeeIdController.text.trim(),
                  phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                  department: departmentController.text.trim().isEmpty ? null : departmentController.text.trim(),
                );

                Navigator.pop(context);
                if (error == null) {
                  Get.snackbar('Success', 'Employee added successfully');
                } else {
                  Get.snackbar('Error', error);
                }
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditEmployeeDialog(BuildContext context, UserModel employee) {
    // Similar implementation for editing employee details
  }

  void _toggleEmployeeStatus(UserModel employee) async {
    String? error = await firestoreService.updateEmployeeStatus(employee.uid, !employee.isActive);
    if (error == null) {
      Get.snackbar('Success', '${employee.name} ${employee.isActive ? 'deactivated' : 'activated'}');
    } else {
      Get.snackbar('Error', error);
    }
  }

  void _showDeleteConfirmDialog(BuildContext context, UserModel employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              String? error = await firestoreService.deleteEmployee(employee.uid);
              if (error == null) {
                Get.snackbar('Success', 'Employee deleted successfully');
              } else {
                Get.snackbar('Error', error);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
