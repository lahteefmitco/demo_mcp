import 'package:flutter_bloc/flutter_bloc.dart';

import '../../api/finance_mcp_client.dart';
import '../../models/finance_models.dart';
import '../../repository/finance_repository.dart';
import '../../utils/app_logger.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required FinanceRepository repository,
    required FinanceMcpClient toolsClient,
  }) : _repository = repository,
       _toolsClient = toolsClient,
       super(
         SettingsState(
           future: _loadInitial(repository),
           toastNonce: 0,
           toastMessage: null,
           toastIsError: false,
         ),
       ) {
    _fetchToolsBackground();
  }

  final FinanceRepository _repository;
  final FinanceMcpClient _toolsClient;

  static Future<SettingsData> _loadInitial(
    FinanceRepository repository,
  ) async {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final monthYyyyMm = '${now.year}-$month';
    final dashboard = await repository.fetchDashboard(monthYyyyMm);
    return SettingsData(dashboard: dashboard);
  }

  void _fetchToolsBackground() async {
    try {
      final tools = await _toolsClient.listTools();
      final currentData = await state.future;
      emit(state.copyWith(future: Future.value(SettingsData(dashboard: currentData.dashboard, tools: tools))));
    } catch (e, st) {
      AppLogger.e('Failed to fetch tools in background', error: e, stackTrace: st);
    }
  }

  Future<void> refresh() async {
    emit(state.copyWith(future: _loadInitial(_repository)));
    _fetchToolsBackground();
    try {
      await state.future;
    } catch (e, st) {
      AppLogger.e('Settings refresh failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Refresh failed',
          toastIsError: true,
        ),
      );
    }
  }

  Future<void> importAllFromServer() async {
    try {
      await _repository.importAllFromServer();
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Import finished',
          toastIsError: false,
        ),
      );
      await refresh();
    } catch (e, st) {
      AppLogger.e('Import failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Import failed: $e',
          toastIsError: true,
        ),
      );
    }
  }

  Future<void> updateCategory({
    required String uuid,
    required String name,
    required String kind,
    required String color,
    required String icon,
  }) async {
    try {
      await _repository.updateCategory(
        uuid: uuid,
        name: name,
        kind: kind,
        color: color,
        icon: icon,
      );
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Category updated',
          toastIsError: false,
        ),
      );
      await refresh();
    } catch (e, st) {
      AppLogger.e('Update category failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Category update failed',
          toastIsError: true,
        ),
      );
    }
  }

  Future<void> deleteCategoryByUuid(String uuid) async {
    try {
      await _repository.deleteCategoryByUuid(uuid);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Category deleted',
          toastIsError: false,
        ),
      );
      await refresh();
    } catch (e, st) {
      AppLogger.e('Delete category failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Category delete failed',
          toastIsError: true,
        ),
      );
    }
  }

  Future<void> createCategory({
    required String name,
    required String kind,
    required String color,
    required String icon,
  }) async {
    try {
      await _repository.createCategory(
        name: name,
        kind: kind,
        color: color,
        icon: icon,
      );
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Category added',
          toastIsError: false,
        ),
      );
      await refresh();
    } catch (e, st) {
      AppLogger.e('Create category failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Category add failed',
          toastIsError: true,
        ),
      );
    }
  }

  Future<void> createBudget({
    required String name,
    required double amount,
    required String period,
    required String startDate,
    required String? categoryUuid,
    required String notes,
  }) async {
    try {
      await _repository.createBudget(
        name: name,
        amount: amount,
        period: period,
        startDate: startDate,
        categoryUuid: categoryUuid,
        notes: notes,
      );
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Budget added',
          toastIsError: false,
        ),
      );
      await refresh();
    } catch (e, st) {
      AppLogger.e('Create budget failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Budget add failed',
          toastIsError: true,
        ),
      );
    }
  }

  Future<void> updateBudget({
    required String uuid,
    required String name,
    required double amount,
    required String period,
    required String startDate,
    required String? categoryUuid,
    required String notes,
  }) async {
    try {
      await _repository.updateBudget(
        uuid: uuid,
        name: name,
        amount: amount,
        period: period,
        startDate: startDate,
        categoryUuid: categoryUuid,
        notes: notes,
      );
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Budget updated',
          toastIsError: false,
        ),
      );
      await refresh();
    } catch (e, st) {
      AppLogger.e('Update budget failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Budget update failed',
          toastIsError: true,
        ),
      );
    }
  }

  Future<void> deleteBudgetByUuid(String uuid) async {
    try {
      await _repository.deleteBudgetByUuid(uuid);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Budget deleted',
          toastIsError: false,
        ),
      );
      await refresh();
    } catch (e, st) {
      AppLogger.e('Delete budget failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          toastNonce: state.toastNonce + 1,
          toastMessage: 'Budget delete failed',
          toastIsError: true,
        ),
      );
    }
  }
}
