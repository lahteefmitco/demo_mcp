import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/finance_models.dart';
import '../../repository/finance_repository.dart';
import 'category_entries_state.dart';

class CategoryEntriesCubit extends Cubit<CategoryEntriesState> {
  CategoryEntriesCubit({
    required FinanceRepository repository,
    required FinanceCategory category,
  })  : _repository = repository,
        _category = category,
        super(
          CategoryEntriesState(
            future: _load(repository: repository, category: category),
          ),
        );

  final FinanceRepository _repository;
  final FinanceCategory _category;

  static Future<CategoryEntriesData> _load({
    required FinanceRepository repository,
    required FinanceCategory category,
  }) async {
    final futures = <Future<dynamic>>[];

    if (category.kind == 'expense' || category.kind == 'both') {
      futures.add(repository.listExpensesLocal(categoryUuid: category.uuid));
    }

    if (category.kind == 'income' || category.kind == 'both') {
      futures.add(repository.listIncomesLocal(categoryUuid: category.uuid));
    }

    final results = await Future.wait(futures);
    var idx = 0;

    List<FinanceEntry> expenses = const [];
    if (category.kind == 'expense' || category.kind == 'both') {
      expenses = results[idx] as List<FinanceEntry>;
      idx += 1;
    }

    List<FinanceEntry> incomes = const [];
    if (category.kind == 'income' || category.kind == 'both') {
      incomes = results[idx] as List<FinanceEntry>;
    }

    return CategoryEntriesData(expenses: expenses, incomes: incomes);
  }

  Future<void> refresh() async {
    emit(
      state.copyWith(
        future: _load(repository: _repository, category: _category),
      ),
    );
  }
}

