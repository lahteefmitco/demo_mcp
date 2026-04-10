class FinanceCategory {
  const FinanceCategory({
    required this.id,
    required this.uuid,
    required this.name,
    required this.kind,
    required this.color,
    required this.icon,
  });

  final int id;
  final String uuid;
  final String name;
  final String kind;
  final String color;
  final String icon;

  factory FinanceCategory.fromJson(Map<String, dynamic> json) {
    return FinanceCategory(
      id: json['id'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      kind: json['kind'] as String? ?? '',
      color: json['color'] as String? ?? '#0E7490',
      icon: json['icon'] as String? ?? 'tag',
    );
  }
}

class FinanceAccount {
  const FinanceAccount({
    required this.id,
    required this.uuid,
    required this.name,
    required this.type,
    required this.initialBalance,
    required this.currentBalance,
    required this.color,
    required this.icon,
    required this.notes,
    required this.isActive,
  });

  final int id;
  final String uuid;
  final String name;
  final String type;
  final double initialBalance;
  final double currentBalance;
  final String color;
  final String icon;
  final String notes;
  final bool isActive;

  factory FinanceAccount.fromJson(Map<String, dynamic> json) {
    return FinanceAccount(
      id: json['id'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'cash',
      initialBalance: (json['initialBalance'] as num).toDouble(),
      currentBalance: (json['currentBalance'] as num).toDouble(),
      color: json['color'] as String? ?? '#0E7490',
      icon: json['icon'] as String? ?? 'account_balance_wallet',
      notes: json['notes'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'initialBalance': initialBalance,
      'color': color,
      'icon': icon,
      'notes': notes,
    };
  }
}

class FinanceEntry {
  const FinanceEntry({
    required this.id,
    required this.uuid,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.categoryUuid,
    required this.categoryName,
    required this.categoryColor,
    required this.accountId,
    required this.accountUuid,
    required this.accountName,
    required this.accountColor,
    required this.date,
    required this.notes,
  });

  final int id;
  final String uuid;
  final double amount;
  final int categoryId;
  final String categoryUuid;
  final String title;
  final String categoryName;
  final String categoryColor;
  final int accountId;
  final String accountUuid;
  final String accountName;
  final String accountColor;
  final String date;
  final String notes;

  factory FinanceEntry.fromExpenseJson(Map<String, dynamic> json) {
    return FinanceEntry(
      id: json['id'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as int? ?? 0,
      categoryUuid: json['categoryUuid'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      categoryColor: json['categoryColor'] as String? ?? '#0E7490',
      accountId: json['accountId'] as int? ?? 0,
      accountUuid: json['accountUuid'] as String? ?? '',
      accountName: json['accountName'] as String? ?? 'General Account',
      accountColor: json['accountColor'] as String? ?? '#10B981',
      date: json['spentOn'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }

  factory FinanceEntry.fromIncomeJson(Map<String, dynamic> json) {
    return FinanceEntry(
      id: json['id'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as int? ?? 0,
      categoryUuid: json['categoryUuid'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      categoryColor: json['categoryColor'] as String? ?? '#0E7490',
      accountId: json['accountId'] as int? ?? 0,
      accountUuid: json['accountUuid'] as String? ?? '',
      accountName: json['accountName'] as String? ?? 'General Account',
      accountColor: json['accountColor'] as String? ?? '#10B981',
      date: json['receivedOn'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }
}

/// Local expense or income row shown on the account ledger screen.
enum AccountLedgerKind {
  all,
  expense,
  income,
}

class AccountLedgerItem {
  const AccountLedgerItem({required this.isExpense, required this.entry});

  final bool isExpense;
  final FinanceEntry entry;
}

class CategorySpend {
  const CategorySpend({
    required this.category,
    required this.color,
    required this.total,
  });

  final String category;
  final String color;
  final double total;

  factory CategorySpend.fromJson(Map<String, dynamic> json) {
    return CategorySpend(
      category: json['category'] as String? ?? '',
      color: json['color'] as String? ?? '#0E7490',
      total: (json['total'] as num).toDouble(),
    );
  }
}

class PeriodSummary {
  const PeriodSummary({
    required this.month,
    required this.expenseTotal,
    required this.expenseCount,
    required this.incomeTotal,
    required this.incomeCount,
    required this.balance,
    required this.expenseByCategory,
  });

  final String month;
  final double expenseTotal;
  final int expenseCount;
  final double incomeTotal;
  final int incomeCount;
  final double balance;
  final List<CategorySpend> expenseByCategory;

  factory PeriodSummary.fromJson(Map<String, dynamic> json) {
    final items = json['expenseByCategory'] as List<dynamic>? ?? [];
    return PeriodSummary(
      month: json['month'] as String? ?? '',
      expenseTotal: (json['expenseTotal'] as num).toDouble(),
      expenseCount: json['expenseCount'] as int? ?? 0,
      incomeTotal: (json['incomeTotal'] as num).toDouble(),
      incomeCount: json['incomeCount'] as int? ?? 0,
      balance: (json['balance'] as num).toDouble(),
      expenseByCategory: items
          .map((item) => CategorySpend.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BudgetItem {
  const BudgetItem({
    required this.id,
    required this.uuid,
    required this.name,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.notes,
    required this.categoryId,
    this.categoryUuid,
    required this.categoryName,
    required this.categoryColor,
    required this.spent,
    required this.remaining,
  });

  final int id;
  final String uuid;
  final double amount;
  final double spent;
  final double remaining;
  final int? categoryId;
  final String? categoryUuid;
  final String name;
  final String period;
  final String startDate;
  final String endDate;
  final String notes;
  final String? categoryName;
  final String? categoryColor;

  factory BudgetItem.fromJson(Map<String, dynamic> json) {
    return BudgetItem(
      id: json['id'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      period: json['period'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      categoryId: json['categoryId'] as int?,
      categoryUuid: json['categoryUuid'] as String?,
      categoryName: json['categoryName'] as String?,
      categoryColor: json['categoryColor'] as String?,
      spent: (json['spent'] as num).toDouble(),
      remaining: (json['remaining'] as num).toDouble(),
    );
  }
}

class FinanceDashboard {
  const FinanceDashboard({
    required this.month,
    required this.summary,
    required this.categories,
    required this.accounts,
    required this.recentExpenses,
    required this.recentIncomes,
    required this.budgets,
  });

  final String month;
  final PeriodSummary summary;
  final List<FinanceCategory> categories;
  final List<FinanceAccount> accounts;
  final List<FinanceEntry> recentExpenses;
  final List<FinanceEntry> recentIncomes;
  final List<BudgetItem> budgets;

  factory FinanceDashboard.fromJson(Map<String, dynamic> json) {
    final categoriesJson = json['categories'] as List<dynamic>? ?? [];
    final accountsJson = json['accounts'] as List<dynamic>? ?? [];
    final expensesJson = json['recentExpenses'] as List<dynamic>? ?? [];
    final incomesJson = json['recentIncomes'] as List<dynamic>? ?? [];
    final budgetsJson = json['budgets'] as List<dynamic>? ?? [];

    return FinanceDashboard(
      month: json['month'] as String? ?? '',
      summary: PeriodSummary.fromJson(json['summary'] as Map<String, dynamic>),
      categories: categoriesJson
          .map((item) => FinanceCategory.fromJson(item as Map<String, dynamic>))
          .toList(),
      accounts: accountsJson
          .map((item) => FinanceAccount.fromJson(item as Map<String, dynamic>))
          .toList(),
      recentExpenses: expensesJson
          .map(
            (item) =>
                FinanceEntry.fromExpenseJson(item as Map<String, dynamic>),
          )
          .toList(),
      recentIncomes: incomesJson
          .map(
            (item) => FinanceEntry.fromIncomeJson(item as Map<String, dynamic>),
          )
          .toList(),
      budgets: budgetsJson
          .map((item) => BudgetItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DailyExpense {
  const DailyExpense({
    required this.date,
    required this.dayName,
    required this.dayNumber,
    required this.total,
    required this.count,
  });

  final String date;
  final String dayName;
  final String dayNumber;
  final double total;
  final int count;

  factory DailyExpense.fromJson(Map<String, dynamic> json) {
    return DailyExpense(
      date: json['date'] as String? ?? '',
      dayName: json['dayName'] as String? ?? '',
      dayNumber: json['dayNumber'] as String? ?? '',
      total: (json['total'] as num).toDouble(),
      count: json['count'] as int? ?? 0,
    );
  }
}

class WeeklyExpense {
  const WeeklyExpense({
    required this.weekStart,
    required this.dateRange,
    required this.year,
    required this.total,
    required this.count,
  });

  final String weekStart;
  final String dateRange;
  final String year;
  final double total;
  final int count;

  factory WeeklyExpense.fromJson(Map<String, dynamic> json) {
    return WeeklyExpense(
      weekStart: json['weekStart'] as String? ?? '',
      dateRange: json['dateRange'] as String? ?? '',
      year: json['year'] as String? ?? '',
      total: (json['total'] as num).toDouble(),
      count: json['count'] as int? ?? 0,
    );
  }
}

class MonthlyExpense {
  const MonthlyExpense({
    required this.monthStart,
    required this.monthName,
    required this.year,
    required this.total,
    required this.count,
  });

  final String monthStart;
  final String monthName;
  final String year;
  final double total;
  final int count;

  factory MonthlyExpense.fromJson(Map<String, dynamic> json) {
    return MonthlyExpense(
      monthStart: json['monthStart'] as String? ?? '',
      monthName: json['monthName'] as String? ?? '',
      year: json['year'] as String? ?? '',
      total: (json['total'] as num).toDouble(),
      count: json['count'] as int? ?? 0,
    );
  }
}

class AccountSummary {
  const AccountSummary({
    required this.account,
    required this.totalIncome,
    required this.incomeCount,
    required this.totalExpenses,
    required this.expenseCount,
    required this.currentBalance,
  });

  final FinanceAccount account;
  final double totalIncome;
  final int incomeCount;
  final double totalExpenses;
  final int expenseCount;
  final double currentBalance;

  factory AccountSummary.fromJson(Map<String, dynamic> json) {
    return AccountSummary(
      account: FinanceAccount.fromJson(json['account'] as Map<String, dynamic>),
      totalIncome: (json['summary']['totalIncome'] as num).toDouble(),
      incomeCount: json['summary']['incomeCount'] as int? ?? 0,
      totalExpenses: (json['summary']['totalExpenses'] as num).toDouble(),
      expenseCount: json['summary']['expenseCount'] as int? ?? 0,
      currentBalance: (json['summary']['currentBalance'] as num).toDouble(),
    );
  }
}

class Transfer {
  const Transfer({
    required this.id,
    required this.uuid,
    required this.fromAccountId,
    required this.fromAccountUuid,
    required this.fromAccountName,
    required this.toAccountId,
    required this.toAccountUuid,
    required this.toAccountName,
    required this.amount,
    required this.notes,
    required this.createdAt,
  });

  final int id;
  final String uuid;
  final int fromAccountId;
  final String fromAccountUuid;
  final String fromAccountName;
  final int toAccountId;
  final String toAccountUuid;
  final String toAccountName;
  final double amount;
  final String notes;
  final String createdAt;

  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      id: json['id'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? '',
      fromAccountId: json['fromAccountId'] as int? ?? 0,
      fromAccountUuid: json['fromAccountUuid'] as String? ?? '',
      fromAccountName: json['fromAccountName'] as String? ?? '',
      toAccountId: json['toAccountId'] as int? ?? 0,
      toAccountUuid: json['toAccountUuid'] as String? ?? '',
      toAccountName: json['toAccountName'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      notes: json['notes'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
