import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';

import '../api/finance_mcp_client.dart';
import '../database/finance_database.dart';
import '../settings/app_preferences_storage.dart';

const String syncTaskName = 'syncFinanceDataTask';
const String syncTaskTag = 'finance_sync';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    log('WorkManager task started: $task');

    final token = inputData?['token'] as String?;
    if (token == null) {
      log('No token provided, skipping sync');
      return Future.value(false);
    }

    final client = FinanceMcpClient(token: token);
    final db = FinanceDatabase();

    try {
      final hasConnectivity = await _checkConnectivity();
      if (!hasConnectivity) {
        log('No connectivity, skipping sync');
        return Future.value(false);
      }

      await syncPendingDataStatic(client, db);
      log('Sync completed successfully');
      return Future.value(true);
    } catch (e) {
      log('Sync failed: $e');
      return Future.value(false);
    }
  });
}

Future<bool> _checkConnectivity() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult.any(
    (result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet,
  );
}

Future<void> syncPendingDataStatic(
  FinanceMcpClient client,
  FinanceDatabase db,
) async {
  await _syncCategoriesStatic(client, db);
  await _syncAccountsStatic(client, db);
  await _syncExpensesStatic(client, db);
  await _syncIncomesStatic(client, db);
  await _syncBudgetsStatic(client, db);
  await _syncTransfersStatic(client, db);
  await _downloadFromServerStatic(client, db);
}

Future<void> _syncCategoriesStatic(
  FinanceMcpClient client,
  FinanceDatabase db,
) async {
  final pending = await db.getPendingCategories();
  for (final category in pending) {
    try {
      if (category.serverId == null) {
        await client.createCategory(
          name: category.name,
          kind: category.kind,
          color: category.color,
          icon: category.icon,
        );
      } else {
        await client.updateCategory(
          id: category.serverId!,
          name: category.name,
          kind: category.kind,
          color: category.color,
          icon: category.icon,
        );
      }
      await _updateCategorySyncStatus(db, category.uuid, SyncStatus.synced);
    } catch (e) {
      log('Failed to sync category ${category.uuid}: $e');
      await _updateCategorySyncStatus(db, category.uuid, SyncStatus.failed);
    }
  }
}

Future<void> _updateCategorySyncStatus(
  FinanceDatabase db,
  String uuid,
  SyncStatus status,
) async {
  final category = await (db.select(
    db.categories,
  )..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
  if (category != null) {
    await db.updateCategory(
      CategoriesCompanion(
        uuid: Value(category.uuid),
        serverId: Value(category.serverId),
        name: Value(category.name),
        kind: Value(category.kind),
        color: Value(category.color),
        icon: Value(category.icon),
        syncStatus: Value(status),
        createdAt: Value(category.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

Future<void> _syncAccountsStatic(
  FinanceMcpClient client,
  FinanceDatabase db,
) async {
  final pending = await db.getPendingAccounts();
  for (final account in pending) {
    try {
      if (account.serverId == null) {
        await client.createAccount(
          name: account.name,
          type: account.type,
          initialBalance: account.initialBalance,
          color: account.color,
          icon: account.icon,
          notes: account.notes,
        );
      } else {
        await client.updateAccount(
          id: account.serverId!,
          name: account.name,
          type: account.type,
          color: account.color,
          icon: account.icon,
          notes: account.notes,
        );
      }
      await _updateAccountSyncStatus(db, account.uuid, SyncStatus.synced);
    } catch (e) {
      log('Failed to sync account ${account.uuid}: $e');
      await _updateAccountSyncStatus(db, account.uuid, SyncStatus.failed);
    }
  }
}

Future<void> _updateAccountSyncStatus(
  FinanceDatabase db,
  String uuid,
  SyncStatus status,
) async {
  final account = await (db.select(
    db.accounts,
  )..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
  if (account != null) {
    await db.updateAccount(
      AccountsCompanion(
        uuid: Value(account.uuid),
        serverId: Value(account.serverId),
        name: Value(account.name),
        type: Value(account.type),
        initialBalance: Value(account.initialBalance),
        currentBalance: Value(account.currentBalance),
        color: Value(account.color),
        icon: Value(account.icon),
        notes: Value(account.notes),
        isActive: Value(account.isActive),
        syncStatus: Value(status),
        createdAt: Value(account.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

Future<void> _syncExpensesStatic(
  FinanceMcpClient client,
  FinanceDatabase db,
) async {
  final pending = await db.getPendingExpenses();
  for (final expense in pending) {
    try {
      if (expense.serverId == null) {
        await client.createExpense(
          title: expense.title,
          amount: expense.amount,
          categoryId: expense.categoryId,
          accountId: expense.accountId,
          spentOn: expense.spentOn.toIso8601String(),
          notes: expense.notes,
        );
      } else {
        await client.updateExpense(
          id: expense.serverId!,
          title: expense.title,
          amount: expense.amount,
          categoryId: expense.categoryId,
          accountId: expense.accountId,
          spentOn: expense.spentOn.toIso8601String(),
          notes: expense.notes,
        );
      }
      await _updateExpenseSyncStatus(db, expense.uuid, SyncStatus.synced);
    } catch (e) {
      log('Failed to sync expense ${expense.uuid}: $e');
      await _updateExpenseSyncStatus(db, expense.uuid, SyncStatus.failed);
    }
  }
}

Future<void> _updateExpenseSyncStatus(
  FinanceDatabase db,
  String uuid,
  SyncStatus status,
) async {
  final expense = await (db.select(
    db.expenses,
  )..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
  if (expense != null) {
    await db.updateExpense(
      ExpensesCompanion(
        uuid: Value(expense.uuid),
        serverId: Value(expense.serverId),
        title: Value(expense.title),
        amount: Value(expense.amount),
        categoryId: Value(expense.categoryId),
        categoryUuid: Value(expense.categoryUuid),
        accountId: Value(expense.accountId),
        accountUuid: Value(expense.accountUuid),
        spentOn: Value(expense.spentOn),
        notes: Value(expense.notes),
        syncStatus: Value(status),
        createdAt: Value(expense.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

Future<void> _syncIncomesStatic(
  FinanceMcpClient client,
  FinanceDatabase db,
) async {
  final pending = await db.getPendingIncomes();
  for (final income in pending) {
    try {
      if (income.serverId == null) {
        await client.createIncome(
          title: income.title,
          amount: income.amount,
          categoryId: income.categoryId,
          accountId: income.accountId,
          receivedOn: income.receivedOn.toIso8601String(),
          notes: income.notes,
        );
      } else {
        await client.updateIncome(
          id: income.serverId!,
          title: income.title,
          amount: income.amount,
          categoryId: income.categoryId,
          accountId: income.accountId,
          receivedOn: income.receivedOn.toIso8601String(),
          notes: income.notes,
        );
      }
      await _updateIncomeSyncStatus(db, income.uuid, SyncStatus.synced);
    } catch (e) {
      log('Failed to sync income ${income.uuid}: $e');
      await _updateIncomeSyncStatus(db, income.uuid, SyncStatus.failed);
    }
  }
}

Future<void> _updateIncomeSyncStatus(
  FinanceDatabase db,
  String uuid,
  SyncStatus status,
) async {
  final income = await (db.select(
    db.incomes,
  )..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
  if (income != null) {
    await db.updateIncome(
      IncomesCompanion(
        uuid: Value(income.uuid),
        serverId: Value(income.serverId),
        title: Value(income.title),
        amount: Value(income.amount),
        categoryId: Value(income.categoryId),
        categoryUuid: Value(income.categoryUuid),
        accountId: Value(income.accountId),
        accountUuid: Value(income.accountUuid),
        receivedOn: Value(income.receivedOn),
        notes: Value(income.notes),
        syncStatus: Value(status),
        createdAt: Value(income.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

Future<void> _syncBudgetsStatic(
  FinanceMcpClient client,
  FinanceDatabase db,
) async {
  final pending = await db.getPendingBudgets();
  for (final budget in pending) {
    try {
      if (budget.serverId == null) {
        await client.createBudget(
          name: budget.name,
          amount: budget.amount,
          period: budget.period,
          startDate: budget.startDate.toIso8601String(),
          categoryId: budget.categoryId,
          notes: budget.notes,
        );
      } else {
        await client.updateBudget(
          id: budget.serverId!,
          name: budget.name,
          amount: budget.amount,
          period: budget.period,
          startDate: budget.startDate.toIso8601String(),
          categoryId: budget.categoryId,
          notes: budget.notes,
        );
      }
      await _updateBudgetSyncStatus(db, budget.uuid, SyncStatus.synced);
    } catch (e) {
      log('Failed to sync budget ${budget.uuid}: $e');
      await _updateBudgetSyncStatus(db, budget.uuid, SyncStatus.failed);
    }
  }
}

Future<void> _updateBudgetSyncStatus(
  FinanceDatabase db,
  String uuid,
  SyncStatus status,
) async {
  final budget = await (db.select(
    db.budgets,
  )..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
  if (budget != null) {
    await db.updateBudget(
      BudgetsCompanion(
        uuid: Value(budget.uuid),
        serverId: Value(budget.serverId),
        name: Value(budget.name),
        amount: Value(budget.amount),
        period: Value(budget.period),
        startDate: Value(budget.startDate),
        endDate: Value(budget.endDate),
        notes: Value(budget.notes),
        categoryId: Value(budget.categoryId),
        categoryUuid: Value(budget.categoryUuid),
        syncStatus: Value(status),
        createdAt: Value(budget.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

Future<void> _syncTransfersStatic(
  FinanceMcpClient client,
  FinanceDatabase db,
) async {
  final pending = await db.getPendingTransfers();
  for (final transfer in pending) {
    try {
      if (transfer.serverId == null) {
        await client.transferBetweenAccounts(
          fromAccountId: transfer.fromAccountId,
          toAccountId: transfer.toAccountId,
          amount: transfer.amount,
          notes: transfer.notes,
        );
        final serverId = DateTime.now().millisecondsSinceEpoch;
        await _updateTransferSyncStatus(
          db,
          transfer.uuid,
          SyncStatus.synced,
          serverId,
        );
      }
    } catch (e) {
      log('Failed to sync transfer ${transfer.uuid}: $e');
      await _updateTransferSyncStatus(
        db,
        transfer.uuid,
        SyncStatus.failed,
        null,
      );
    }
  }
}

Future<void> _updateTransferSyncStatus(
  FinanceDatabase db,
  String uuid,
  SyncStatus status,
  int? serverId,
) async {
  final transfer = await (db.select(
    db.transfers,
  )..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
  if (transfer != null) {
    await db.updateTransfer(
      TransfersCompanion(
        uuid: Value(transfer.uuid),
        serverId: Value(serverId ?? transfer.serverId),
        fromAccountId: Value(transfer.fromAccountId),
        fromAccountUuid: Value(transfer.fromAccountUuid),
        toAccountId: Value(transfer.toAccountId),
        toAccountUuid: Value(transfer.toAccountUuid),
        amount: Value(transfer.amount),
        notes: Value(transfer.notes),
        syncStatus: Value(status),
        createdAt: Value(transfer.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

Future<void> _downloadFromServerStatic(
  FinanceMcpClient client,
  FinanceDatabase db,
) async {
  try {
    final dashboard = await client.fetchDashboard(_currentMonthStatic());
    await _storeCategoriesStatic(dashboard.categories, db);
    await _storeAccountsStatic(dashboard.accounts, db);
    await _storeExpensesStatic(dashboard.recentExpenses, db);
    await _storeIncomesStatic(dashboard.recentIncomes, db);
    await _storeBudgetsStatic(dashboard.budgets, db);
  } catch (e) {
    log('Failed to download from server: $e');
  }
}

String _currentMonthStatic() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  return '${now.year}-$month';
}

Future<void> _storeCategoriesStatic(
  List<dynamic> categories,
  FinanceDatabase db,
) async {
  for (final cat in categories) {
    final existing = await (db.select(
      db.categories,
    )..where((t) => t.serverId.equals(cat['id'] as int))).getSingleOrNull();

    if (existing == null) {
      final uuid = const Uuid().v4();
      await db.insertCategory(
        CategoriesCompanion.insert(
          uuid: uuid,
          serverId: Value(cat['id'] as int),
          name: cat['name'] as String,
          kind: cat['kind'] as String,
          color: cat['color'] as String,
          icon: cat['icon'] as String,
          syncStatus: SyncStatus.synced,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
  }
}

Future<void> _storeAccountsStatic(
  List<dynamic> accounts,
  FinanceDatabase db,
) async {
  for (final acc in accounts) {
    final existing = await (db.select(
      db.accounts,
    )..where((t) => t.serverId.equals(acc['id'] as int))).getSingleOrNull();

    if (existing == null) {
      final uuid = const Uuid().v4();
      await db.insertAccount(
        AccountsCompanion.insert(
          uuid: uuid,
          serverId: Value(acc['id'] as int),
          name: acc['name'] as String,
          type: acc['type'] as String,
          initialBalance: (acc['initialBalance'] as num).toDouble(),
          currentBalance: (acc['currentBalance'] as num).toDouble(),
          color: acc['color'] as String,
          icon: acc['icon'] as String,
          notes: acc['notes'] as String? ?? '',
          isActive: Value(acc['isActive'] as bool? ?? true),
          syncStatus: SyncStatus.synced,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
  }
}

Future<void> _storeExpensesStatic(
  List<dynamic> expenses,
  FinanceDatabase db,
) async {
  for (final exp in expenses) {
    final existing = await (db.select(
      db.expenses,
    )..where((t) => t.serverId.equals(exp['id'] as int))).getSingleOrNull();

    if (existing == null) {
      final uuid = const Uuid().v4();
      await db.insertExpense(
        ExpensesCompanion.insert(
          uuid: uuid,
          serverId: Value(exp['id'] as int),
          title: exp['title'] as String,
          amount: (exp['amount'] as num).toDouble(),
          categoryId: exp['categoryId'] as int,
          categoryUuid: '',
          accountId: exp['accountId'] as int? ?? 1,
          accountUuid: '',
          spentOn: DateTime.parse(exp['spentOn'] as String),
          notes: exp['notes'] as String? ?? '',
          syncStatus: SyncStatus.synced,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
  }
}

Future<void> _storeIncomesStatic(
  List<dynamic> incomes,
  FinanceDatabase db,
) async {
  for (final inc in incomes) {
    final existing = await (db.select(
      db.incomes,
    )..where((t) => t.serverId.equals(inc['id'] as int))).getSingleOrNull();

    if (existing == null) {
      final uuid = const Uuid().v4();
      await db.insertIncome(
        IncomesCompanion.insert(
          uuid: uuid,
          serverId: Value(inc['id'] as int),
          title: inc['title'] as String,
          amount: (inc['amount'] as num).toDouble(),
          categoryId: inc['categoryId'] as int,
          categoryUuid: '',
          accountId: inc['accountId'] as int? ?? 1,
          accountUuid: '',
          receivedOn: DateTime.parse(inc['receivedOn'] as String),
          notes: inc['notes'] as String? ?? '',
          syncStatus: SyncStatus.synced,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
  }
}

Future<void> _storeBudgetsStatic(
  List<dynamic> budgets,
  FinanceDatabase db,
) async {
  for (final bud in budgets) {
    final existing = await (db.select(
      db.budgets,
    )..where((t) => t.serverId.equals(bud['id'] as int))).getSingleOrNull();

    if (existing == null) {
      final uuid = const Uuid().v4();
      await db.insertBudget(
        BudgetsCompanion.insert(
          uuid: uuid,
          serverId: Value(bud['id'] as int),
          name: bud['name'] as String,
          amount: (bud['amount'] as num).toDouble(),
          period: bud['period'] as String,
          startDate: DateTime.parse(bud['startDate'] as String),
          endDate: DateTime.parse(bud['endDate'] as String),
          notes: bud['notes'] as String? ?? '',
          categoryId: Value(bud['categoryId'] as int?),
          categoryUuid: const Value(null),
          syncStatus: SyncStatus.synced,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
  }
}

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _uuid = const Uuid();
  final _db = FinanceDatabase();
  final _storage = AppPreferencesStorage();

  static const _syncIntervalMinutes = 15;

  Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    log('SyncService initialized');
  }

  Future<void> scheduleSync(String token) async {
    await Workmanager().registerPeriodicTask(
      syncTaskName,
      syncTaskName,
      frequency: Duration(minutes: _syncIntervalMinutes),
      inputData: {'token': token},
      constraints: Constraints(networkType: NetworkType.connected),
    );
    log('Scheduled periodic sync every $_syncIntervalMinutes minutes');
  }

  Future<void> cancelSync() async {
    await Workmanager().cancelByUniqueName(syncTaskName);
    log('Cancelled periodic sync');
  }

  Future<void> syncNow(String token) async {
    final hasConnectivity = await _checkConnectivityNow();
    if (!hasConnectivity) {
      log('No connectivity for immediate sync');
      return;
    }

    final client = FinanceMcpClient(token: token);
    await syncPendingDataStatic(client, _db);
  }

  Future<bool> _checkConnectivityNow() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet,
    );
  }

  Future<void> saveCategory({
    required String name,
    required String kind,
    required String color,
    required String icon,
    int? serverId,
  }) async {
    final uuid = _uuid.v4();
    await _db.insertCategory(
      CategoriesCompanion.insert(
        uuid: uuid,
        serverId: Value(serverId),
        name: name,
        kind: kind,
        color: color,
        icon: icon,
        syncStatus: serverId != null ? SyncStatus.synced : SyncStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> saveAccount({
    required String name,
    required String type,
    required double initialBalance,
    required String color,
    required String icon,
    String notes = '',
    int? serverId,
  }) async {
    final uuid = _uuid.v4();
    await _db.insertAccount(
      AccountsCompanion.insert(
        uuid: uuid,
        serverId: Value(serverId),
        name: name,
        type: type,
        initialBalance: initialBalance,
        currentBalance: initialBalance,
        color: color,
        icon: icon,
        notes: notes,
        isActive: const Value(true),
        syncStatus: serverId != null ? SyncStatus.synced : SyncStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> saveExpense({
    required String title,
    required double amount,
    required int categoryId,
    required String categoryUuid,
    required int accountId,
    required String accountUuid,
    required DateTime spentOn,
    String notes = '',
    int? serverId,
  }) async {
    final uuid = _uuid.v4();
    await _db.insertExpense(
      ExpensesCompanion.insert(
        uuid: uuid,
        serverId: Value(serverId),
        title: title,
        amount: amount,
        categoryId: categoryId,
        categoryUuid: categoryUuid,
        accountId: accountId,
        accountUuid: accountUuid,
        spentOn: spentOn,
        notes: notes,
        syncStatus: serverId != null ? SyncStatus.synced : SyncStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> saveIncome({
    required String title,
    required double amount,
    required int categoryId,
    required String categoryUuid,
    required int accountId,
    required String accountUuid,
    required DateTime receivedOn,
    String notes = '',
    int? serverId,
  }) async {
    final uuid = _uuid.v4();
    await _db.insertIncome(
      IncomesCompanion.insert(
        uuid: uuid,
        serverId: Value(serverId),
        title: title,
        amount: amount,
        categoryId: categoryId,
        categoryUuid: categoryUuid,
        accountId: accountId,
        accountUuid: accountUuid,
        receivedOn: receivedOn,
        notes: notes,
        syncStatus: serverId != null ? SyncStatus.synced : SyncStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> saveBudget({
    required String name,
    required double amount,
    required String period,
    required DateTime startDate,
    DateTime? endDate,
    int? categoryId,
    String? categoryUuid,
    String notes = '',
    int? serverId,
  }) async {
    final uuid = _uuid.v4();
    await _db.insertBudget(
      BudgetsCompanion.insert(
        uuid: uuid,
        serverId: Value(serverId),
        name: name,
        amount: amount,
        period: period,
        startDate: startDate,
        endDate: endDate ?? startDate.add(const Duration(days: 30)),
        notes: notes,
        categoryId: Value(categoryId),
        categoryUuid: Value(categoryUuid),
        syncStatus: serverId != null ? SyncStatus.synced : SyncStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> saveTransfer({
    required int fromAccountId,
    required String fromAccountUuid,
    required int toAccountId,
    required String toAccountUuid,
    required double amount,
    String notes = '',
    int? serverId,
  }) async {
    final uuid = _uuid.v4();
    await _db.insertTransfer(
      TransfersCompanion.insert(
        uuid: uuid,
        serverId: Value(serverId),
        fromAccountId: fromAccountId,
        fromAccountUuid: fromAccountUuid,
        toAccountId: toAccountId,
        toAccountUuid: toAccountUuid,
        amount: amount,
        notes: notes,
        syncStatus: serverId != null ? SyncStatus.synced : SyncStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }
}
