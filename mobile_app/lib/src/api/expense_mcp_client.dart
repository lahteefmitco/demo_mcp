import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/bootstrap_data.dart';
import '../models/expense.dart';
import '../models/mcp_tool.dart';

class ExpenseMcpClient {
  ExpenseMcpClient({http.Client? client})
    : _client = client ?? http.Client(),
      baseUrl = const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://demo-mcp-l0rq.onrender.com',
      );

  final http.Client _client;
  final String baseUrl;
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
        'clientInfo': {'name': 'expense-mobile-flutter', 'version': '1.0.0'},
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

  Future<BootstrapData> fetchDashboard(String month) async {
    final data = await callTool('dashboard_snapshot', {'month': month});
    return BootstrapData.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Expense>> fetchExpenses({int limit = 50}) async {
    final data = await callTool('list_expenses', {'limit': limit});
    final items = data as List<dynamic>;
    return items
        .map((item) => Expense.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> fetchCategories() async {
    final data = await callTool('list_categories', {});
    final items = data as List<dynamic>;
    return items.map((item) => item.toString()).toList();
  }

  Future<void> createExpense({
    required String title,
    required double amount,
    required String category,
    required String spentOn,
    String notes = '',
  }) async {
    await callTool('create_expense', {
      'title': title,
      'amount': amount,
      'category': category,
      'spentOn': spentOn,
      'notes': notes,
    });
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
    final response = await _client.post(
      _mcpUri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/event-stream',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 400) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    if (!expectBody || response.body.trim().isEmpty) {
      return {};
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  int _nextId() {
    final id = _requestId;
    _requestId += 1;
    return id;
  }
}
