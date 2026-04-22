import 'dart:convert';

import 'package:http/http.dart' as http;

/// HTTP-only finance API (no MCP). Used for sync, import, and background tasks.
class FinanceRestApi {
  FinanceRestApi({required this.token, http.Client? client})
    : _client = client ?? http.Client(),
      baseUrl = const String.fromEnvironment(
        'API_BASE_URL',
        //defaultValue: 'https://demo-mcp-l0rq.onrender.com',
        defaultValue: 'https://demo-mcp-615058378594.europe-west1.run.app',
      );

  final http.Client _client;
  final String baseUrl;
  final String token;

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  Map<String, String> get _authHeaders => {'Authorization': 'Bearer $token'};

  Future<List<Map<String, dynamic>>> getAccounts() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/finance/accounts'),
      headers: _authHeaders,
    );
    _throwIfFailed(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getCategories({String? kind}) async {
    var uri = '$baseUrl/api/finance/categories';
    if (kind != null) {
      uri += '?kind=${Uri.encodeQueryComponent(kind)}';
    }
    final response = await _client.get(Uri.parse(uri), headers: _authHeaders);
    _throwIfFailed(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getExpenses() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/finance/expenses'),
      headers: _authHeaders,
    );
    _throwIfFailed(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getIncomes() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/finance/incomes'),
      headers: _authHeaders,
    );
    _throwIfFailed(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getTransfers() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/finance/transfers'),
      headers: _authHeaders,
    );
    _throwIfFailed(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getBudgets() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/finance/budgets'),
      headers: _authHeaders,
    );
    _throwIfFailed(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> postAccount(Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/finance/accounts'),
      headers: _headers,
      body: jsonEncode(body),
    );
    _throwIfFailed(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> postCategory(Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/finance/categories'),
      headers: _headers,
      body: jsonEncode(body),
    );
    _throwIfFailed(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> postExpense(Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/finance/expenses'),
      headers: _headers,
      body: jsonEncode(body),
    );
    _throwIfFailed(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> postIncome(Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/finance/incomes'),
      headers: _headers,
      body: jsonEncode(body),
    );
    _throwIfFailed(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> postBudget(Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/finance/budgets'),
      headers: _headers,
      body: jsonEncode(body),
    );
    _throwIfFailed(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> postTransfer(Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/finance/transfers'),
      headers: _headers,
      body: jsonEncode(body),
    );
    _throwIfFailed(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> putExpense(int serverId, Map<String, dynamic> body) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/api/finance/expenses/$serverId'),
      headers: _headers,
      body: jsonEncode(body),
    );
    _throwIfFailed(response);
  }

  Future<void> putIncome(int serverId, Map<String, dynamic> body) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/api/finance/incomes/$serverId'),
      headers: _headers,
      body: jsonEncode(body),
    );
    _throwIfFailed(response);
  }

  Future<void> putAccount(int serverId, Map<String, dynamic> body) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/api/finance/accounts/$serverId'),
      headers: _headers,
      body: jsonEncode(body),
    );
    _throwIfFailed(response);
  }

  Future<void> putCategory(int serverId, Map<String, dynamic> body) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/api/finance/categories/$serverId'),
      headers: _headers,
      body: jsonEncode(body),
    );
    _throwIfFailed(response);
  }

  Future<void> putBudget(int serverId, Map<String, dynamic> body) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/api/finance/budgets/$serverId'),
      headers: _headers,
      body: jsonEncode(body),
    );
    _throwIfFailed(response);
  }

  Future<void> deleteExpense(int serverId) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/finance/expenses/$serverId'),
      headers: _authHeaders,
    );
    if (response.statusCode != 204 && response.statusCode >= 400) {
      _throwIfFailed(response);
    }
  }

  Future<void> deleteIncome(int serverId) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/finance/incomes/$serverId'),
      headers: _authHeaders,
    );
    if (response.statusCode != 204 && response.statusCode >= 400) {
      _throwIfFailed(response);
    }
  }

  Future<void> deleteCategory(int serverId) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/finance/categories/$serverId'),
      headers: _authHeaders,
    );
    if (response.statusCode != 204 && response.statusCode >= 400) {
      _throwIfFailed(response);
    }
  }

  Future<void> deleteBudget(int serverId) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/finance/budgets/$serverId'),
      headers: _authHeaders,
    );
    if (response.statusCode != 204 && response.statusCode >= 400) {
      _throwIfFailed(response);
    }
  }

  Future<void> deleteAccount(int serverId) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/finance/accounts/$serverId'),
      headers: _authHeaders,
    );
    if (response.statusCode != 204 && response.statusCode >= 400) {
      _throwIfFailed(response);
    }
  }

  void _throwIfFailed(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw Exception('HTTP ${response.statusCode}: ${response.body}');
  }
}
