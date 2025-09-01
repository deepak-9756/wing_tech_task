import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/customer_provider.dart';
import '../../models/customer.dart';

class EmployeeDetailsScreen extends StatefulWidget {
  final String employeeEmail;

  const EmployeeDetailsScreen({Key? key, required this.employeeEmail})
    : super(key: key);

  @override
  State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
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
      widget.employeeEmail,
    );

    setState(() {
      followedCustomers = customers;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue,
                  child: Text(
                    widget.employeeEmail[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.employeeEmail,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${followedCustomers.length} customers followed',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
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
                            'No customers followed yet',
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
