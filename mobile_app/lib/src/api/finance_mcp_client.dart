import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/finance_models.dart';
import '../models/mcp_tool.dart';

class FinanceMcpClient {
  FinanceMcpClient({required this.token, http.Client? client})
    : _client = client ?? http.Client(),
      baseUrl = const String.fromEnvironment(
        'API_BASE_URL',
       // defaultValue: 'https://demo-mcp-l0rq.onrender.com',
       defaultValue: 'https://demo-mcp-615058378594.europe-west1.run.app',
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
    int? accountId,
    String? from,
    String? to,
    int? limit,
  }) async {
    try {
      final arguments = <String, dynamic>{};
      if (categoryId != null) {
        arguments['categoryId'] = categoryId;
      }
      if (accountId != null) {
        arguments['accountId'] = accountId;
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
            (item) =>
                FinanceEntry.fromExpenseJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (error) {
      if (!_isUnknownToolError(error, 'list_expenses')) {
        rethrow;
      }

      final queryParams = <String>[];
      if (categoryId != null) queryParams.add('categoryId=$categoryId');
      if (accountId != null) queryParams.add('accountId=$accountId');
      if (from != null) queryParams.add('from=$from');
      if (to != null) queryParams.add('to=$to');
      if (limit != null) queryParams.add('limit=$limit');

      var uri = '$baseUrl/api/finance/expenses';
      if (queryParams.isNotEmpty) {
        uri += '?${queryParams.join('&')}';
      }

      final response = await _client.get(
        Uri.parse(uri),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode >= 400) {
        throw Exception('Failed to fetch expenses: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map(
            (item) =>
                FinanceEntry.fromExpenseJson(item as Map<String, dynamic>),
          )
          .toList();
    }
  }

  Future<List<FinanceEntry>> listIncomes({
    int? categoryId,
    int? accountId,
    String? from,
    String? to,
    int? limit,
  }) async {
    try {
      final arguments = <String, dynamic>{};
      if (categoryId != null) {
        arguments['categoryId'] = categoryId;
      }
      if (accountId != null) {
        arguments['accountId'] = accountId;
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
    } catch (error) {
      if (!_isUnknownToolError(error, 'list_incomes')) {
        rethrow;
      }

      final queryParams = <String>[];
      if (categoryId != null) queryParams.add('categoryId=$categoryId');
      if (accountId != null) queryParams.add('accountId=$accountId');
      if (from != null) queryParams.add('from=$from');
      if (to != null) queryParams.add('to=$to');
      if (limit != null) queryParams.add('limit=$limit');

      var uri = '$baseUrl/api/finance/incomes';
      if (queryParams.isNotEmpty) {
        uri += '?${queryParams.join('&')}';
      }

      final response = await _client.get(
        Uri.parse(uri),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode >= 400) {
        throw Exception('Failed to fetch incomes: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map(
            (item) => FinanceEntry.fromIncomeJson(item as Map<String, dynamic>),
          )
          .toList();
    }
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

  Future<List<DailyExpense>> fetchDailyExpenses({int days = 7}) async {
    try {
      final data = await callTool('daily_expenses', {'days': days});
      final items = data as List<dynamic>;
      return items
          .map((item) => DailyExpense.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (error) {
      if (!_isUnknownToolError(error, 'daily_expenses')) {
        rethrow;
      }

      final response = await _client.get(
        Uri.parse('$baseUrl/api/finance/expenses/daily?days=$days'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode >= 400) {
        throw Exception(
          'Failed to fetch daily expenses: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => DailyExpense.fromJson(item as Map<String, dynamic>))
          .toList();
    }
  }

  Future<List<WeeklyExpense>> fetchWeeklyExpenses({int weeks = 4}) async {
    try {
      final data = await callTool('weekly_expenses', {'weeks': weeks});
      final items = data as List<dynamic>;
      return items
          .map((item) => WeeklyExpense.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (error) {
      if (!_isUnknownToolError(error, 'weekly_expenses')) {
        rethrow;
      }

      final response = await _client.get(
        Uri.parse('$baseUrl/api/finance/expenses/weekly?weeks=$weeks'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode >= 400) {
        throw Exception(
          'Failed to fetch weekly expenses: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => WeeklyExpense.fromJson(item as Map<String, dynamic>))
          .toList();
    }
  }

  Future<List<MonthlyExpense>> fetchMonthlyExpenses({int months = 6}) async {
    try {
      final data = await callTool('monthly_expenses', {'months': months});
      final items = data as List<dynamic>;
      return items
          .map((item) => MonthlyExpense.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (error) {
      if (!_isUnknownToolError(error, 'monthly_expenses')) {
        rethrow;
      }

      final response = await _client.get(
        Uri.parse('$baseUrl/api/finance/expenses/monthly?months=$months'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode >= 400) {
        throw Exception(
          'Failed to fetch monthly expenses: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => MonthlyExpense.fromJson(item as Map<String, dynamic>))
          .toList();
    }
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
    required int accountId,
    required String spentOn,
    String notes = '',
  }) async {
    try {
      await callTool('create_expense', {
        'title': title,
        'amount': amount,
        'categoryId': categoryId,
        'accountId': accountId,
        'spentOn': spentOn,
        'notes': notes,
      });
    } catch (error) {
      if (!_isUnknownToolError(error, 'create_expense')) {
        rethrow;
      }

      final response = await _client.post(
        Uri.parse('$baseUrl/api/finance/expenses'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'title': title,
          'amount': amount,
          'categoryId': categoryId,
          'accountId': accountId,
          'spentOn': spentOn,
          'notes': notes,
        }),
      );

      _throwIfRequestFailed(response);
    }
  }

  Future<void> updateExpense({
    required int id,
    required String title,
    required double amount,
    required int categoryId,
    required int accountId,
    required String spentOn,
    String notes = '',
  }) async {
    try {
      await callTool('update_expense', {
        'id': id,
        'title': title,
        'amount': amount,
        'categoryId': categoryId,
        'accountId': accountId,
        'spentOn': spentOn,
        'notes': notes,
      });
    } catch (error) {
      if (!_isUnknownToolError(error, 'update_expense')) {
        rethrow;
      }

      final response = await _client.put(
        Uri.parse('$baseUrl/api/finance/expenses/$id'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'title': title,
          'amount': amount,
          'categoryId': categoryId,
          'accountId': accountId,
          'spentOn': spentOn,
          'notes': notes,
        }),
      );

      _throwIfRequestFailed(response);
    }
  }

  Future<void> deleteExpense(int id) async {
    await callTool('delete_expense', {'id': id});
  }

  Future<void> createIncome({
    required String title,
    required double amount,
    required int categoryId,
    required int accountId,
    required String receivedOn,
    String notes = '',
  }) async {
    try {
      await callTool('create_income', {
        'title': title,
        'amount': amount,
        'categoryId': categoryId,
        'accountId': accountId,
        'receivedOn': receivedOn,
        'notes': notes,
      });
    } catch (error) {
      if (!_isUnknownToolError(error, 'create_income')) {
        rethrow;
      }

      final response = await _client.post(
        Uri.parse('$baseUrl/api/finance/incomes'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'title': title,
          'amount': amount,
          'categoryId': categoryId,
          'accountId': accountId,
          'receivedOn': receivedOn,
          'notes': notes,
        }),
      );

      _throwIfRequestFailed(response);
    }
  }

  Future<void> updateIncome({
    required int id,
    required String title,
    required double amount,
    required int categoryId,
    required int accountId,
    required String receivedOn,
    String notes = '',
  }) async {
    try {
      await callTool('update_income', {
        'id': id,
        'title': title,
        'amount': amount,
        'categoryId': categoryId,
        'accountId': accountId,
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
          'accountId': accountId,
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

  Future<List<FinanceAccount>> fetchAccounts({
    String? type,
    bool? isActive,
  }) async {
    try {
      final arguments = <String, dynamic>{};
      if (type != null) {
        arguments['type'] = type;
      }
      if (isActive != null) {
        arguments['isActive'] = isActive;
      }
      final data = await callTool('list_accounts', arguments);
      final items = data as List<dynamic>;
      return items
          .map((item) => FinanceAccount.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (error) {
      if (!_isUnknownToolError(error, 'list_accounts')) {
        rethrow;
      }

      var uri = '$baseUrl/api/finance/accounts';
      final queryParams = <String>[];
      if (type != null) queryParams.add('type=$type');
      if (isActive != null) queryParams.add('isActive=$isActive');
      if (queryParams.isNotEmpty) {
        uri += '?${queryParams.join('&')}';
      }

      final response = await _client.get(
        Uri.parse(uri),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode >= 400) {
        throw Exception('Failed to fetch accounts: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => FinanceAccount.fromJson(item as Map<String, dynamic>))
          .toList();
    }
  }

  Future<AccountSummary> fetchAccountSummary(int accountId) async {
    try {
      final data = await callTool('account_summary', {'id': accountId});
      return AccountSummary.fromJson(data as Map<String, dynamic>);
    } catch (error) {
      if (!_isUnknownToolError(error, 'account_summary')) {
        rethrow;
      }

      final response = await _client.get(
        Uri.parse('$baseUrl/api/finance/accounts/$accountId/summary'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode >= 400) {
        throw Exception(
          'Failed to fetch account summary: ${response.statusCode}',
        );
      }

      return AccountSummary.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
  }

  Future<void> createAccount({
    required String name,
    String type = 'cash',
    double initialBalance = 0,
    String color = '#0E7490',
    String icon = 'account_balance_wallet',
    String notes = '',
  }) async {
    try {
      await callTool('create_account', {
        'name': name,
        'type': type,
        'initialBalance': initialBalance,
        'color': color,
        'icon': icon,
        'notes': notes,
      });
    } catch (error) {
      if (!_isUnknownToolError(error, 'create_account')) {
        rethrow;
      }

      final response = await _client.post(
        Uri.parse('$baseUrl/api/finance/accounts'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'name': name,
          'type': type,
          'initialBalance': initialBalance,
          'color': color,
          'icon': icon,
          'notes': notes,
        }),
      );

      _throwIfRequestFailed(response);
    }
  }

  Future<void> updateAccount({
    required int id,
    String? name,
    String? type,
    String? color,
    String? icon,
    String? notes,
    bool? isActive,
  }) async {
    try {
      final arguments = <String, dynamic>{'id': id};
      if (name != null) arguments['name'] = name;
      if (type != null) arguments['type'] = type;
      if (color != null) arguments['color'] = color;
      if (icon != null) arguments['icon'] = icon;
      if (notes != null) arguments['notes'] = notes;
      if (isActive != null) arguments['isActive'] = isActive;
      await callTool('update_account', arguments);
    } catch (error) {
      if (!_isUnknownToolError(error, 'update_account')) {
        rethrow;
      }

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (type != null) body['type'] = type;
      if (color != null) body['color'] = color;
      if (icon != null) body['icon'] = icon;
      if (notes != null) body['notes'] = notes;
      if (isActive != null) body['isActive'] = isActive;

      final response = await _client.put(
        Uri.parse('$baseUrl/api/finance/accounts/$id'),
        headers: _jsonHeaders,
        body: jsonEncode(body),
      );

      _throwIfRequestFailed(response);
    }
  }

  Future<void> deleteAccount(int id) async {
    try {
      await callTool('delete_account', {'id': id});
    } catch (error) {
      if (!_isUnknownToolError(error, 'delete_account')) {
        rethrow;
      }

      final response = await _client.delete(
        Uri.parse('$baseUrl/api/finance/accounts/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      _throwIfRequestFailed(response);
    }
  }

  Future<void> transferBetweenAccounts({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    String notes = '',
  }) async {
    try {
      await callTool('transfer_between_accounts', {
        'fromAccountId': fromAccountId,
        'toAccountId': toAccountId,
        'amount': amount,
        'notes': notes,
      });
    } catch (error) {
      if (!_isUnknownToolError(error, 'transfer_between_accounts')) {
        rethrow;
      }

      final response = await _client.post(
        Uri.parse('$baseUrl/api/finance/transfers'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'fromAccountId': fromAccountId,
          'toAccountId': toAccountId,
          'amount': amount,
          'notes': notes,
        }),
      );

      _throwIfRequestFailed(response);
    }
  }

  Future<List<Transfer>> fetchTransfers({int? accountId, int? limit}) async {
    try {
      final arguments = <String, dynamic>{};
      if (accountId != null) arguments['accountId'] = accountId;
      if (limit != null) arguments['limit'] = limit;
      final data = await callTool('list_transfers', arguments);
      final items = data as List<dynamic>;
      return items
          .map((item) => Transfer.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (error) {
      if (!_isUnknownToolError(error, 'list_transfers')) {
        rethrow;
      }

      var uri = '$baseUrl/api/finance/transfers';
      final queryParams = <String>[];
      if (accountId != null) queryParams.add('accountId=$accountId');
      if (limit != null) queryParams.add('limit=$limit');
      if (queryParams.isNotEmpty) {
        uri += '?${queryParams.join('&')}';
      }

      final response = await _client.get(
        Uri.parse(uri),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode >= 400) {
        throw Exception('Failed to fetch transfers: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => Transfer.fromJson(item as Map<String, dynamic>))
          .toList();
    }
  }

  Future<ChartData> fetchChartData({
    String? type,
    required String period,
    int? accountId,
  }) async {
    try {
      final data = await callTool('get_chart_data', {
        'type': type,
        'period': period,
        'accountId': accountId,
      });
      return ChartData.fromJson(data as Map<String, dynamic>);
    } catch (error) {
      if (!_isUnknownToolError(error, 'get_chart_data')) {
        rethrow;
      }

      var uri = '$baseUrl/api/finance/charts?period=$period';
      if (type != null) uri += '&type=$type';
      if (accountId != null) uri += '&accountId=$accountId';

      final response = await _client.get(
        Uri.parse(uri),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode >= 400) {
        throw Exception('Failed to fetch chart data: ${response.statusCode}');
      }

      return ChartData.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
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

class ChartDataPoint {
  final String label;
  final double value;

  ChartDataPoint({required this.label, required this.value});

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      label: json['label'] as String? ?? '',
      value: (json['value'] as num).toDouble(),
    );
  }
}

class ChartData {
  final String type;
  final String title;
  final String period;
  final List<ChartDataPoint> data;
  final double total;

  ChartData({
    required this.type,
    required this.title,
    required this.period,
    required this.data,
    required this.total,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    final items = json['data'] as List<dynamic>? ?? [];
    return ChartData(
      type: json['type'] as String? ?? 'bar',
      title: json['title'] as String? ?? 'Chart',
      period: json['period'] as String? ?? '',
      data: items
          .map((item) => ChartDataPoint.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );
  }
}
