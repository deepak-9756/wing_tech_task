import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class CustomerProvider extends ChangeNotifier {
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  Set<int> _selectedCustomers = <int>{};
  bool _isLoading = false;
  bool _isSelectionMode = false;
  int _currentSince = 0;
  String _searchQuery = '';

  List<Customer> get customers => _filteredCustomers;
  Set<int> get selectedCustomers => _selectedCustomers;
  bool get isLoading => _isLoading;
  bool get isSelectionMode => _isSelectionMode;
  int get selectedCount => _selectedCustomers.length;

  Future<void> fetchCustomers({bool loadMore = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (!loadMore) {
        _currentSince = 0;
        _customers.clear();
      }

      final newCustomers = await ApiService.fetchCustomers(
        since: _currentSince,
        perPage: 10,
      );

      if (newCustomers.isNotEmpty) {
        _customers.addAll(newCustomers);
        _currentSince = newCustomers.last.id + 1;

        // Save to local database
        for (var customer in newCustomers) {
          await DatabaseService.instance.insertCustomer(customer);
        }
      }

      _filterCustomers();
    } catch (e) {
      // Load from local database if API fails
      if (_customers.isEmpty) {
        _customers = await DatabaseService.instance.getCustomers();
        _filterCustomers();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  void searchCustomers(String query) {
    _searchQuery = query.toLowerCase();
    _filterCustomers();
  }

  void _filterCustomers() {
    if (_searchQuery.isEmpty) {
      _filteredCustomers = List.from(_customers);
    } else {
      _filteredCustomers =
          _customers
              .where(
                (customer) =>
                    customer.login.toLowerCase().contains(_searchQuery) ||
                    customer.id.toString().contains(_searchQuery),
              )
              .toList();
    }
    notifyListeners();
  }

  void toggleCustomerSelection(int customerId) {
    if (_selectedCustomers.contains(customerId)) {
      _selectedCustomers.remove(customerId);
    } else {
      _selectedCustomers.add(customerId);
    }

    _isSelectionMode = _selectedCustomers.isNotEmpty;
    notifyListeners();
  }

  void startSelectionMode(int customerId) {
    _isSelectionMode = true;
    _selectedCustomers.add(customerId);
    notifyListeners();
  }

  void clearSelection() {
    _selectedCustomers.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  Future<void> markSelectedAsFollowed(String employeeEmail) async {
    if (_selectedCustomers.isEmpty) return;

    final selectedCustomersList =
        _customers
            .where((customer) => _selectedCustomers.contains(customer.id))
            .toList();

    // Update local database
    for (var customerId in _selectedCustomers) {
      await DatabaseService.instance.markCustomerAsFollowed(
        customerId,
        employeeEmail,
      );
    }

    // Send notification to admin
    await FirebaseFirestore.instance.collection('notifications').add({
      'employeeEmail': employeeEmail,
      'customerIds': _selectedCustomers.toList(),
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    clearSelection();
    notifyListeners();
  }

  Future<List<Customer>> getFollowedCustomers(String employeeEmail) async {
    return await DatabaseService.instance.getFollowedCustomers(employeeEmail);
  }
}
