import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/customer_provider.dart';
import '../../models/customer.dart';

class NotificationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> notification;

  const NotificationDetailScreen({Key? key, required this.notification})
    : super(key: key);

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  List<Customer> followedCustomers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFollowedCustomers();
  }

  Future<void> _loadFollowedCustomers() async {
    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );
    final customers = await customerProvider.getFollowedCustomers(
      widget.notification['employeeEmail'],
    );

    // Filter customers by the notification's customer IDs
    final notificationCustomerIds = List<int>.from(
      widget.notification['customerIds'] ?? [],
    );
    final filteredCustomers =
        customers
            .where((customer) => notificationCustomerIds.contains(customer.id))
            .toList();

    setState(() {
      followedCustomers = filteredCustomers;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Follow-up Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.orange.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text(
                      'Follow-up Notification',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Employee: ${widget.notification['employeeEmail']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Customers followed: ${followedCustomers.length}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : followedCustomers.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No customers found for this notification',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: followedCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = followedCustomers[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                customer.avatarUrl,
                              ),
                            ),
                            title: Text(customer.login),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ID: ${customer.id}'),
                                if (customer.followedAt != null)
                                  Text(
                                    'Followed: ${customer.followedAt!.toString().split(' ')[0]}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
