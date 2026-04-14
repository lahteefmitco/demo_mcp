import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/finance_models.dart';
import '../../repository/finance_repository.dart';
import '../period_expenses/period_expenses_state.dart';
import 'account_transactions_state.dart';

class AccountTransactionsCubit extends Cubit<AccountTransactionsState> {
  AccountTransactionsCubit({
    required FinanceRepository repository,
    required FinanceAccount account,
  })  : _repository = repository,
        super(_initial(repository, account));

  final FinanceRepository _repository;

  static AccountTransactionsState _initial(
    FinanceRepository repository,
    FinanceAccount account,
  ) {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, 1);
    final to = DateTime(now.year, now.month + 1, 0);
    const limit = PeriodExpenseRowLimit.fifty;
    const ledgerKind = AccountLedgerKind.all;
    const searchQuery = '';
    return AccountTransactionsState(
      account: account,
      fromDate: from,
      toDate: to,
      limit: limit,
      ledgerKind: ledgerKind,
      searchQuery: searchQuery,
      future: _load(
        repository,
        account,
        from,
        to,
        limit,
        ledgerKind,
        searchQuery,
      ),
    );
  }

  static Future<List<AccountLedgerItem>> _load(
    FinanceRepository repository,
    FinanceAccount account,
    DateTime from,
    DateTime to,
    PeriodExpenseRowLimit limit,
    AccountLedgerKind ledgerKind,
    String searchQuery,
  ) {
    return repository.listAccountLedgerLocal(
      accountUuid: account.uuid,
      fromInclusive: from,
      toInclusive: to,
      kind: ledgerKind,
      searchQuery: searchQuery,
      maxRows: limit.sqlLimit,
    );
  }

  void setFromDate(DateTime d) {
    _reload(fromDate: DateTime(d.year, d.month, d.day));
  }

  void setToDate(DateTime d) {
    _reload(toDate: DateTime(d.year, d.month, d.day));
  }

  void setLimit(PeriodExpenseRowLimit limit) {
    _reload(limit: limit);
  }

  void setLedgerKind(AccountLedgerKind ledgerKind) {
    _reload(ledgerKind: ledgerKind);
  }

  void setSearchQuery(String searchQuery) {
    _reload(searchQuery: searchQuery);
  }

  void refresh() {
    _reload();
  }

  void _reload({
    DateTime? fromDate,
    DateTime? toDate,
    PeriodExpenseRowLimit? limit,
    AccountLedgerKind? ledgerKind,
    String? searchQuery,
  }) {
    final from = fromDate ?? state.fromDate;
    final to = toDate ?? state.toDate;
    final lim = limit ?? state.limit;
    final kind = ledgerKind ?? state.ledgerKind;
    final search = searchQuery ?? state.searchQuery;
    if (from.isAfter(to)) {
      emit(
        state.copyWith(
          fromDate: from,
          toDate: to,
          limit: lim,
          ledgerKind: kind,
          searchQuery: search,
          future: Future<List<AccountLedgerItem>>.value([]),
          invalidRangeMessage: 'From date must be on or before To date.',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        fromDate: from,
        toDate: to,
        limit: lim,
        ledgerKind: kind,
        searchQuery: search,
        future: _load(_repository, state.account, from, to, lim, kind, search),
        clearInvalidRangeMessage: true,
      ),
    );
  }
}
