import '../../models/finance_models.dart';

class DashboardState {
  const DashboardState({
    required this.dashboardFuture,
    required this.dailyFuture,
    required this.weeklyFuture,
    required this.monthlyFuture,
  });

  final Future<FinanceDashboard> dashboardFuture;
  final Future<List<DailyExpense>> dailyFuture;
  final Future<List<WeeklyExpense>> weeklyFuture;
  final Future<List<MonthlyExpense>> monthlyFuture;

  DashboardState copyWith({
    Future<FinanceDashboard>? dashboardFuture,
    Future<List<DailyExpense>>? dailyFuture,
    Future<List<WeeklyExpense>>? weeklyFuture,
    Future<List<MonthlyExpense>>? monthlyFuture,
  }) {
    return DashboardState(
      dashboardFuture: dashboardFuture ?? this.dashboardFuture,
      dailyFuture: dailyFuture ?? this.dailyFuture,
      weeklyFuture: weeklyFuture ?? this.weeklyFuture,
      monthlyFuture: monthlyFuture ?? this.monthlyFuture,
    );
  }
}

