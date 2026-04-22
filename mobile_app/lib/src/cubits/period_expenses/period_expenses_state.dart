import '../../models/finance_models.dart';

enum PeriodExpenseRowLimit { fifty, hundred, all }

extension PeriodExpenseRowLimitX on PeriodExpenseRowLimit {
  /// `null` means no SQL LIMIT (all matching rows).
  int? get sqlLimit => switch (this) {
    PeriodExpenseRowLimit.fifty => 50,
    PeriodExpenseRowLimit.hundred => 100,
    PeriodExpenseRowLimit.all => null,
  };

  String get label => switch (this) {
    PeriodExpenseRowLimit.fifty => '50',
    PeriodExpenseRowLimit.hundred => '100',
    PeriodExpenseRowLimit.all => 'All',
  };
}

class PeriodExpensesState {
  const PeriodExpensesState({
    required this.fromDate,
    required this.toDate,
    required this.limit,
    required this.future,
    this.invalidRangeMessage,
  });

  final DateTime fromDate;
  final DateTime toDate;
  final PeriodExpenseRowLimit limit;
  final Future<List<FinanceEntry>> future;
  final String? invalidRangeMessage;

  PeriodExpensesState copyWith({
    DateTime? fromDate,
    DateTime? toDate,
    PeriodExpenseRowLimit? limit,
    Future<List<FinanceEntry>>? future,
    String? invalidRangeMessage,
  }) {
    return PeriodExpensesState(
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      limit: limit ?? this.limit,
      future: future ?? this.future,
      invalidRangeMessage: invalidRangeMessage ?? this.invalidRangeMessage,
    );
  }
}
