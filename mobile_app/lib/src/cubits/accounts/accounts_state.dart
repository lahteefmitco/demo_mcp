import '../../models/finance_models.dart';

class AccountsState {
  const AccountsState({
    required this.accountsFuture,
    required this.toastNonce,
    required this.toastMessage,
    required this.toastIsError,
  });

  final Future<List<FinanceAccount>> accountsFuture;

  final int toastNonce;
  final String? toastMessage;
  final bool toastIsError;

  AccountsState copyWith({
    Future<List<FinanceAccount>>? accountsFuture,
    int? toastNonce,
    String? toastMessage,
    bool? toastIsError,
  }) {
    return AccountsState(
      accountsFuture: accountsFuture ?? this.accountsFuture,
      toastNonce: toastNonce ?? this.toastNonce,
      toastMessage: toastMessage,
      toastIsError: toastIsError ?? this.toastIsError,
    );
  }
}
