import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/finance_models.dart';
import '../../repository/finance_repository.dart';
import '../../utils/app_logger.dart';
import 'transfers_state.dart';

class TransfersCubit extends Cubit<TransfersState> {
  TransfersCubit({required FinanceRepository repository})
    : _repository = repository,
      super(
        TransfersState(
          accountsFuture: repository.listAccountsLocal(),
          transfersFuture: _loadTransfers(repository),
          toastNonce: 0,
          toastMessage: null,
          toastIsError: false,
        ),
      );

  final FinanceRepository _repository;

  static Future<List<Transfer>> _loadTransfers(
    FinanceRepository repository,
  ) async {
    final list = await repository.listTransfersLocal();
    return list.length > 20 ? list.sublist(0, 20) : list;
  }

  Future<void> refresh() async {
    emit(
      state.copyWith(
        accountsFuture: _repository.listAccountsLocal(),
        transfersFuture: _loadTransfers(_repository),
      ),
    );
  }

  Future<void> createTransfer({
    required String fromAccountUuid,
    required String toAccountUuid,
    required double amount,
    required String notes,
  }) async {
    try {
      await _repository.transferBetweenAccounts(
        fromAccountUuid: fromAccountUuid,
        toAccountUuid: toAccountUuid,
        amount: amount,
        notes: notes,
      );
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Transfer completed',
          toastIsError: false,
        ),
      );
      await refresh();
    } catch (e, st) {
      AppLogger.e('Create transfer failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Transfer failed',
          toastIsError: true,
        ),
      );
    }
  }
}
