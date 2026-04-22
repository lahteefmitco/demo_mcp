import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/finance_models.dart';
import '../../repository/finance_repository.dart';
import 'period_expenses_state.dart';

class PeriodExpensesCubit extends Cubit<PeriodExpensesState> {
  PeriodExpensesCubit({required FinanceRepository repository})
    : _repository = repository,
      super(_initial(repository));

  final FinanceRepository _repository;

  static PeriodExpensesState _initial(FinanceRepository repository) {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, 1);
    final to = DateTime(now.year, now.month + 1, 0);
    const limit = PeriodExpenseRowLimit.fifty;
    return PeriodExpensesState(
      fromDate: from,
      toDate: to,
      limit: limit,
      future: _load(repository, from, to, limit),
    );
  }

  static Future<List<FinanceEntry>> _load(
    FinanceRepository repository,
    DateTime from,
    DateTime to,
    PeriodExpenseRowLimit limit,
  ) {
    return repository.listExpensesLocalInDateRange(
      fromInclusive: from,
      toInclusive: to,
      maxRows: limit.sqlLimit,
    );
  }

  void setFromDate(DateTime d) {
    final normalized = DateTime(d.year, d.month, d.day);
    _reload(fromDate: normalized);
  }

  void setToDate(DateTime d) {
    final normalized = DateTime(d.year, d.month, d.day);
    _reload(toDate: normalized);
  }

  void setLimit(PeriodExpenseRowLimit limit) {
    _reload(limit: limit);
  }

  void refresh() {
    _reload();
  }

  void _reload({
    DateTime? fromDate,
    DateTime? toDate,
    PeriodExpenseRowLimit? limit,
  }) {
    final from = fromDate ?? state.fromDate;
    final to = toDate ?? state.toDate;
    final lim = limit ?? state.limit;
    if (from.isAfter(to)) {
      emit(
        PeriodExpensesState(
          fromDate: from,
          toDate: to,
          limit: lim,
          future: Future<List<FinanceEntry>>.value([]),
          invalidRangeMessage: 'From date must be on or before To date.',
        ),
      );
      return;
    }
    emit(
      PeriodExpensesState(
        fromDate: from,
        toDate: to,
        limit: lim,
        future: _load(_repository, from, to, lim),
        invalidRangeMessage: null,
      ),
    );
  }
}
