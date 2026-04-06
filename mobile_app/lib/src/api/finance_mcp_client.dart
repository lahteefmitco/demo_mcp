import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/finance_models.dart';
import '../models/mcp_tool.dart';

class FinanceMcpClient {
  FinanceMcpClient({required this.token, http.Client? client})
    : _client = client ?? http.Client(),
      baseUrl = const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://demo-mcp-l0rq.onrender.com',
      );

  final http.Client _client;
  final String baseUrl;
  final String token;
  int _requestId = 1;
  bool _initialized = false;

  Uri get _mcpUri => Uri.parse('$baseUrl/mcp');

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final initializeResponse = await _postJsonRpc({
      'jsonrpc': '2.0',
      'id': _nextId(),
      'method': 'initialize',
      'params': {
        'protocolVersion': '2025-11-25',
        'capabilities': {},
        'clientInfo': {'name': 'finance-mobile-flutter', 'version': '2.0.0'},
      },
    });

    if (initializeResponse['error'] != null) {
      throw Exception('MCP initialize failed: ${initializeResponse['error']}');
    }

    await _postJsonRpc({
      'jsonrpc': '2.0',
      'method': 'notifications/initialized',
    }, expectBody: false);

    _initialized = true;
  }

  Future<List<McpTool>> listTools() async {
    await initialize();

    final response = await _postJsonRpc({
      'jsonrpc': '2.0',
      'id': _nextId(),
      'method': 'tools/list',
      'params': {},
    });

    final toolsJson = response['result']?['tools'] as List<dynamic>? ?? [];
    return toolsJson
        .map((item) => McpTool.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<FinanceDashboard> fetchDashboard(String month) async {
    final data = await callTool('finance_dashboard', {'month': month});
    return FinanceDashboard.fromJson(data as Map<String, dynamic>);
  }

  Future<List<FinanceCategory>> fetchCategories({String? kind}) async {
    final arguments = <String, dynamic>{};
    if (kind != null) {
      arguments['kind'] = kind;
    }
    final data = await callTool('list_categories', arguments);
    final items = data as List<dynamic>;
    return items
        .map((item) => FinanceCategory.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<FinanceEntry>> listExpenses({
    int? categoryId,
    String? from,
    String? to,
    int? limit,
  }) async {
    final arguments = <String, dynamic>{};
    if (categoryId != null) {
      arguments['categoryId'] = categoryId;
    }
    if (from != null) {
      arguments['from'] = from;
    }
    if (to != null) {
      arguments['to'] = to;
    }
    if (limit != null) {
      arguments['limit'] = limit;
    }
    final data = await callTool('list_expenses', arguments);
    final items = data as List<dynamic>;
    return items
        .map(
          (item) => FinanceEntry.fromExpenseJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<FinanceEntry>> listIncomes({
    int? categoryId,
    String? from,
    String? to,
    int? limit,
  }) async {
    final arguments = <String, dynamic>{};
    if (categoryId != null) {
      arguments['categoryId'] = categoryId;
    }
    if (from != null) {
      arguments['from'] = from;
    }
    if (to != null) {
      arguments['to'] = to;
    }
    if (limit != null) {
      arguments['limit'] = limit;
    }
    final data = await callTool('list_incomes', arguments);
    final items = data as List<dynamic>;
    return items
        .map(
          (item) => FinanceEntry.fromIncomeJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<BudgetItem>> fetchBudgets({String? period}) async {
    final arguments = <String, dynamic>{};
    if (period != null) {
      arguments['period'] = period;
    }
    final data = await callTool('list_budgets', arguments);
    final items = data as List<dynamic>;
    return items
        .map((item) => BudgetItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createCategory({
    required String name,
    required String kind,
    required String color,
    required String icon,
  }) async {
    await callTool('create_category', {
      'name': name,
      'kind': kind,
      'color': color,
      'icon': icon,
    });
  }

  Future<void> updateCategory({
    required int id,
    required String name,
    required String kind,
    required String color,
    required String icon,
  }) async {
    try {
      await callTool('update_category', {
        'id': id,
        'name': name,
        'kind': kind,
        'color': color,
        'icon': icon,
      });
    } catch (error) {
      if (!_isUnknownToolError(error, 'update_category')) {
        rethrow;
      }

      final response = await _client.put(
        Uri.parse('$baseUrl/api/finance/categories/$id'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'name': name,
          'kind': kind,
          'color': color,
          'icon': icon,
        }),
      );

      _throwIfRequestFailed(response);
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await callTool('delete_category', {'id': id});
    } catch (error) {
      if (!_isUnknownToolError(error, 'delete_category')) {
        rethrow;
      }

      final response = await _client.delete(
        Uri.parse('$baseUrl/api/finance/categories/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      _throwIfRequestFailed(response);
    }
  }

  Future<void> createExpense({
    required String title,
    required double amount,
    required int categoryId,
    required String spentOn,
    String notes = '',
  }) async {
    await callTool('create_expense', {
      'title': title,
      'amount': amount,
      'categoryId': categoryId,
      'spentOn': spentOn,
      'notes': notes,
    });
  }

  Future<void> updateExpense({
    required int id,
    required String title,
    required double amount,
    required int categoryId,
    required String spentOn,
    String notes = '',
  }) async {
    await callTool('update_expense', {
      'id': id,
      'title': title,
      'amount': amount,
      'categoryId': categoryId,
      'spentOn': spentOn,
      'notes': notes,
    });
  }

  Future<void> deleteExpense(int id) async {
    await callTool('delete_expense', {'id': id});
  }

  Future<void> createIncome({
    required String title,
    required double amount,
    required int categoryId,
    required String receivedOn,
    String notes = '',
  }) async {
    await callTool('create_income', {
      'title': title,
      'amount': amount,
      'categoryId': categoryId,
      'receivedOn': receivedOn,
      'notes': notes,
    });
  }

  Future<void> updateIncome({
    required int id,
    required String title,
    required double amount,
    required int categoryId,
    required String receivedOn,
    String notes = '',
  }) async {
    try {
      await callTool('update_income', {
        'id': id,
        'title': title,
        'amount': amount,
        'categoryId': categoryId,
        'receivedOn': receivedOn,
        'notes': notes,
      });
    } catch (error) {
      if (!_isUnknownToolError(error, 'update_income')) {
        rethrow;
      }

      final response = await _client.put(
        Uri.parse('$baseUrl/api/finance/incomes/$id'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'title': title,
          'amount': amount,
          'categoryId': categoryId,
          'receivedOn': receivedOn,
          'notes': notes,
        }),
      );

      _throwIfRequestFailed(response);
    }
  }

  Future<void> deleteIncome(int id) async {
    try {
      await callTool('delete_income', {'id': id});
    } catch (error) {
      if (!_isUnknownToolError(error, 'delete_income')) {
        rethrow;
      }

      final response = await _client.delete(
        Uri.parse('$baseUrl/api/finance/incomes/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      _throwIfRequestFailed(response);
    }
  }

  Future<void> createBudget({
    required String name,
    required double amount,
    required String period,
    required String startDate,
    int? categoryId,
    String notes = '',
  }) async {
    await callTool('create_budget', {
      'name': name,
      'amount': amount,
      'period': period,
      'startDate': startDate,
      'categoryId': categoryId,
      'notes': notes,
    });
  }

  Future<void> updateBudget({
    required int id,
    required String name,
    required double amount,
    required String period,
    required String startDate,
    int? categoryId,
    String notes = '',
  }) async {
    try {
      await callTool('update_budget', {
        'id': id,
        'name': name,
        'amount': amount,
        'period': period,
        'startDate': startDate,
        'categoryId': categoryId,
        'notes': notes,
      });
    } catch (error) {
      if (!_isUnknownToolError(error, 'update_budget')) {
        rethrow;
      }

      final response = await _client.put(
        Uri.parse('$baseUrl/api/finance/budgets/$id'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'name': name,
          'amount': amount,
          'period': period,
          'startDate': startDate,
          'categoryId': categoryId,
          'notes': notes,
        }),
      );

      _throwIfRequestFailed(response);
    }
  }

  Future<void> deleteBudget(int id) async {
    try {
      await callTool('delete_budget', {'id': id});
    } catch (error) {
      if (!_isUnknownToolError(error, 'delete_budget')) {
        rethrow;
      }

      final response = await _client.delete(
        Uri.parse('$baseUrl/api/finance/budgets/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      _throwIfRequestFailed(response);
    }
  }

  Future<dynamic> callTool(
    String toolName,
    Map<String, dynamic> arguments,
  ) async {
    await initialize();

    final response = await _postJsonRpc({
      'jsonrpc': '2.0',
      'id': _nextId(),
      'method': 'tools/call',
      'params': {'name': toolName, 'arguments': arguments},
    });

    if (response['error'] != null) {
      throw Exception('MCP tool call failed: ${response['error']}');
    }

    final content = response['result']?['content'] as List<dynamic>? ?? [];
    if (content.isEmpty) {
      return null;
    }

    final first = content.first as Map<String, dynamic>;
    final text = first['text'] as String? ?? 'null';
    return jsonDecode(text);
  }

  Future<Map<String, dynamic>> _postJsonRpc(
    Map<String, dynamic> payload, {
    bool expectBody = true,
  }) async {
    final authorizedResponse = await _client.post(
      _mcpUri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/event-stream',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (authorizedResponse.statusCode >= 400) {
      throw Exception(
        'HTTP ${authorizedResponse.statusCode}: ${authorizedResponse.body}',
      );
    }

    if (!expectBody || authorizedResponse.body.trim().isEmpty) {
      return {};
    }

    final contentType = authorizedResponse.headers['content-type'] ?? '';
    if (contentType.contains('text/event-stream')) {
      return _parseSseJson(authorizedResponse.body);
    }

    return jsonDecode(authorizedResponse.body) as Map<String, dynamic>;
  }

  Map<String, dynamic> _parseSseJson(String body) {
    final lines = body.split('\n');
    final dataLines = <String>[];

    for (final line in lines) {
      if (line.startsWith('data:')) {
        dataLines.add(line.substring(5).trimLeft());
      }
    }

    if (dataLines.isEmpty) {
      throw Exception('MCP SSE response did not include any data payload');
    }

    return jsonDecode(dataLines.join('\n')) as Map<String, dynamic>;
  }

  Map<String, String> get _jsonHeaders => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  bool _isUnknownToolError(Object error, String toolName) {
    final message = error.toString();
    return message.contains('Unknown tool: $toolName');
  }

  void _throwIfRequestFailed(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(_extractErrorMessage(response));
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['error'] is String) {
        return body['error'] as String;
      }

      if (body['errors'] is List) {
        return (body['errors'] as List<dynamic>).join(', ');
      }
    } catch (_) {}

    return 'Request failed (${response.statusCode})';
  }

  int _nextId() {
    final id = _requestId;
    _requestId += 1;
    return id;
  }
}
