import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/customer.dart';

class ApiService {
  static const String baseUrl = 'https://api.github.com/users';

  static Future<List<Customer>> fetchCustomers({
    required int since,
    required int perPage,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl?per_page=$perPage&since=$since'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Customer.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load customers');
    }
  }
}
