import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repository/finance_repository.dart';
import '../../utils/app_logger.dart';
import 'accounts_state.dart';

class AccountsCubit extends Cubit<AccountsState> {
  AccountsCubit({required FinanceRepository repository})
      : _repository = repository,
        super(
          AccountsState(
            accountsFuture: repository.listAccountsLocal(),
            toastNonce: 0,
            toastMessage: null,
            toastIsError: false,
          ),
        );

  final FinanceRepository _repository;

  Future<void> refresh() async {
    emit(state.copyWith(accountsFuture: _repository.listAccountsLocal()));
    try {
      await state.accountsFuture;
    } catch (e, st) {
      AppLogger.e('Accounts refresh failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Refresh failed',
          toastIsError: true,
        ),
      );
    }
  }

  Future<void> createAccount({
    required String name,
    required String type,
    required double initialBalance,
    required String color,
    required String icon,
    required String notes,
  }) async {
    try {
      await _repository.createAccount(
        name: name,
        type: type,
        initialBalance: initialBalance,
        color: color,
        icon: icon,
        notes: notes,
      );
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Account created',
          toastIsError: false,
        ),
      );
      await refresh();
    } catch (e, st) {
      AppLogger.e('Create account failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Account create failed',
          toastIsError: true,
        ),
      );
    }
  }

  Future<void> updateAccount({
    required String uuid,
    required String name,
    required String type,
    required String color,
    required String icon,
    required String notes,
  }) async {
    try {
      await _repository.updateAccount(
        uuid: uuid,
        name: name,
        type: type,
        color: color,
        icon: icon,
        notes: notes,
      );
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Account updated',
          toastIsError: false,
        ),
      );
      await refresh();
    } catch (e, st) {
      AppLogger.e('Update account failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Account update failed',
          toastIsError: true,
        ),
      );
    }
  }

  Future<void> deleteAccount(String uuid) async {
    try {
      await _repository.deleteAccountByUuid(uuid);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Account deleted',
          toastIsError: false,
        ),
      );
      await refresh();
    } catch (e, st) {
      AppLogger.e('Delete account failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Account delete failed',
          toastIsError: true,
        ),
      );
    }
  }
}

