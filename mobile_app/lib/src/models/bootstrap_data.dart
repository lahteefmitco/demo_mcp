import 'expense.dart';

class CategoryTotal {
  const CategoryTotal({required this.category, required this.total});

  final String category;
  final double total;

  factory CategoryTotal.fromJson(Map<String, dynamic> json) {
    return CategoryTotal(
      category: json['category'] as String? ?? '',
      total: (json['total'] as num).toDouble(),
    );
  }
}

class MonthlySummary {
  const MonthlySummary({
    required this.month,
    required this.total,
    required this.expenseCount,
    required this.byCategory,
  });

  final String month;
  final double total;
  final int expenseCount;
  final List<CategoryTotal> byCategory;

  factory MonthlySummary.fromJson(Map<String, dynamic> json) {
    final byCategoryJson = (json['byCategory'] as List<dynamic>? ?? []);

    return MonthlySummary(
      month: json['month'] as String? ?? '',
      total: (json['total'] as num).toDouble(),
      expenseCount: json['expenseCount'] as int? ?? 0,
      byCategory: byCategoryJson
          .map((item) => CategoryTotal.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BootstrapData {
  const BootstrapData({
    required this.month,
    required this.summary,
    required this.categories,
    required this.recentExpenses,
  });

  final String month;
  final MonthlySummary summary;
  final List<String> categories;
  final List<Expense> recentExpenses;

  factory BootstrapData.fromJson(Map<String, dynamic> json) {
    final categoriesJson = (json['categories'] as List<dynamic>? ?? []);
    final expensesJson = (json['recentExpenses'] as List<dynamic>? ?? []);

    return BootstrapData(
      month: json['month'] as String? ?? '',
      summary: MonthlySummary.fromJson(json['summary'] as Map<String, dynamic>),
      categories: categoriesJson.map((item) => item.toString()).toList(),
      recentExpenses: expensesJson
          .map((item) => Expense.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
