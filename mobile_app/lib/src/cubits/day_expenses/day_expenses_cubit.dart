import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/finance_models.dart';
import '../../repository/finance_repository.dart';
import 'day_expenses_state.dart';

class DayExpensesCubit extends Cubit<DayExpensesState> {
  DayExpensesCubit({
    required FinanceRepository repository,
    required String date,
  }) : _repository = repository,
       _date = date,
       super(DayExpensesState(future: _load(repository, date)));

  final FinanceRepository _repository;
  final String _date;

  static String _spentOnDayKey(String date) {
    final t = date.trim();
    if (t.length >= 10 && t[4] == '-') {
      final p = t.substring(0, 10).split('-');
      if (p.length == 3) {
        return '${p[2].padLeft(2, '0')}-${p[1].padLeft(2, '0')}-${p[0]}';
      }
    }
    return t;
  }

  static Future<List<FinanceEntry>> _load(
    FinanceRepository repository,
    String date,
  ) {
    return repository.listExpensesLocal(spentOnEquals: _spentOnDayKey(date));
  }

  Future<void> refresh() async {
    emit(state.copyWith(future: _load(_repository, _date)));
  }
}
