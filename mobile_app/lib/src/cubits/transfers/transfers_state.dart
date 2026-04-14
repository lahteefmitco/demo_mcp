import '../../models/finance_models.dart';

class TransfersState {
  const TransfersState({
    required this.accountsFuture,
    required this.transfersFuture,
    required this.toastNonce,
    required this.toastMessage,
    required this.toastIsError,
  });

  final Future<List<FinanceAccount>> accountsFuture;
  final Future<List<Transfer>> transfersFuture;

  final int toastNonce;
  final String? toastMessage;
  final bool toastIsError;

  TransfersState copyWith({
    Future<List<FinanceAccount>>? accountsFuture,
    Future<List<Transfer>>? transfersFuture,
    int? toastNonce,
    String? toastMessage,
    bool? toastIsError,
  }) {
    return TransfersState(
      accountsFuture: accountsFuture ?? this.accountsFuture,
      transfersFuture: transfersFuture ?? this.transfersFuture,
      toastNonce: toastNonce ?? this.toastNonce,
      toastMessage: toastMessage,
      toastIsError: toastIsError ?? this.toastIsError,
    );
  }
}

