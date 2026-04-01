import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/bootstrap_data.dart';
import '../models/expense.dart';

class ExpenseApi {
  ExpenseApi({http.Client? client})
    : _client = client ?? http.Client(),
      baseUrl = const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://demo-mcp-l0rq.onrender.com',
      );

  final http.Client _client;
  final String baseUrl;

  Future<BootstrapData> fetchBootstrap(String month) async {
    final uri = Uri.parse('$baseUrl/api/expenses/bootstrap?month=$month');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load dashboard: ${response.body}');
    }

    return BootstrapData.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<Expense>> fetchExpenses({int limit = 50}) async {
    final uri = Uri.parse('$baseUrl/api/expenses?limit=$limit');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load expenses: ${response.body}');
    }

    final body = jsonDecode(response.body) as List<dynamic>;
    return body
        .map((item) => Expense.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> fetchCategories() async {
    final uri = Uri.parse('$baseUrl/api/expenses/categories');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load categories: ${response.body}');
    }

    final body = jsonDecode(response.body) as List<dynamic>;
    return body.map((item) => item.toString()).toList();
  }

  Future<void> createExpense({
    required String title,
    required double amount,
    required String category,
    required String spentOn,
    String notes = '',
  }) async {
    final uri = Uri.parse('$baseUrl/api/expenses');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'amount': amount,
        'category': category,
        'spentOn': spentOn,
        'notes': notes,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create expense: ${response.body}');
    }
  }
}
