import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../api/finance_rest_api.dart';
import '../database/finance_database.dart';
import '../models/finance_models.dart';
import 'finance_local_dashboard.dart';
import 'finance_mappers.dart';

/// Local-first finance data with REST sync.
class FinanceRepository {
  FinanceRepository({
    required FinanceDatabase database,
    required String token,
  }) : _db = database,
       _token = token;

  final FinanceDatabase _db;
  final String _token;

  static const _uuid = Uuid();

  FinanceRestApi get _api => FinanceRestApi(token: _token);

  Future<FinanceDashboard> fetchDashboard(String monthYyyyMm) async {
    final categories = await _db.select(_db.localCategories).get();
    final accounts = await _db.select(_db.localAccounts).get();
    final expenses = await _db.select(_db.localExpenses).get();
    final incomes = await _db.select(_db.localIncomes).get();
    final budgets = await _db.select(_db.localBudgets).get();
    return FinanceLocalDashboard.build(
      monthYyyyMm: monthYyyyMm,
      categories: categories,
      accounts: accounts,
      expenses: expenses,
      incomes: incomes,
      budgets: budgets,
    );
  }

  Future<List<FinanceAccount>> listAccountsLocal() async {
    final rows = await _db.select(_db.localAccounts).get();
    return rows.map(_accountRowToModel).toList();
  }

  Future<List<FinanceCategory>> listCategoriesLocal() async {
    final rows = await _db.select(_db.localCategories).get();
    return rows.map(_categoryRowToModel).toList();
  }

  Future<List<Transfer>> listTransfersLocal() async {
    final rows = await _db.select(_db.localTransfers).get();
    return rows.map(_transferRowToModel).toList();
  }

  Future<List<FinanceEntry>> listExpensesLocal({
    int? categoryServerId,
    String? categoryUuid,
    String? fromIsoDate,
    String? toIsoDate,
    String? spentOnEquals,
  }) async {
    var rows = await _db.select(_db.localExpenses).get();
    if (spentOnEquals != null && spentOnEquals.isNotEmpty) {
      rows = rows.where((e) => e.spentOn == spentOnEquals).toList();
    }
    if (categoryUuid != null && categoryUuid.isNotEmpty) {
      rows = rows.where((e) => e.categoryUuid == categoryUuid).toList();
    } else if (categoryServerId != null) {
      final cat = await (_db.select(_db.localCategories)
            ..where((t) => t.serverId.equals(categoryServerId)))
          .getSingleOrNull();
      if (cat != null) {
        rows = rows.where((e) => e.categoryUuid == cat.uuid).toList();
      }
    }
    if (fromIsoDate != null && toIsoDate != null) {
      final from = _isoToDdMmYyyy(fromIsoDate);
      final to = _isoToDdMmYyyy(toIsoDate);
      rows = rows
          .where((e) {
            final d = _parseDdMmYyyy(e.spentOn);
            final a = _parseDdMmYyyy(from);
            final b = _parseDdMmYyyy(to);
            if (d == null || a == null || b == null) {
              return false;
            }
            return !d.isBefore(a) && !d.isAfter(b);
          })
          .toList();
    }
    rows.sort((a, b) => _cmpDateDesc(a.spentOn, b.spentOn));
    return rows.map(_expenseRowToModel).toList();
  }

  Future<List<FinanceEntry>> listIncomesLocal({
    int? categoryServerId,
    String? categoryUuid,
  }) async {
    var rows = await _db.select(_db.localIncomes).get();
    if (categoryUuid != null && categoryUuid.isNotEmpty) {
      rows = rows.where((e) => e.categoryUuid == categoryUuid).toList();
    } else if (categoryServerId != null) {
      final cat = await (_db.select(_db.localCategories)
            ..where((t) => t.serverId.equals(categoryServerId)))
          .getSingleOrNull();
      if (cat != null) {
        rows = rows.where((e) => e.categoryUuid == cat.uuid).toList();
      }
    }
    rows.sort((a, b) => _cmpDateDesc(a.receivedOn, b.receivedOn));
    return rows.map(_incomeRowToModel).toList();
  }

  Future<List<BudgetItem>> listBudgetsLocal() async {
    final rows = await _db.select(_db.localBudgets).get();
    return rows
        .map(
          (b) => BudgetItem(
            id: b.serverId ?? 0,
            uuid: b.uuid,
            name: b.name,
            amount: b.amount,
            period: b.period,
            startDate: b.startDate,
            endDate: b.endDate,
            notes: b.notes,
            categoryId: null,
            categoryUuid: b.categoryUuid,
            categoryName: b.categoryName,
            categoryColor: b.categoryColor,
            spent: b.spent,
            remaining: b.remaining,
          ),
        )
        .toList();
  }

  Future<List<DailyExpense>> fetchDailyExpenses({int days = 7}) async {
    final expenses = await _db.select(_db.localExpenses).get();
    return _aggregateDaily(expenses, days);
  }

  Future<List<WeeklyExpense>> fetchWeeklyExpenses({int weeks = 4}) async {
    final expenses = await _db.select(_db.localExpenses).get();
    return _aggregateWeekly(expenses, weeks);
  }

  Future<List<MonthlyExpense>> fetchMonthlyExpenses({int months = 6}) async {
    final expenses = await _db.select(_db.localExpenses).get();
    return _aggregateMonthly(expenses, months);
  }

  FinanceAccount _accountRowToModel(LocalAccountRow a) {
    return FinanceAccount(
      id: a.serverId ?? 0,
      uuid: a.uuid,
      name: a.name,
      type: a.type,
      initialBalance: a.initialBalance,
      currentBalance: a.currentBalance,
      color: a.color,
      icon: a.icon,
      notes: a.notes,
      isActive: a.isActive,
    );
  }

  FinanceCategory _categoryRowToModel(LocalCategoryRow c) {
    return FinanceCategory(
      id: c.serverId ?? 0,
      uuid: c.uuid,
      name: c.name,
      kind: c.kind,
      color: c.color,
      icon: c.icon,
    );
  }

  FinanceEntry _expenseRowToModel(LocalExpenseRow e) {
    return FinanceEntry(
      id: e.serverId ?? 0,
      uuid: e.uuid,
      title: e.title,
      amount: e.amount,
      categoryId: 0,
      categoryUuid: e.categoryUuid,
      categoryName: e.categoryName,
      categoryColor: e.categoryColor,
      accountId: 0,
      accountUuid: e.accountUuid,
      accountName: e.accountName,
      accountColor: e.accountColor,
      date: e.spentOn,
      notes: e.notes,
    );
  }

  FinanceEntry _incomeRowToModel(LocalIncomeRow e) {
    return FinanceEntry(
      id: e.serverId ?? 0,
      uuid: e.uuid,
      title: e.title,
      amount: e.amount,
      categoryId: 0,
      categoryUuid: e.categoryUuid,
      categoryName: e.categoryName,
      categoryColor: e.categoryColor,
      accountId: 0,
      accountUuid: e.accountUuid,
      accountName: e.accountName,
      accountColor: e.accountColor,
      date: e.receivedOn,
      notes: e.notes,
    );
  }

  Transfer _transferRowToModel(LocalTransferRow t) {
    return Transfer(
      id: t.serverId ?? 0,
      uuid: t.uuid,
      fromAccountId: 0,
      fromAccountUuid: t.fromAccountUuid,
      fromAccountName: t.fromAccountName,
      toAccountId: 0,
      toAccountUuid: t.toAccountUuid,
      toAccountName: t.toAccountName,
      amount: t.amount,
      notes: t.notes,
      createdAt: t.createdAt ?? '',
    );
  }

  int _cmpDateDesc(String a, String b) {
    final da = _parseDdMmYyyy(a);
    final db = _parseDdMmYyyy(b);
    if (da == null && db == null) {
      return 0;
    }
    if (da == null) {
      return 1;
    }
    if (db == null) {
      return -1;
    }
    return db.compareTo(da);
  }

  String _isoToDdMmYyyy(String iso) {
    final p = iso.split('-');
    if (p.length != 3) {
      return iso;
    }
    return '${p[2]}-${p[1]}-${p[0]}';
  }

  List<DailyExpense> _aggregateDaily(List<LocalExpenseRow> expenses, int days) {
    final now = DateTime.now();
    final result = <DailyExpense>[];
    for (var i = days - 1; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final dayStr =
          '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
      final label =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      double total = 0;
      var count = 0;
      for (final e in expenses) {
        if (e.spentOn == dayStr) {
          total += e.amount;
          count++;
        }
      }
      final names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      result.add(
        DailyExpense(
          date: label,
          dayName: names[d.weekday - 1],
          dayNumber: d.day.toString().padLeft(2, '0'),
          total: total,
          count: count,
        ),
      );
    }
    return result;
  }

  List<WeeklyExpense> _aggregateWeekly(List<LocalExpenseRow> expenses, int weeks) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final result = <WeeklyExpense>[];
    for (var w = weeks - 1; w >= 0; w--) {
      final weekStart = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      ).subtract(Duration(days: 7 * w));
      final weekEnd = weekStart.add(const Duration(days: 6));
      double total = 0;
      var count = 0;
      for (final e in expenses) {
        final p = _parseDdMmYyyy(e.spentOn);
        if (p != null &&
            !p.isBefore(weekStart) &&
            !p.isAfter(weekEnd)) {
          total += e.amount;
          count++;
        }
      }
      final ws =
          '${weekStart.day.toString().padLeft(2, '0')}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.year}';
      final range =
          '${weekStart.day}/${weekStart.month} – ${weekEnd.day}/${weekEnd.month}';
      result.add(
        WeeklyExpense(
          weekStart: ws,
          dateRange: range,
          year: '${weekStart.year}',
          total: total,
          count: count,
        ),
      );
    }
    return result;
  }

  List<MonthlyExpense> _aggregateMonthly(List<LocalExpenseRow> expenses, int months) {
    final now = DateTime.now();
    final result = <MonthlyExpense>[];
    for (var m = months - 1; m >= 0; m--) {
      final monthDate = DateTime(now.year, now.month - m, 1);
      final monthKey =
          '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}';
      final names = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      double total = 0;
      var count = 0;
      for (final e in expenses) {
        final p = _parseDdMmYyyy(e.spentOn);
        if (p != null) {
          final mk =
              '${p.year}-${p.month.toString().padLeft(2, '0')}';
          if (mk == monthKey) {
            total += e.amount;
            count++;
          }
        }
      }
      result.add(
        MonthlyExpense(
          monthStart:
              '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}-01',
          monthName: names[monthDate.month],
          year: '${monthDate.year}',
          total: total,
          count: count,
        ),
      );
    }
    return result;
  }

  DateTime? _parseDdMmYyyy(String s) {
    final p = s.split('-');
    if (p.length != 3) {
      return null;
    }
    final d = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    final y = int.tryParse(p[2]);
    if (d == null || m == null || y == null) {
      return null;
    }
    return DateTime(y, m, d);
  }

  Future<void> recomputeAccountBalances() async {
    final accounts = await _db.select(_db.localAccounts).get();
    final expenses = await _db.select(_db.localExpenses).get();
    final incomes = await _db.select(_db.localIncomes).get();
    for (final a in accounts) {
      final inc = incomes
          .where((i) => i.accountUuid == a.uuid)
          .fold<double>(0, (s, i) => s + i.amount);
      final exp = expenses
          .where((e) => e.accountUuid == a.uuid)
          .fold<double>(0, (s, e) => s + e.amount);
      final bal = a.initialBalance + inc - exp;
      await (_db.update(_db.localAccounts)..where((t) => t.uuid.equals(a.uuid)))
          .write(LocalAccountsCompanion(currentBalance: Value(bal)));
    }
  }

  Future<void> importAllFromServer() async {
    final api = _api;
    final accountsJson = await api.getAccounts();
    final categoriesJson = await api.getCategories();
    final expensesJson = await api.getExpenses();
    final incomesJson = await api.getIncomes();
    final transfersJson = await api.getTransfers();
    final budgetsJson = await api.getBudgets();

    final accountIdToUuid = <int, String>{};
    for (final j in accountsJson) {
      final id = j['id'] as int?;
      final u = j['uuid']?.toString();
      if (id != null && u != null && u.isNotEmpty) {
        accountIdToUuid[id] = u;
      }
    }

    final categoryIdToUuid = <int, String>{};
    for (final j in categoriesJson) {
      final id = j['id'] as int?;
      final u = j['uuid']?.toString();
      if (id != null && u != null && u.isNotEmpty) {
        categoryIdToUuid[id] = u;
      }
    }

    await _db.batch((b) {
      for (final j in accountsJson) {
        b.insert(
          _db.localAccounts,
          accountFromServerJson(j),
          mode: InsertMode.insertOrReplace,
        );
      }
      for (final j in categoriesJson) {
        b.insert(
          _db.localCategories,
          categoryFromServerJson(j),
          mode: InsertMode.insertOrReplace,
        );
      }
    });

    await _db.batch((b) {
      for (final j in expensesJson) {
        final cid = j['categoryId'] as int?;
        final aid = j['accountId'] as int?;
        final cu = cid != null ? categoryIdToUuid[cid] : null;
        final au = aid != null ? accountIdToUuid[aid] : null;
        if (cu == null || au == null) {
          continue;
        }
        b.insert(
          _db.localExpenses,
          expenseFromServerJson(j, categoryUuid: cu, accountUuid: au),
          mode: InsertMode.insertOrReplace,
        );
      }
      for (final j in incomesJson) {
        final cid = j['categoryId'] as int?;
        final aid = j['accountId'] as int?;
        final cu = cid != null ? categoryIdToUuid[cid] : null;
        final au = aid != null ? accountIdToUuid[aid] : null;
        if (cu == null || au == null) {
          continue;
        }
        b.insert(
          _db.localIncomes,
          incomeFromServerJson(j, categoryUuid: cu, accountUuid: au),
          mode: InsertMode.insertOrReplace,
        );
      }
    });

    await _db.batch((b) {
      for (final j in transfersJson) {
        final fid = j['fromAccountId'] as int?;
        final tid = j['toAccountId'] as int?;
        final fu = fid != null ? accountIdToUuid[fid] : null;
        final tu = tid != null ? accountIdToUuid[tid] : null;
        if (fu == null || tu == null) {
          continue;
        }
        b.insert(
          _db.localTransfers,
          transferFromServerJson(j, fromAccountUuid: fu, toAccountUuid: tu),
          mode: InsertMode.insertOrReplace,
        );
      }
      for (final j in budgetsJson) {
        final cid = j['categoryId'] as int?;
        final String? cu = cid != null ? categoryIdToUuid[cid] : null;
        b.insert(
          _db.localBudgets,
          budgetFromServerJson(j, categoryUuid: cu),
          mode: InsertMode.insertOrReplace,
        );
      }
    });

    await recomputeAccountBalances();
  }

  Future<void> pushUnsynced() async {
    final api = _api;

    final unsyncedAccounts = await (_db.select(_db.localAccounts)
          ..where((t) => t.isSynced.equals(false)))
        .get();
    for (final row in unsyncedAccounts) {
      if (row.serverId != null) {
        continue;
      }
      try {
        final res = await api.postAccount({
          'name': row.name,
          'type': row.type,
          'initialBalance': row.initialBalance,
          'color': row.color,
          'icon': row.icon,
          'notes': row.notes,
          'uuid': row.uuid,
        });
        final sid = res['id'] as int?;
        if (sid != null) {
          await (_db.update(_db.localAccounts)..where((t) => t.uuid.equals(row.uuid)))
              .write(
            LocalAccountsCompanion(
              serverId: Value(sid),
              isSynced: const Value(true),
              currentBalance: Value(
                (res['currentBalance'] as num?)?.toDouble() ?? row.currentBalance,
              ),
            ),
          );
        }
      } catch (_) {}
    }

    final unsyncedCategories = await (_db.select(_db.localCategories)
          ..where((t) => t.isSynced.equals(false)))
        .get();
    for (final row in unsyncedCategories) {
      if (row.serverId != null) {
        continue;
      }
      try {
        final res = await api.postCategory({
          'name': row.name,
          'kind': row.kind,
          'color': row.color,
          'icon': row.icon,
          'uuid': row.uuid,
        });
        final sid = res['id'] as int?;
        if (sid != null) {
          await (_db.update(_db.localCategories)..where((t) => t.uuid.equals(row.uuid)))
              .write(
            LocalCategoriesCompanion(
              serverId: Value(sid),
              isSynced: const Value(true),
            ),
          );
        }
      } catch (_) {}
    }

    final unsyncedExpenses = await (_db.select(_db.localExpenses)
          ..where((t) => t.isSynced.equals(false)))
        .get();
    for (final row in unsyncedExpenses) {
      if (row.serverId != null) {
        continue;
      }
      final cId = await catSid(row.categoryUuid);
      final aId = await accSid(row.accountUuid);
      if (cId == null || aId == null) {
        continue;
      }
      try {
        final res = await api.postExpense({
          'title': row.title,
          'amount': row.amount,
          'categoryId': cId,
          'accountId': aId,
          'spentOn': row.spentOn,
          'notes': row.notes,
          'uuid': row.uuid,
        });
        final sid = res['id'] as int?;
        if (sid != null) {
          await (_db.update(_db.localExpenses)..where((t) => t.uuid.equals(row.uuid)))
              .write(
            LocalExpensesCompanion(
              serverId: Value(sid),
              isSynced: const Value(true),
            ),
          );
        }
      } catch (_) {}
    }

    final unsyncedIncomes = await (_db.select(_db.localIncomes)
          ..where((t) => t.isSynced.equals(false)))
        .get();
    for (final row in unsyncedIncomes) {
      if (row.serverId != null) {
        continue;
      }
      final cId = await catSid(row.categoryUuid);
      final aId = await accSid(row.accountUuid);
      if (cId == null || aId == null) {
        continue;
      }
      try {
        final res = await api.postIncome({
          'title': row.title,
          'amount': row.amount,
          'categoryId': cId,
          'accountId': aId,
          'receivedOn': row.receivedOn,
          'notes': row.notes,
          'uuid': row.uuid,
        });
        final sid = res['id'] as int?;
        if (sid != null) {
          await (_db.update(_db.localIncomes)..where((t) => t.uuid.equals(row.uuid)))
              .write(
            LocalIncomesCompanion(
              serverId: Value(sid),
              isSynced: const Value(true),
            ),
          );
        }
      } catch (_) {}
    }

    final unsyncedTransfers = await (_db.select(_db.localTransfers)
          ..where((t) => t.isSynced.equals(false)))
        .get();
    for (final row in unsyncedTransfers) {
      if (row.serverId != null) {
        continue;
      }
      final fId = await accSid(row.fromAccountUuid);
      final tId = await accSid(row.toAccountUuid);
      if (fId == null || tId == null) {
        continue;
      }
      try {
        final res = await api.postTransfer({
          'fromAccountId': fId,
          'toAccountId': tId,
          'amount': row.amount,
          'notes': row.notes,
          'uuid': row.uuid,
        });
        final sid = res['id'] as int?;
        if (sid != null) {
          await (_db.update(_db.localTransfers)..where((t) => t.uuid.equals(row.uuid)))
              .write(
            LocalTransfersCompanion(
              serverId: Value(sid),
              isSynced: const Value(true),
            ),
          );
        }
      } catch (_) {}
    }

    final unsyncedBudgets = await (_db.select(_db.localBudgets)
          ..where((t) => t.isSynced.equals(false)))
        .get();
    for (final row in unsyncedBudgets) {
      if (row.serverId != null) {
        continue;
      }
      int? catId;
      if (row.categoryUuid != null && row.categoryUuid!.isNotEmpty) {
        catId = await catSid(row.categoryUuid!);
        if (catId == null) {
          continue;
        }
      }
      try {
        final body = <String, dynamic>{
          'name': row.name,
          'amount': row.amount,
          'period': row.period,
          'startDate': row.startDate,
          'notes': row.notes,
          'uuid': row.uuid,
        };
        if (catId != null) {
          body['categoryId'] = catId;
        }
        final res = await api.postBudget(body);
        final sid = res['id'] as int?;
        if (sid != null) {
          await (_db.update(_db.localBudgets)..where((t) => t.uuid.equals(row.uuid)))
              .write(
            LocalBudgetsCompanion(
              serverId: Value(sid),
              isSynced: const Value(true),
            ),
          );
        }
      } catch (_) {}
    }

    await recomputeAccountBalances();
  }

  Future<void> createExpense({
    required String title,
    required double amount,
    required String categoryUuid,
    required String accountUuid,
    required String spentOn,
    String notes = '',
  }) async {
    final cat = await (_db.select(_db.localCategories)
          ..where((t) => t.uuid.equals(categoryUuid)))
        .getSingleOrNull();
    final acc = await (_db.select(_db.localAccounts)
          ..where((t) => t.uuid.equals(accountUuid)))
        .getSingleOrNull();
    final id = _uuid.v4();
    await _db.into(_db.localExpenses).insert(
          LocalExpensesCompanion.insert(
            uuid: id,
            title: title,
            amount: amount,
            categoryUuid: categoryUuid,
            accountUuid: accountUuid,
            categoryName: Value(cat?.name ?? ''),
            categoryColor: Value(cat?.color ?? '#0E7490'),
            accountName: Value(acc?.name ?? ''),
            accountColor: Value(acc?.color ?? '#10B981'),
            spentOn: spentOn,
            notes: Value(notes),
            isSynced: const Value(false),
          ),
        );
    await recomputeAccountBalances();
  }

  Future<void> updateExpense({
    required String uuid,
    required String title,
    required double amount,
    required String categoryUuid,
    required String accountUuid,
    required String spentOn,
    String notes = '',
  }) async {
    final cat = await (_db.select(_db.localCategories)
          ..where((t) => t.uuid.equals(categoryUuid)))
        .getSingleOrNull();
    final acc = await (_db.select(_db.localAccounts)
          ..where((t) => t.uuid.equals(accountUuid)))
        .getSingleOrNull();
    await (_db.update(_db.localExpenses)..where((t) => t.uuid.equals(uuid))).write(
          LocalExpensesCompanion(
            title: Value(title),
            amount: Value(amount),
            categoryUuid: Value(categoryUuid),
            accountUuid: Value(accountUuid),
            categoryName: Value(cat?.name ?? ''),
            categoryColor: Value(cat?.color ?? '#0E7490'),
            accountName: Value(acc?.name ?? ''),
            accountColor: Value(acc?.color ?? '#10B981'),
            spentOn: Value(spentOn),
            notes: Value(notes),
            isSynced: const Value(false),
          ),
        );
    final row = await (_db.select(_db.localExpenses)
          ..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
    if (row?.serverId != null) {
      try {
        final cId = await catSid(categoryUuid);
        final aId = await accSid(accountUuid);
        if (cId != null && aId != null) {
          await _api.putExpense(row!.serverId!, {
            'title': title,
            'amount': amount,
            'categoryId': cId,
            'accountId': aId,
            'spentOn': spentOn,
            'notes': notes,
          });
          await (_db.update(_db.localExpenses)..where((t) => t.uuid.equals(uuid)))
              .write(const LocalExpensesCompanion(isSynced: Value(true)));
        }
      } catch (_) {}
    }
    await recomputeAccountBalances();
  }

  Future<int?> catSid(String u) async {
    final r = await (_db.select(_db.localCategories)..where((t) => t.uuid.equals(u)))
        .getSingleOrNull();
    return r?.serverId;
  }

  Future<int?> accSid(String u) async {
    final r = await (_db.select(_db.localAccounts)..where((t) => t.uuid.equals(u)))
        .getSingleOrNull();
    return r?.serverId;
  }

  Future<void> deleteExpenseByUuid(String uuid) async {
    final row = await (_db.select(_db.localExpenses)..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
    await (_db.delete(_db.localExpenses)..where((t) => t.uuid.equals(uuid))).go();
    if (row?.serverId != null) {
      try {
        await _api.deleteExpense(row!.serverId!);
      } catch (_) {}
    }
    await recomputeAccountBalances();
  }

  Future<void> createIncome({
    required String title,
    required double amount,
    required String categoryUuid,
    required String accountUuid,
    required String receivedOn,
    String notes = '',
  }) async {
    final cat = await (_db.select(_db.localCategories)
          ..where((t) => t.uuid.equals(categoryUuid)))
        .getSingleOrNull();
    final acc = await (_db.select(_db.localAccounts)
          ..where((t) => t.uuid.equals(accountUuid)))
        .getSingleOrNull();
    final id = _uuid.v4();
    await _db.into(_db.localIncomes).insert(
          LocalIncomesCompanion.insert(
            uuid: id,
            title: title,
            amount: amount,
            categoryUuid: categoryUuid,
            accountUuid: accountUuid,
            categoryName: Value(cat?.name ?? ''),
            categoryColor: Value(cat?.color ?? '#0E7490'),
            accountName: Value(acc?.name ?? ''),
            accountColor: Value(acc?.color ?? '#10B981'),
            receivedOn: receivedOn,
            notes: Value(notes),
            isSynced: const Value(false),
          ),
        );
    await recomputeAccountBalances();
  }

  Future<void> updateIncome({
    required String uuid,
    required String title,
    required double amount,
    required String categoryUuid,
    required String accountUuid,
    required String receivedOn,
    String notes = '',
  }) async {
    final cat = await (_db.select(_db.localCategories)
          ..where((t) => t.uuid.equals(categoryUuid)))
        .getSingleOrNull();
    final acc = await (_db.select(_db.localAccounts)
          ..where((t) => t.uuid.equals(accountUuid)))
        .getSingleOrNull();
    await (_db.update(_db.localIncomes)..where((t) => t.uuid.equals(uuid))).write(
          LocalIncomesCompanion(
            title: Value(title),
            amount: Value(amount),
            categoryUuid: Value(categoryUuid),
            accountUuid: Value(accountUuid),
            categoryName: Value(cat?.name ?? ''),
            categoryColor: Value(cat?.color ?? '#0E7490'),
            accountName: Value(acc?.name ?? ''),
            accountColor: Value(acc?.color ?? '#10B981'),
            receivedOn: Value(receivedOn),
            notes: Value(notes),
            isSynced: const Value(false),
          ),
        );
    final row = await (_db.select(_db.localIncomes)..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
    if (row?.serverId != null) {
      try {
        final cId = await catSid(categoryUuid);
        final aId = await accSid(accountUuid);
        if (cId != null && aId != null) {
          await _api.putIncome(row!.serverId!, {
            'title': title,
            'amount': amount,
            'categoryId': cId,
            'accountId': aId,
            'receivedOn': receivedOn,
            'notes': notes,
          });
          await (_db.update(_db.localIncomes)..where((t) => t.uuid.equals(uuid)))
              .write(const LocalIncomesCompanion(isSynced: Value(true)));
        }
      } catch (_) {}
    }
    await recomputeAccountBalances();
  }

  Future<void> deleteIncomeByUuid(String uuid) async {
    final row = await (_db.select(_db.localIncomes)..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
    await (_db.delete(_db.localIncomes)..where((t) => t.uuid.equals(uuid))).go();
    if (row?.serverId != null) {
      try {
        await _api.deleteIncome(row!.serverId!);
      } catch (_) {}
    }
    await recomputeAccountBalances();
  }

  Future<void> createCategory({
    required String name,
    required String kind,
    required String color,
    required String icon,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.localCategories).insert(
          LocalCategoriesCompanion.insert(
            uuid: id,
            name: name,
            kind: kind,
            color: color,
            icon: icon,
            isSynced: const Value(false),
          ),
        );
  }

  Future<void> updateCategory({
    required String uuid,
    required String name,
    required String kind,
    required String color,
    required String icon,
  }) async {
    await (_db.update(_db.localCategories)..where((t) => t.uuid.equals(uuid))).write(
          LocalCategoriesCompanion(
            name: Value(name),
            kind: Value(kind),
            color: Value(color),
            icon: Value(icon),
            isSynced: const Value(false),
          ),
        );
    final row = await (_db.select(_db.localCategories)
          ..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
    if (row?.serverId != null) {
      try {
        await _api.putCategory(row!.serverId!, {
          'name': name,
          'kind': kind,
          'color': color,
          'icon': icon,
        });
        await (_db.update(_db.localCategories)..where((t) => t.uuid.equals(uuid)))
            .write(const LocalCategoriesCompanion(isSynced: Value(true)));
      } catch (_) {}
    }
  }

  Future<void> deleteCategoryByUuid(String uuid) async {
    final row = await (_db.select(_db.localCategories)
          ..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
    await (_db.delete(_db.localCategories)..where((t) => t.uuid.equals(uuid))).go();
    if (row?.serverId != null) {
      try {
        await _api.deleteCategory(row!.serverId!);
      } catch (_) {}
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
    final id = _uuid.v4();
    await _db.into(_db.localAccounts).insert(
          LocalAccountsCompanion.insert(
            uuid: id,
            name: name,
            type: type,
            initialBalance: initialBalance,
            currentBalance: initialBalance,
            color: color,
            icon: icon,
            notes: Value(notes),
            isSynced: const Value(false),
          ),
        );
  }

  Future<void> updateAccount({
    required String uuid,
    String? name,
    String? type,
    String? color,
    String? icon,
    String? notes,
    bool? isActive,
  }) async {
    await (_db.update(_db.localAccounts)..where((t) => t.uuid.equals(uuid))).write(
          LocalAccountsCompanion(
            name: name != null ? Value(name) : const Value.absent(),
            type: type != null ? Value(type) : const Value.absent(),
            color: color != null ? Value(color) : const Value.absent(),
            icon: icon != null ? Value(icon) : const Value.absent(),
            notes: notes != null ? Value(notes) : const Value.absent(),
            isActive: isActive != null ? Value(isActive) : const Value.absent(),
            isSynced: const Value(false),
          ),
        );
    final row = await (_db.select(_db.localAccounts)..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
    if (row?.serverId != null) {
      try {
        final body = <String, dynamic>{};
        if (name != null) {
          body['name'] = name;
        }
        if (type != null) {
          body['type'] = type;
        }
        if (color != null) {
          body['color'] = color;
        }
        if (icon != null) {
          body['icon'] = icon;
        }
        if (notes != null) {
          body['notes'] = notes;
        }
        if (isActive != null) {
          body['isActive'] = isActive;
        }
        if (body.isNotEmpty) {
          await _api.putAccount(row!.serverId!, body);
          await (_db.update(_db.localAccounts)..where((t) => t.uuid.equals(uuid)))
              .write(const LocalAccountsCompanion(isSynced: Value(true)));
        }
      } catch (_) {}
    }
  }

  Future<void> deleteAccountByUuid(String uuid) async {
    final row = await (_db.select(_db.localAccounts)..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
    if (row?.serverId != null) {
      try {
        await _api.deleteAccount(row!.serverId!);
      } catch (_) {}
    }
    await (_db.delete(_db.localAccounts)..where((t) => t.uuid.equals(uuid))).go();
  }

  Future<void> createBudget({
    required String name,
    required double amount,
    required String period,
    required String startDate,
    String? categoryUuid,
    String notes = '',
  }) async {
    final id = _uuid.v4();
    String? cname;
    String? ccolor;
    if (categoryUuid != null && categoryUuid.isNotEmpty) {
      final c = await (_db.select(_db.localCategories)
            ..where((t) => t.uuid.equals(categoryUuid)))
          .getSingleOrNull();
      cname = c?.name;
      ccolor = c?.color;
    }
    await _db.into(_db.localBudgets).insert(
          LocalBudgetsCompanion.insert(
            uuid: id,
            name: name,
            amount: amount,
            period: period,
            startDate: startDate,
            endDate: const Value(''),
            notes: Value(notes),
            categoryUuid: categoryUuid != null
                ? Value(categoryUuid)
                : const Value.absent(),
            categoryName: Value(cname),
            categoryColor: Value(ccolor),
            spent: const Value(0),
            remaining: Value(amount),
            isSynced: const Value(false),
          ),
        );
  }

  Future<void> updateBudget({
    required String uuid,
    required String name,
    required double amount,
    required String period,
    required String startDate,
    String? categoryUuid,
    String notes = '',
  }) async {
    String? cname;
    String? ccolor;
    if (categoryUuid != null && categoryUuid.isNotEmpty) {
      final c = await (_db.select(_db.localCategories)
            ..where((t) => t.uuid.equals(categoryUuid)))
          .getSingleOrNull();
      cname = c?.name;
      ccolor = c?.color;
    }
    await (_db.update(_db.localBudgets)..where((t) => t.uuid.equals(uuid))).write(
          LocalBudgetsCompanion(
            name: Value(name),
            amount: Value(amount),
            period: Value(period),
            startDate: Value(startDate),
            notes: Value(notes),
            categoryUuid: categoryUuid != null
                ? Value(categoryUuid)
                : const Value.absent(),
            categoryName: Value(cname),
            categoryColor: Value(ccolor),
            isSynced: const Value(false),
          ),
        );
    final row = await (_db.select(_db.localBudgets)..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
    if (row?.serverId != null) {
      try {
        final body = <String, dynamic>{
          'name': name,
          'amount': amount,
          'period': period,
          'startDate': startDate,
          'notes': notes,
        };
        if (categoryUuid != null) {
          final cid = await catSid(categoryUuid);
          body['categoryId'] = cid;
        }
        await _api.putBudget(row!.serverId!, body);
        await (_db.update(_db.localBudgets)..where((t) => t.uuid.equals(uuid)))
            .write(const LocalBudgetsCompanion(isSynced: Value(true)));
      } catch (_) {}
    }
  }

  Future<void> deleteBudgetByUuid(String uuid) async {
    final row = await (_db.select(_db.localBudgets)..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
    await (_db.delete(_db.localBudgets)..where((t) => t.uuid.equals(uuid))).go();
    if (row?.serverId != null) {
      try {
        await _api.deleteBudget(row!.serverId!);
      } catch (_) {}
    }
  }

  Future<void> transferBetweenAccounts({
    required String fromAccountUuid,
    required String toAccountUuid,
    required double amount,
    String notes = '',
  }) async {
    final from = await (_db.select(_db.localAccounts)
          ..where((t) => t.uuid.equals(fromAccountUuid)))
        .getSingleOrNull();
    final to = await (_db.select(_db.localAccounts)
          ..where((t) => t.uuid.equals(toAccountUuid)))
        .getSingleOrNull();
    final id = _uuid.v4();
    await _db.into(_db.localTransfers).insert(
          LocalTransfersCompanion.insert(
            uuid: id,
            fromAccountUuid: fromAccountUuid,
            toAccountUuid: toAccountUuid,
            fromAccountName: Value(from?.name ?? ''),
            toAccountName: Value(to?.name ?? ''),
            amount: amount,
            notes: Value(notes),
            isSynced: const Value(false),
          ),
        );
  }
}
