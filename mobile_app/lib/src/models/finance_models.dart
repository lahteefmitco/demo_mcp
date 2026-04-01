class FinanceCategory {
  const FinanceCategory({
    required this.id,
    required this.name,
    required this.kind,
    required this.color,
    required this.icon,
  });

  final int id;
  final String name;
  final String kind;
  final String color;
  final String icon;

  factory FinanceCategory.fromJson(Map<String, dynamic> json) {
    return FinanceCategory(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      kind: json['kind'] as String? ?? '',
      color: json['color'] as String? ?? '#0E7490',
      icon: json['icon'] as String? ?? 'tag',
    );
  }
}

class FinanceEntry {
  const FinanceEntry({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.date,
    required this.notes,
  });

  final int id;
  final double amount;
  final int categoryId;
  final String title;
  final String categoryName;
  final String categoryColor;
  final String date;
  final String notes;

  factory FinanceEntry.fromExpenseJson(Map<String, dynamic> json) {
    return FinanceEntry(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String? ?? '',
      categoryColor: json['categoryColor'] as String? ?? '#0E7490',
      date: json['spentOn'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }

  factory FinanceEntry.fromIncomeJson(Map<String, dynamic> json) {
    return FinanceEntry(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String? ?? '',
      categoryColor: json['categoryColor'] as String? ?? '#0E7490',
      date: json['receivedOn'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }
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
    required this.name,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.notes,
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.spent,
    required this.remaining,
  });

  final int id;
  final double amount;
  final double spent;
  final double remaining;
  final int? categoryId;
  final String name;
  final String period;
  final String startDate;
  final String endDate;
  final String notes;
  final String? categoryName;
  final String? categoryColor;

  factory BudgetItem.fromJson(Map<String, dynamic> json) {
    return BudgetItem(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      period: json['period'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      categoryId: json['categoryId'] as int?,
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
    required this.recentExpenses,
    required this.recentIncomes,
    required this.budgets,
  });

  final String month;
  final PeriodSummary summary;
  final List<FinanceCategory> categories;
  final List<FinanceEntry> recentExpenses;
  final List<FinanceEntry> recentIncomes;
  final List<BudgetItem> budgets;

  factory FinanceDashboard.fromJson(Map<String, dynamic> json) {
    final categoriesJson = json['categories'] as List<dynamic>? ?? [];
    final expensesJson = json['recentExpenses'] as List<dynamic>? ?? [];
    final incomesJson = json['recentIncomes'] as List<dynamic>? ?? [];
    final budgetsJson = json['budgets'] as List<dynamic>? ?? [];

    return FinanceDashboard(
      month: json['month'] as String? ?? '',
      summary: PeriodSummary.fromJson(json['summary'] as Map<String, dynamic>),
      categories: categoriesJson
          .map((item) => FinanceCategory.fromJson(item as Map<String, dynamic>))
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
