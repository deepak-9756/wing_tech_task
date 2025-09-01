import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'employee/employee_home_screen.dart';
import 'admin/admin_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.isAuthenticated) {
        if (authProvider.isAdmin) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const EmployeeHomeScreen()),
          );
        }
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 80, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Task Manager',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
