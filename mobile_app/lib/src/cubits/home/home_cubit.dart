import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repository/finance_repository.dart';
import '../../utils/app_logger.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required FinanceRepository repository})
      : _repository = repository,
        super(HomeState.initial());

  final FinanceRepository _repository;

  Future<void> load(String monthYyyyMm) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final dashboard = await _repository.fetchDashboard(monthYyyyMm);
      emit(
        state.copyWith(
          isLoading: false,
          dashboard: dashboard,
          errorMessage: null,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Home load failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> refresh(String monthYyyyMm) async {
    try {
      final dashboard = await _repository.fetchDashboard(monthYyyyMm);
      emit(
        state.copyWith(
          isLoading: false,
          dashboard: dashboard,
          errorMessage: null,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Home refresh failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Refresh failed',
          toastIsError: true,
        ),
      );
    }
  }

  Future<void> syncNow({required String monthYyyyMm}) async {
    try {
      await _repository.pushUnsynced();
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Sync complete',
          toastIsError: false,
        ),
      );
      await refresh(monthYyyyMm);
    } catch (e, st) {
      AppLogger.e('Sync now failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Sync failed',
          toastIsError: true,
        ),
      );
    }
  }

  Future<void> createExpense({
    required String title,
    required double amount,
    required String categoryUuid,
    required String accountUuid,
    required String spentOn,
    required String notes,
    required String monthYyyyMm,
  }) async {
    try {
      await _repository.createExpense(
        title: title,
        amount: amount,
        categoryUuid: categoryUuid,
        accountUuid: accountUuid,
        spentOn: spentOn,
        notes: notes,
      );
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Expense added',
          toastIsError: false,
        ),
      );
      await refresh(monthYyyyMm);
    } catch (e, st) {
      AppLogger.e('Create expense failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Failed to add expense',
          toastIsError: true,
        ),
      );
    }
  }

  Future<void> updateExpense({
    required String uuid,
    required String title,
    required double amount,
    required String categoryUuid,
    required String accountUuid,
    required String spentOn,
    required String notes,
    required String monthYyyyMm,
  }) async {
    try {
      await _repository.updateExpense(
        uuid: uuid,
        title: title,
        amount: amount,
        categoryUuid: categoryUuid,
        accountUuid: accountUuid,
        spentOn: spentOn,
        notes: notes,
      );
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Expense updated',
          toastIsError: false,
        ),
      );
      await refresh(monthYyyyMm);
    } catch (e, st) {
      AppLogger.e('Update expense failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Failed to update expense',
          toastIsError: true,
        ),
      );
    }
  }

  Future<void> deleteExpense({
    required String uuid,
    required String monthYyyyMm,
  }) async {
    try {
      await _repository.deleteExpenseByUuid(uuid);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Expense deleted',
          toastIsError: false,
        ),
      );
      await refresh(monthYyyyMm);
    } catch (e, st) {
      AppLogger.e('Delete expense failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Failed to delete expense',
          toastIsError: true,
        ),
      );
    }
  }

  Future<void> createIncome({
    required String title,
    required double amount,
    required String categoryUuid,
    required String accountUuid,
    required String receivedOn,
    required String notes,
    required String monthYyyyMm,
  }) async {
    try {
      await _repository.createIncome(
        title: title,
        amount: amount,
        categoryUuid: categoryUuid,
        accountUuid: accountUuid,
        receivedOn: receivedOn,
        notes: notes,
      );
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Income added',
          toastIsError: false,
        ),
      );
      await refresh(monthYyyyMm);
    } catch (e, st) {
      AppLogger.e('Create income failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Failed to add income',
          toastIsError: true,
        ),
      );
    }
  }

  Future<void> updateIncome({
    required String uuid,
    required String title,
    required double amount,
    required String categoryUuid,
    required String accountUuid,
    required String receivedOn,
    required String notes,
    required String monthYyyyMm,
  }) async {
    try {
      await _repository.updateIncome(
        uuid: uuid,
        title: title,
        amount: amount,
        categoryUuid: categoryUuid,
        accountUuid: accountUuid,
        receivedOn: receivedOn,
        notes: notes,
      );
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Income updated',
          toastIsError: false,
        ),
      );
      await refresh(monthYyyyMm);
    } catch (e, st) {
      AppLogger.e('Update income failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Failed to update income',
          toastIsError: true,
        ),
      );
    }
  }

  Future<void> deleteIncome({
    required String uuid,
    required String monthYyyyMm,
  }) async {
    try {
      await _repository.deleteIncomeByUuid(uuid);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Income deleted',
          toastIsError: false,
        ),
      );
      await refresh(monthYyyyMm);
    } catch (e, st) {
      AppLogger.e('Delete income failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Failed to delete income',
          toastIsError: true,
        ),
      );
    }
  }
}

