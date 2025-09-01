import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../models/customer.dart';
import '../auth/login_screen.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerProvider>(context, listen: false).fetchCustomers();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        Provider.of<CustomerProvider>(
          context,
          listen: false,
        ).fetchCustomers(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showImageDialog(String imageUrl, String title) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: Text(title),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                ),
                Expanded(
                  child: PhotoView(
                    imageProvider: CachedNetworkImageProvider(imageUrl),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2.0,
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _markSelectedAsFollowed() async {
    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await customerProvider.markSelectedAsFollowed(authProvider.user!.email!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${customerProvider.selectedCount} customers marked as followed',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Follow-up'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Consumer<CustomerProvider>(
            builder: (context, customerProvider, child) {
              if (customerProvider.isSelectionMode) {
                return Row(
                  children: [
                    Text('${customerProvider.selectedCount}'),
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: _markSelectedAsFollowed,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        customerProvider.clearSelection();
                      },
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search customers...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                Provider.of<CustomerProvider>(
                  context,
                  listen: false,
                ).searchCustomers(value);
              },
            ),
          ),
          Expanded(
            child: Consumer<CustomerProvider>(
              builder: (context, customerProvider, child) {
                if (customerProvider.isLoading &&
                    customerProvider.customers.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (customerProvider.customers.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No customers found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => customerProvider.fetchCustomers(),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        customerProvider.customers.length +
                        (customerProvider.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == customerProvider.customers.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final customer = customerProvider.customers[index];
                      final isSelected = customerProvider.selectedCustomers
                          .contains(customer.id);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: GestureDetector(
                            onTap:
                                () => _showImageDialog(
                                  customer.avatarUrl,
                                  customer.login,
                                ),
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                    customer.avatarUrl,
                                  ),
                                ),
                                if (customerProvider.isSelectionMode)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? Colors.blue
                                                : Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isSelected
                                            ? Icons.check
                                            : Icons.circle_outlined,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          title: Text(customer.login),
                          subtitle: Text('ID: ${customer.id}'),
                          trailing:
                              customer.isFollowed
                                  ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                  : null,
                          selected: isSelected,
                          selectedTileColor: Colors.blue.withOpacity(0.1),
                          onTap: () {
                            if (customerProvider.isSelectionMode) {
                              customerProvider.toggleCustomerSelection(
                                customer.id,
                              );
                            }
                          },
                          onLongPress: () {
                            if (!customerProvider.isSelectionMode) {
                              customerProvider.startSelectionMode(customer.id);
                            }
                          },
                        ),
                      );
                    },
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
