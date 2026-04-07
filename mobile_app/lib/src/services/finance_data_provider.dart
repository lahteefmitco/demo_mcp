import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../api/finance_mcp_client.dart';
import '../database/finance_database.dart';
import '../models/finance_models.dart';
import '../settings/app_preferences_storage.dart';

class FinanceDataProvider {
  static final FinanceDataProvider _instance = FinanceDataProvider._internal();
  factory FinanceDataProvider() => _instance;
  FinanceDataProvider._internal();

  final _db = FinanceDatabase();
  final _storage = AppPreferencesStorage();
  final _uuid = const Uuid();
  final Map<String, FinanceMcpClient> _clients = {};

  FinanceMcpClient _getClient(String token) {
    if (!_clients.containsKey(token)) {
      _clients[token] = FinanceMcpClient(token: token);
    }
    return _clients[token]!;
  }

  Future<bool> _shouldLoadFromBackend() async {
    return _storage.readLoadFromBackend();
  }

  Future<FinanceDashboard> getDashboard(String token, String month) async {
    if (await _shouldLoadFromBackend()) {
      final client = _getClient(token);
      return client.fetchDashboard(month);
    }
    return _getLocalDashboard();
  }

  Future<FinanceDashboard> _getLocalDashboard() async {
    final categories = await _db.getAllCategories();
    final accounts = await _db.getAllAccounts();
    final expenses = await _db.getAllExpenses();
    final incomes = await _db.getAllIncomes();
    final budgets = await _db.getAllBudgets();

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    final monthExpenses = expenses.where((e) {
      return e.spentOn.isAfter(monthStart.subtract(const Duration(days: 1))) &&
          e.spentOn.isBefore(monthEnd.add(const Duration(days: 1)));
    }).toList();

    final monthIncomes = incomes.where((i) {
      return i.receivedOn.isAfter(
            monthStart.subtract(const Duration(days: 1)),
          ) &&
          i.receivedOn.isBefore(monthEnd.add(const Duration(days: 1)));
    }).toList();

    final expenseTotal = monthExpenses.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );
    final incomeTotal = monthIncomes.fold<double>(
      0,
      (sum, i) => sum + i.amount,
    );

    final Map<String, double> expenseByCategory = {};
    for (final exp in monthExpenses) {
      final cat = categories
          .where((c) => c.serverId == exp.categoryId)
          .firstOrNull;
      final catName = cat?.name ?? 'Unknown';
      expenseByCategory[catName] =
          (expenseByCategory[catName] ?? 0) + exp.amount;
    }

    final categoryList = categories
        .map(
          (c) => FinanceCategory(
            id: c.serverId ?? 0,
            name: c.name,
            kind: c.kind,
            color: c.color,
            icon: c.icon,
          ),
        )
        .toList();

    final accountList = accounts
        .map(
          (a) => FinanceAccount(
            id: a.serverId ?? 0,
            name: a.name,
            type: a.type,
            initialBalance: a.initialBalance,
            currentBalance: a.currentBalance,
            color: a.color,
            icon: a.icon,
            notes: a.notes,
            isActive: a.isActive,
          ),
        )
        .toList();

    final expenseList = monthExpenses.map((e) {
      final cat = categories
          .where((c) => c.serverId == e.categoryId)
          .firstOrNull;
      final acc = accounts.where((a) => a.serverId == e.accountId).firstOrNull;
      return FinanceEntry(
        id: e.serverId ?? 0,
        title: e.title,
        amount: e.amount,
        categoryId: e.categoryId,
        categoryName: cat?.name ?? '',
        categoryColor: cat?.color ?? '#0E7490',
        accountId: e.accountId,
        accountName: acc?.name ?? '',
        accountColor: acc?.color ?? '#10B981',
        date: e.spentOn.toIso8601String().split('T')[0],
        notes: e.notes,
      );
    }).toList();

    final incomeList = monthIncomes.map((i) {
      final cat = categories
          .where((c) => c.serverId == i.categoryId)
          .firstOrNull;
      final acc = accounts.where((a) => a.serverId == i.accountId).firstOrNull;
      return FinanceEntry(
        id: i.serverId ?? 0,
        title: i.title,
        amount: i.amount,
        categoryId: i.categoryId,
        categoryName: cat?.name ?? '',
        categoryColor: cat?.color ?? '#0E7490',
        accountId: i.accountId,
        accountName: acc?.name ?? '',
        accountColor: acc?.color ?? '#10B981',
        date: i.receivedOn.toIso8601String().split('T')[0],
        notes: i.notes,
      );
    }).toList();

    final budgetList = budgets.map((b) {
      final cat = categories
          .where((c) => c.serverId == b.categoryId)
          .firstOrNull;
      return BudgetItem(
        id: b.serverId ?? 0,
        name: b.name,
        amount: b.amount,
        period: b.period,
        startDate: b.startDate.toIso8601String().split('T')[0],
        endDate: b.endDate.toIso8601String().split('T')[0],
        notes: b.notes,
        categoryId: b.categoryId,
        categoryName: cat?.name,
        categoryColor: cat?.color,
        spent: 0,
        remaining: b.amount,
      );
    }).toList();

    final now2 = DateTime.now();
    final month = '${now2.year}-${now2.month.toString().padLeft(2, '0')}';

    return FinanceDashboard(
      month: month,
      summary: PeriodSummary(
        month: month,
        expenseTotal: expenseTotal,
        expenseCount: monthExpenses.length,
        incomeTotal: incomeTotal,
        incomeCount: monthIncomes.length,
        balance: incomeTotal - expenseTotal,
        expenseByCategory: expenseByCategory.entries
            .map(
              (e) => CategorySpend(
                category: e.key,
                color: '#0E7490',
                total: e.value,
              ),
            )
            .toList(),
      ),
      categories: categoryList,
      accounts: accountList,
      recentExpenses: expenseList,
      recentIncomes: incomeList,
      budgets: budgetList,
    );
  }

  Future<List<FinanceCategory>> getCategories(
    String token, {
    String? kind,
  }) async {
    if (await _shouldLoadFromBackend()) {
      final client = _getClient(token);
      return client.fetchCategories(kind: kind);
    }
    return _getLocalCategories();
  }

  Future<List<FinanceCategory>> _getLocalCategories() async {
    final categories = await _db.getAllCategories();
    return categories
        .map(
          (c) => FinanceCategory(
            id: c.serverId ?? 0,
            name: c.name,
            kind: c.kind,
            color: c.color,
            icon: c.icon,
          ),
        )
        .toList();
  }

  Future<List<FinanceAccount>> getAccounts(String token) async {
    if (await _shouldLoadFromBackend()) {
      final client = _getClient(token);
      return client.fetchAccounts();
    }
    return _getLocalAccounts();
  }

  Future<List<FinanceAccount>> _getLocalAccounts() async {
    final accounts = await _db.getAllAccounts();
    return accounts
        .map(
          (a) => FinanceAccount(
            id: a.serverId ?? 0,
            name: a.name,
            type: a.type,
            initialBalance: a.initialBalance,
            currentBalance: a.currentBalance,
            color: a.color,
            icon: a.icon,
            notes: a.notes,
            isActive: a.isActive,
          ),
        )
        .toList();
  }

  Future<List<FinanceEntry>> getExpenses(
    String token, {
    int? categoryId,
    int? accountId,
    String? from,
    String? to,
  }) async {
    if (await _shouldLoadFromBackend()) {
      final client = _getClient(token);
      return client.listExpenses(
        categoryId: categoryId,
        accountId: accountId,
        from: from,
        to: to,
      );
    }
    return _getLocalExpenses(
      categoryId: categoryId,
      accountId: accountId,
      from: from,
      to: to,
    );
  }

  Future<List<FinanceEntry>> _getLocalExpenses({
    int? categoryId,
    int? accountId,
    String? from,
    String? to,
  }) async {
    List<Expense> expenses = await _db.getAllExpenses();

    if (categoryId != null) {
      expenses = expenses.where((e) => e.categoryId == categoryId).toList();
    }
    if (accountId != null) {
      expenses = expenses.where((e) => e.accountId == accountId).toList();
    }
    if (from != null) {
      final fromDate = DateTime.parse(from);
      expenses = expenses
          .where(
            (e) =>
                e.spentOn.isAfter(fromDate.subtract(const Duration(days: 1))),
          )
          .toList();
    }
    if (to != null) {
      final toDate = DateTime.parse(to);
      expenses = expenses
          .where((e) => e.spentOn.isBefore(toDate.add(const Duration(days: 1))))
          .toList();
    }

    final categories = await _db.getAllCategories();
    final accounts = await _db.getAllAccounts();

    return expenses.map((e) {
      final cat = categories
          .where((c) => c.serverId == e.categoryId)
          .firstOrNull;
      final acc = accounts.where((a) => a.serverId == e.accountId).firstOrNull;
      return FinanceEntry(
        id: e.serverId ?? 0,
        title: e.title,
        amount: e.amount,
        categoryId: e.categoryId,
        categoryName: cat?.name ?? '',
        categoryColor: cat?.color ?? '#0E7490',
        accountId: e.accountId,
        accountName: acc?.name ?? '',
        accountColor: acc?.color ?? '#10B981',
        date: e.spentOn.toIso8601String().split('T')[0],
        notes: e.notes,
      );
    }).toList();
  }

  Future<List<FinanceEntry>> getIncomes(
    String token, {
    int? categoryId,
    int? accountId,
  }) async {
    if (await _shouldLoadFromBackend()) {
      final client = _getClient(token);
      return client.listIncomes(categoryId: categoryId, accountId: accountId);
    }
    return _getLocalIncomes(categoryId: categoryId, accountId: accountId);
  }

  Future<List<FinanceEntry>> _getLocalIncomes({
    int? categoryId,
    int? accountId,
  }) async {
    List<Income> incomes = await _db.getAllIncomes();

    if (categoryId != null) {
      incomes = incomes.where((i) => i.categoryId == categoryId).toList();
    }
    if (accountId != null) {
      incomes = incomes.where((i) => i.accountId == accountId).toList();
    }

    final categories = await _db.getAllCategories();
    final accounts = await _db.getAllAccounts();

    return incomes.map((i) {
      final cat = categories
          .where((c) => c.serverId == i.categoryId)
          .firstOrNull;
      final acc = accounts.where((a) => a.serverId == i.accountId).firstOrNull;
      return FinanceEntry(
        id: i.serverId ?? 0,
        title: i.title,
        amount: i.amount,
        categoryId: i.categoryId,
        categoryName: cat?.name ?? '',
        categoryColor: cat?.color ?? '#0E7490',
        accountId: i.accountId,
        accountName: acc?.name ?? '',
        accountColor: acc?.color ?? '#10B981',
        date: i.receivedOn.toIso8601String().split('T')[0],
        notes: i.notes,
      );
    }).toList();
  }

  Future<List<BudgetItem>> getBudgets(String token) async {
    if (await _shouldLoadFromBackend()) {
      final client = _getClient(token);
      return client.fetchBudgets();
    }
    return _getLocalBudgets();
  }

  Future<List<BudgetItem>> _getLocalBudgets() async {
    final budgets = await _db.getAllBudgets();
    final categories = await _db.getAllCategories();

    return budgets.map((b) {
      final cat = categories
          .where((c) => c.serverId == b.categoryId)
          .firstOrNull;
      return BudgetItem(
        id: b.serverId ?? 0,
        name: b.name,
        amount: b.amount,
        period: b.period,
        startDate: b.startDate.toIso8601String().split('T')[0],
        endDate: b.endDate.toIso8601String().split('T')[0],
        notes: b.notes,
        categoryId: b.categoryId,
        categoryName: cat?.name,
        categoryColor: cat?.color,
        spent: 0,
        remaining: b.amount,
      );
    }).toList();
  }

  Future<void> saveExpense(
    String token, {
    required String title,
    required double amount,
    required int categoryId,
    required int accountId,
    required DateTime spentOn,
    String notes = '',
  }) async {
    final uuid = _uuid.v4();
    await _db.insertExpense(
      ExpensesCompanion.insert(
        uuid: uuid,
        title: title,
        amount: amount,
        categoryId: categoryId,
        categoryUuid: '',
        accountId: accountId,
        accountUuid: '',
        spentOn: spentOn,
        notes: notes,
        syncStatus: SyncStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (await _shouldLoadFromBackend()) {
      final client = _getClient(token);
      await client.createExpense(
        title: title,
        amount: amount,
        categoryId: categoryId,
        accountId: accountId,
        spentOn: spentOn.toIso8601String(),
        notes: notes,
      );
    }
  }

  Future<void> saveIncome(
    String token, {
    required String title,
    required double amount,
    required int categoryId,
    required int accountId,
    required DateTime receivedOn,
    String notes = '',
  }) async {
    final uuid = _uuid.v4();
    await _db.insertIncome(
      IncomesCompanion.insert(
        uuid: uuid,
        title: title,
        amount: amount,
        categoryId: categoryId,
        categoryUuid: '',
        accountId: accountId,
        accountUuid: '',
        receivedOn: receivedOn,
        notes: notes,
        syncStatus: SyncStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (await _shouldLoadFromBackend()) {
      final client = _getClient(token);
      await client.createIncome(
        title: title,
        amount: amount,
        categoryId: categoryId,
        accountId: accountId,
        receivedOn: receivedOn.toIso8601String(),
        notes: notes,
      );
    }
  }

  Future<void> saveCategory(
    String token, {
    required String name,
    required String kind,
    required String color,
    required String icon,
  }) async {
    final uuid = _uuid.v4();
    await _db.insertCategory(
      CategoriesCompanion.insert(
        uuid: uuid,
        name: name,
        kind: kind,
        color: color,
        icon: icon,
        syncStatus: SyncStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (await _shouldLoadFromBackend()) {
      final client = _getClient(token);
      await client.createCategory(
        name: name,
        kind: kind,
        color: color,
        icon: icon,
      );
    }
  }

  Future<void> saveAccount(
    String token, {
    required String name,
    required String type,
    required double initialBalance,
    required String color,
    required String icon,
    String notes = '',
  }) async {
    final uuid = _uuid.v4();
    await _db.insertAccount(
      AccountsCompanion.insert(
        uuid: uuid,
        name: name,
        type: type,
        initialBalance: initialBalance,
        currentBalance: initialBalance,
        color: color,
        icon: icon,
        notes: notes,
        isActive: const Value(true),
        syncStatus: SyncStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (await _shouldLoadFromBackend()) {
      final client = _getClient(token);
      await client.createAccount(
        name: name,
        type: type,
        initialBalance: initialBalance,
        color: color,
        icon: icon,
        notes: notes,
      );
    }
  }

  Future<void> saveBudget(
    String token, {
    required String name,
    required double amount,
    required String period,
    required DateTime startDate,
    int? categoryId,
    String notes = '',
  }) async {
    final uuid = _uuid.v4();
    await _db.insertBudget(
      BudgetsCompanion.insert(
        uuid: uuid,
        name: name,
        amount: amount,
        period: period,
        startDate: startDate,
        endDate: startDate.add(const Duration(days: 30)),
        notes: notes,
        categoryId: Value(categoryId),
        categoryUuid: const Value(null),
        syncStatus: SyncStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (await _shouldLoadFromBackend()) {
      final client = _getClient(token);
      await client.createBudget(
        name: name,
        amount: amount,
        period: period,
        startDate: startDate.toIso8601String(),
        categoryId: categoryId,
        notes: notes,
      );
    }
  }
}
