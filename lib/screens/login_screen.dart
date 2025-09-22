// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Title
              Icon(
                Icons.inventory,
                size: 80,
                color: Colors.blue[700],
              ),
              SizedBox(height: 16),
              Text(
                'Asset Management',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              Text(
                'System',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              SizedBox(height: 48),
              
              // Email Field
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              
              // Password Field
              Obx(() => TextField(
                controller: passwordController,
                obscureText: authController.obscurePassword.value,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      authController.obscurePassword.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () => authController.togglePasswordVisibility(),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )),
              SizedBox(height: 24),
              
              // Login Button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: authController.isLoading.value
                      ? null
                      : () => _handleLogin(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: authController.isLoading.value
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Login',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              )),
              
              SizedBox(height: 16),
              
              // Register Link
              TextButton(
                onPressed: () => _showRegisterDialog(context),
                child: Text(
                  'Don\'t have an account? Register here',
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    authController.signIn(emailController.text, passwordController.text);
  }

  void _showRegisterDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    Get.dialog(
      Dialog(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Register New User',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty &&
                          emailController.text.isNotEmpty &&
                          passwordController.text.isNotEmpty) {
                        authController.signUp(
                          emailController.text,
                          passwordController.text,
                          nameController.text,
                        );
                        Get.back();
                      }
                    },
                    child: Text('Register'),
                  ),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
