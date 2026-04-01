class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.spentOn,
    required this.notes,
  });

  final int id;
  final double amount;
  final String title;
  final String category;
  final String spentOn;
  final String notes;

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String? ?? '',
      spentOn: json['spentOn'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }
}
