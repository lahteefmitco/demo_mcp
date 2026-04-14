import '../../models/finance_models.dart';
import '../period_expenses/period_expenses_state.dart';

class AccountTransactionsState {
  const AccountTransactionsState({
    required this.account,
    required this.fromDate,
    required this.toDate,
    required this.limit,
    required this.ledgerKind,
    required this.searchQuery,
    required this.future,
    this.invalidRangeMessage,
  });

  final FinanceAccount account;
  final DateTime fromDate;
  final DateTime toDate;
  final PeriodExpenseRowLimit limit;
  final AccountLedgerKind ledgerKind;
  final String searchQuery;
  final Future<List<AccountLedgerItem>> future;
  final String? invalidRangeMessage;

  AccountTransactionsState copyWith({
    FinanceAccount? account,
    DateTime? fromDate,
    DateTime? toDate,
    PeriodExpenseRowLimit? limit,
    AccountLedgerKind? ledgerKind,
    String? searchQuery,
    Future<List<AccountLedgerItem>>? future,
    String? invalidRangeMessage,
    bool clearInvalidRangeMessage = false,
  }) {
    return AccountTransactionsState(
      account: account ?? this.account,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      limit: limit ?? this.limit,
      ledgerKind: ledgerKind ?? this.ledgerKind,
      searchQuery: searchQuery ?? this.searchQuery,
      future: future ?? this.future,
      invalidRangeMessage: clearInvalidRangeMessage
          ? null
          : (invalidRangeMessage ?? this.invalidRangeMessage),
    );
  }
}
