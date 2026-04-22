import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repository/finance_repository.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required FinanceRepository repository,
    required String monthYyyyMm,
  }) : _repository = repository,
       _month = monthYyyyMm,
       super(
         DashboardState(
           dashboardFuture: repository.fetchDashboard(monthYyyyMm),
           dailyFuture: repository.fetchDailyExpenses(days: 30),
           weeklyFuture: repository.fetchWeeklyExpenses(weeks: 8),
           monthlyFuture: repository.fetchMonthlyExpenses(months: 6),
         ),
       );

  final FinanceRepository _repository;
  String _month;

  String get month => _month;

  void setMonth(String monthYyyyMm) {
    _month = monthYyyyMm;
  }

  /// Refreshes all dashboard futures.
  Future<void> refresh() async {
    emit(
      state.copyWith(
        dashboardFuture: _repository.fetchDashboard(_month),
        dailyFuture: _repository.fetchDailyExpenses(days: 30),
        weeklyFuture: _repository.fetchWeeklyExpenses(weeks: 8),
        monthlyFuture: _repository.fetchMonthlyExpenses(months: 6),
      ),
    );
  }
}
