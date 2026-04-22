import '../../models/finance_models.dart';

class DayExpensesState {
  const DayExpensesState({required this.future});

  final Future<List<FinanceEntry>> future;

  DayExpensesState copyWith({Future<List<FinanceEntry>>? future}) {
    return DayExpensesState(future: future ?? this.future);
  }
}
