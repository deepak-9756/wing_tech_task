import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../auth/login_screen.dart';
import 'employee_details_screen.dart';
import 'notification_detail_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).startListening();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showNotificationDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Customer Follow-up'),
            content: Text(
              '${notification['employeeEmail']} has followed up with customers',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Provider.of<NotificationProvider>(
                    context,
                    listen: false,
                  ).markAsRead(notification['id']);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Provider.of<NotificationProvider>(
                    context,
                    listen: false,
                  ).markAsRead(notification['id']);

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => NotificationDetailScreen(
                            notification: notification,
                          ),
                    ),
                  );
                },
                child: const Text('View'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [Tab(text: 'Employees'), Tab(text: 'Notifications')],
        ),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'logout') {
                authProvider.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'logout', child: Text('Logout')),
                ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildEmployeesList(), _buildNotificationsList()],
      ),
    );
  }

  Widget _buildEmployeesList() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .where('email', isNotEqualTo: 'testwtsm@gmail.com')
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No employees registered',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final employee = doc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    employee['email'][0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(employee['email']),
                subtitle: Text(
                  'Joined: ${employee['createdAt'] != null ? (employee['createdAt'] as Timestamp).toDate().toString().split(' ')[0] : 'Unknown'}',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => EmployeeDetailsScreen(
                            employeeEmail: employee['email'],
                          ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationsList() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final notifications = notificationProvider.notifications;

        if (notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No new notifications',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.notifications, color: Colors.white),
                ),
                title: Text('Follow-up Update'),
                subtitle: Text(
                  '${notification['employeeEmail']} has followed up with customers',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        notificationProvider.markAsRead(notification['id']);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        notificationProvider.markAsRead(notification['id']);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (_) => NotificationDetailScreen(
                                  notification: notification,
                                ),
                          ),
                        );
                      },
                      child: const Text('View'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
