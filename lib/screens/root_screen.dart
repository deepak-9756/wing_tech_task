import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import 'employee/employee_home_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'auth/login_screen.dart'; // ← ADD THIS

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid != null) {
      Future.microtask(() {
        context.read<UserProvider>().fetchUser(uid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        // Loading state
        if (userProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = userProvider.user;

        // ← IMPROVED ERROR HANDLING
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    userProvider.error ?? 'Error loading user profile',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Retry
                      final uid = context.read<AuthProvider>().currentUser?.uid;
                      if (uid != null) {
                        context.read<UserProvider>().fetchUser(uid);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      // Logout
                      context.read<AuthProvider>().signOut();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          );
        }

        // Role-based navigation
        if (user.role == 'admin') {
          return const AdminDashboardScreen();
        } else {
          return const EmployeeHomeScreen();
        }
      },
    );
  }
}
