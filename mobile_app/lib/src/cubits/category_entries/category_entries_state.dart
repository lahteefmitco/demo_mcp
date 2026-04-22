import '../../models/finance_models.dart';

class CategoryEntriesState {
  const CategoryEntriesState({required this.future});

  final Future<CategoryEntriesData> future;

  CategoryEntriesState copyWith({Future<CategoryEntriesData>? future}) {
    return CategoryEntriesState(future: future ?? this.future);
  }
}

class CategoryEntriesData {
  const CategoryEntriesData({required this.expenses, required this.incomes});

  final List<FinanceEntry> expenses;
  final List<FinanceEntry> incomes;
}
