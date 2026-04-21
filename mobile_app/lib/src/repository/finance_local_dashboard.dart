import '../models/finance_models.dart';
import '../utils/app_date_utils.dart';
import '../database/finance_database.dart';

class FinanceLocalDashboard {
  static FinanceDashboard build({
    required String monthYyyyMm,
    required List<LocalCategoryRow> categories,
    required List<LocalAccountRow> accounts,
    required List<LocalExpenseRow> expenses,
    required List<LocalIncomeRow> incomes,
    required List<LocalBudgetRow> budgets,
  }) {
    final monthExpenses = expenses
        .where((e) => _inMonth(e.spentOn, monthYyyyMm))
        .toList();
    final monthIncomes = incomes
        .where((e) => _inMonth(e.receivedOn, monthYyyyMm))
        .toList();

    final expenseTotal = monthExpenses.fold<double>(
      0,
      (s, e) => s + e.amount,
    );
    final incomeTotal = monthIncomes.fold<double>(
      0,
      (s, e) => s + e.amount,
    );

    final byCat = <String, (String color, double total)>{};
    for (final e in monthExpenses) {
      final name = e.categoryName.isEmpty ? 'Uncategorized' : e.categoryName;
      final prev = byCat[name];
      final col = e.categoryColor.isEmpty ? '#0E7490' : e.categoryColor;
      if (prev == null) {
        byCat[name] = (col, e.amount);
      } else {
        byCat[name] = (prev.$1, prev.$2 + e.amount);
      }
    }

    final expenseByCategory = byCat.entries
        .map(
          (e) => CategorySpend(
            category: e.key,
            color: e.value.$1,
            total: e.value.$2,
          ),
        )
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    final summary = PeriodSummary(
      month: _displayMonth(monthYyyyMm),
      expenseTotal: expenseTotal,
      expenseCount: monthExpenses.length,
      incomeTotal: incomeTotal,
      incomeCount: monthIncomes.length,
      balance: incomeTotal - expenseTotal,
      expenseByCategory: expenseByCategory,
    );

    final financeCategories = categories
        .map(
          (c) => FinanceCategory(
            id: c.serverId ?? 0,
            uuid: c.uuid,
            name: c.name,
            kind: c.kind,
            color: c.color,
            icon: c.icon,
          ),
        )
        .toList();

    final financeAccounts = accounts
        .map(
          (a) => FinanceAccount(
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
          ),
        )
        .toList();

    final recentExpenses = [...expenses]
      ..sort(_cmpExpenseRecentDesc);
    final recentIncomes = [...incomes]
      ..sort(_cmpIncomeRecentDesc);

    final recentExpenseModels = recentExpenses
        .take(8)
        .map((e) => _expenseRowToEntry(e))
        .toList();
    final recentIncomeModels = recentIncomes
        .take(8)
        .map((e) => _incomeRowToEntry(e))
        .toList();

    final budgetModels = budgets
        .take(8)
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

    return FinanceDashboard(
      month: _displayMonth(monthYyyyMm),
      summary: summary,
      categories: financeCategories,
      accounts: financeAccounts,
      recentExpenses: recentExpenseModels,
      recentIncomes: recentIncomeModels,
      budgets: budgetModels,
    );
  }

  static String _displayMonth(String yyyyMm) {
    final parts = yyyyMm.split('-');
    if (parts.length != 2) {
      return yyyyMm;
    }
    return '${parts[1]}-${parts[0]}';
  }

  static bool _inMonth(String dateStr, String monthYyyyMm) {
    final d = parseAppDate(dateStr);
    if (d == null) {
      return false;
    }
    final key =
        '${d.year}-${d.month.toString().padLeft(2, '0')}';
    return key == monthYyyyMm;
  }

  static int _cmpDateDesc(String a, String b) {
    final da = parseAppDate(a);
    final db = parseAppDate(b);
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

  static DateTime? _parseTimestamp(String? isoLike) {
    if (isoLike == null) {
      return null;
    }
    final s = isoLike.trim();
    if (s.isEmpty) {
      return null;
    }
    return DateTime.tryParse(s);
  }

  static int _cmpTimestampDesc(DateTime? a, DateTime? b) {
    if (a == null && b == null) {
      return 0;
    }
    if (a == null) {
      return 1;
    }
    if (b == null) {
      return -1;
    }
    return b.compareTo(a);
  }

  static int _cmpUuidDesc(String a, String b) => b.compareTo(a);

  static int _cmpExpenseRecentDesc(LocalExpenseRow a, LocalExpenseRow b) {
    final dateCmp = _cmpDateDesc(a.spentOn, b.spentOn);
    if (dateCmp != 0) {
      return dateCmp;
    }

    final createdCmp = _cmpTimestampDesc(
      _parseTimestamp(a.createdAt),
      _parseTimestamp(b.createdAt),
    );
    if (createdCmp != 0) {
      return createdCmp;
    }

    final updatedCmp = _cmpTimestampDesc(
      _parseTimestamp(a.updatedAt),
      _parseTimestamp(b.updatedAt),
    );
    if (updatedCmp != 0) {
      return updatedCmp;
    }

    return _cmpUuidDesc(a.uuid, b.uuid);
  }

  static int _cmpIncomeRecentDesc(LocalIncomeRow a, LocalIncomeRow b) {
    final dateCmp = _cmpDateDesc(a.receivedOn, b.receivedOn);
    if (dateCmp != 0) {
      return dateCmp;
    }

    final createdCmp = _cmpTimestampDesc(
      _parseTimestamp(a.createdAt),
      _parseTimestamp(b.createdAt),
    );
    if (createdCmp != 0) {
      return createdCmp;
    }

    final updatedCmp = _cmpTimestampDesc(
      _parseTimestamp(a.updatedAt),
      _parseTimestamp(b.updatedAt),
    );
    if (updatedCmp != 0) {
      return updatedCmp;
    }

    return _cmpUuidDesc(a.uuid, b.uuid);
  }

  static FinanceEntry _expenseRowToEntry(LocalExpenseRow e) {
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

  static FinanceEntry _incomeRowToEntry(LocalIncomeRow e) {
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
}
