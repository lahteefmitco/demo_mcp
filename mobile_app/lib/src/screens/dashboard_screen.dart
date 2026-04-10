import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/auth_session.dart';
import '../repository/finance_repository.dart';
import '../cubits/shell/shell_cubit.dart';
import '../cubits/shell/shell_state.dart';
import '../cubits/dashboard/dashboard_cubit.dart';
import '../cubits/dashboard/dashboard_state.dart';
import '../models/currency_option.dart';
import '../models/finance_models.dart';
import '../utils/currency_utils.dart';
import '../utils/finance_repository_scope.dart';
import 'day_expenses_screen.dart';

class _DailyExpensesChart extends StatefulWidget {
  const _DailyExpensesChart({
    required this.dailyExpenses,
    required this.currency,
    required this.onDayTap,
  });

  final List<DailyExpense> dailyExpenses;
  final CurrencyOption currency;
  final void Function(DailyExpense expense) onDayTap;

  @override
  State<_DailyExpensesChart> createState() => _DailyExpensesChartState();
}

class _DailyExpensesChartState extends State<_DailyExpensesChart> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
  }

  @override
  void didUpdateWidget(_DailyExpensesChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dailyExpenses.length != oldWidget.dailyExpenses.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    if (!_scrollController.hasClients) return;
    if (widget.dailyExpenses.isEmpty) return;
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dailyExpenses.isEmpty) {
      return const _EmptyCard(message: 'No expense data available');
    }

    final maxTotal = widget.dailyExpenses
        .map((e) => e.total)
        .fold(0.0, (a, b) => a > b ? a : b);
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Expenses',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                'Last ${widget.dailyExpenses.length} days',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.dailyExpenses.length,
            itemBuilder: (context, index) {
              final expense = widget.dailyExpenses[index];
              final isToday = expense.date == todayStr;
              final barHeight = maxTotal > 0
                  ? (expense.total / maxTotal) * 85
                  : 0.0;

              final colors = [
                [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                [const Color(0xFFF97316), const Color(0xFFEA580C)],
                [const Color(0xFFEAB308), const Color(0xFFCA8A04)],
                [const Color(0xFF22C55E), const Color(0xFF16A34A)],
                [const Color(0xFF14B8A6), const Color(0xFF0F766E)],
                [const Color(0xFF0EA5E9), const Color(0xFF0284C7)],
                [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
                [const Color(0xFFD946EF), const Color(0xFFC026D3)],
                [const Color(0xFFEC4899), const Color(0xFFDB2777)],
              ];
              final colorPair = isToday
                  ? [const Color(0xFF0F766E), const Color(0xFF155E75)]
                  : colors[index % colors.length];

              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : 8,
                  right: index == widget.dailyExpenses.length - 1 ? 0 : 0,
                ),
                child: InkWell(
                  onTap: () => widget.onDayTap(expense),
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 44,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (expense.total > 0)
                          Text(
                            formatMoney(widget.currency, expense.total),
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: colorPair[0],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 2),
                        Container(
                          width: 28,
                          height: barHeight > 0 ? barHeight : 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: colorPair,
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            border: isToday
                                ? Border.all(color: colorPair[0], width: 2)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          expense.dayName.substring(0, 3),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: isToday
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isToday
                                ? colorPair[0]
                                : Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          expense.dayNumber,
                          style: TextStyle(
                            fontSize: 8,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    required this.session,
    required this.currency,
    super.key,
  });

  final AuthSession session;
  final CurrencyOption currency;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<FinanceRepository>();
    final month = _currentMonth();

    return BlocProvider(
      create: (_) => DashboardCubit(repository: repo, monthYyyyMm: month),
      child: BlocListener<ShellCubit, ShellState>(
        listenWhen: (prev, next) =>
            next.selectedIndex == 1 && prev.selectedIndex != next.selectedIndex,
        listener: (context, state) {
          context.read<DashboardCubit>().refresh();
        },
        child: DefaultTabController(
          length: 3,
          child: BlocBuilder<DashboardCubit, DashboardState>(
          buildWhen: (p, n) =>
              p.dashboardFuture != n.dashboardFuture ||
              p.dailyFuture != n.dailyFuture ||
              p.weeklyFuture != n.weeklyFuture ||
              p.monthlyFuture != n.monthlyFuture,
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Dashboard'),
                actions: [
                  IconButton(
                    onPressed: () => context.read<DashboardCubit>().refresh(),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              body: FutureBuilder<FinanceDashboard>(
                future: state.dashboardFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_off, size: 52),
                            const SizedBox(height: 12),
                            Text(
                              'Could not load dashboard',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              snapshot.error.toString(),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () =>
                                  context.read<DashboardCubit>().refresh(),
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final dashboard = snapshot.data!;
                  final summary = dashboard.summary;
                  final maxSpend = summary.expenseByCategory.isEmpty
                      ? 1.0
                      : summary.expenseByCategory
                          .map((e) => e.total)
                          .reduce((a, b) => a > b ? a : b);

                  return RefreshIndicator(
                    onRefresh: () => context.read<DashboardCubit>().refresh(),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _AccountsBalanceCard(
                          accounts: dashboard.accounts,
                          currency: currency,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const TabBar(
                                labelColor: Color(0xFF0F766E),
                                unselectedLabelColor: Colors.grey,
                                indicatorColor: Color(0xFF0F766E),
                                tabs: [
                                  Tab(text: 'Daily'),
                                  Tab(text: 'Weekly'),
                                  Tab(text: 'Monthly'),
                                ],
                              ),
                              SizedBox(
                                height: 200,
                                child: TabBarView(
                                  children: [
                                    FutureBuilder<List<DailyExpense>>(
                                      future: state.dailyFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState !=
                                            ConnectionState.done) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        if (snapshot.hasError) {
                                          return const _EmptyCard(
                                            message: 'Could not load daily data',
                                          );
                                        }
                                        return _DailyExpensesChart(
                                          dailyExpenses: snapshot.data!,
                                          currency: currency,
                                          onDayTap: (e) =>
                                              _openDayExpenses(context, e),
                                        );
                                      },
                                    ),
                                    FutureBuilder<List<WeeklyExpense>>(
                                      future: state.weeklyFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState !=
                                            ConnectionState.done) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        if (snapshot.hasError) {
                                          return const _EmptyCard(
                                            message:
                                                'Could not load weekly data',
                                          );
                                        }
                                        return _WeeklyExpensesChart(
                                          weeklyExpenses: snapshot.data!,
                                          currency: currency,
                                          onWeekTap: (e) =>
                                              _openWeekExpenses(context, e),
                                        );
                                      },
                                    ),
                                    FutureBuilder<List<MonthlyExpense>>(
                                      future: state.monthlyFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState !=
                                            ConnectionState.done) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        if (snapshot.hasError) {
                                          return const _EmptyCard(
                                            message:
                                                'Could not load monthly data',
                                          );
                                        }
                                        return _MonthlyExpensesChart(
                                          monthlyExpenses: snapshot.data!,
                                          currency: currency,
                                          onMonthTap: (e) =>
                                              _openMonthExpenses(context, e),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _StatsRow(summary: summary, currency: currency),
                        const SizedBox(height: 24),
                        _SectionTitle(
                          title: 'Spending by Category',
                          subtitle: summary.month,
                        ),
                        const SizedBox(height: 12),
                        if (summary.expenseByCategory.isEmpty)
                          const _EmptyCard(message: 'No spending this month.')
                        else
                          ...summary.expenseByCategory.map(
                            (item) => _CategoryBar(
                              item: item,
                              currency: currency,
                              maxValue: maxSpend,
                            ),
                          ),
                        const SizedBox(height: 24),
                        _SectionTitle(
                          title: 'Budget Overview',
                          subtitle: '${dashboard.budgets.length} budgets',
                        ),
                        const SizedBox(height: 12),
                        if (dashboard.budgets.isEmpty)
                          const _EmptyCard(message: 'No budgets set.')
                        else
                          ...dashboard.budgets.map(
                            (budget) => _BudgetProgressCard(
                              budget: budget,
                              currency: currency,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    ),
    );
  }

  String _currentMonth() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    return '${now.year}-$month';
  }

  Future<void> _pushDayExpenses(
    BuildContext context, {
    required String date,
    required String dayName,
  }) async {
    await pushRouteWithFinanceRepository<void>(
      context,
      DayExpensesScreen(
        session: session,
        currency: currency,
        date: date,
        dayName: dayName,
      ),
    );
  }

  Future<void> _openDayExpenses(
    BuildContext context,
    DailyExpense expense,
  ) async {
    await _pushDayExpenses(
      context,
      date: expense.date,
      dayName: expense.dayName,
    );
  }

  Future<void> _openWeekExpenses(
    BuildContext context,
    WeeklyExpense expense,
  ) async {
    await _pushDayExpenses(
      context,
      date: expense.weekStart,
      dayName: 'Week of ${expense.dateRange}',
    );
  }

  Future<void> _openMonthExpenses(
    BuildContext context,
    MonthlyExpense expense,
  ) async {
    await _pushDayExpenses(
      context,
      date: expense.monthStart,
      dayName: '${expense.monthName} ${expense.year}',
    );
  }
}

class _AccountsBalanceCard extends StatelessWidget {
  const _AccountsBalanceCard({required this.accounts, required this.currency});

  final List<FinanceAccount> accounts;
  final CurrencyOption currency;

  @override
  Widget build(BuildContext context) {
    final activeAccounts = accounts.where((a) => a.isActive).toList();
    final totalBalance = activeAccounts.fold<double>(
      0,
      (sum, account) => sum + account.currentBalance,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF155E75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.white70),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${activeAccounts.length} accounts',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formatMoney(currency, totalBalance),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          ...activeAccounts.map(
            (account) =>
                _AccountBalanceItem(account: account, currency: currency),
          ),
        ],
      ),
    );
  }
}

class _AccountBalanceItem extends StatelessWidget {
  const _AccountBalanceItem({required this.account, required this.currency});

  final FinanceAccount account;
  final CurrencyOption currency;

  Color _parseColor(String hex) {
    final normalized = hex.replaceFirst('#', '');
    return Color(int.parse('FF$normalized', radix: 16));
  }

  IconData _getAccountIcon() {
    switch (account.icon) {
      case 'account_balance':
        return Icons.account_balance;
      case 'credit_card':
        return Icons.credit_card;
      case 'trending_up':
        return Icons.trending_up;
      default:
        return Icons.account_balance_wallet;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountColor = _parseColor(account.color);
    final isPositive = account.currentBalance >= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accountColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getAccountIcon(), color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _getAccountTypeLabel(account.type),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              formatMoney(currency, account.currentBalance),
              style: TextStyle(
                color: isPositive
                    ? const Color(0xFF4ADE80)
                    : const Color(0xFFFCA5A5),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAccountTypeLabel(String type) {
    switch (type) {
      case 'cash':
        return 'Cash';
      case 'bank':
        return 'Bank';
      case 'credit_card':
        return 'Credit Card';
      case 'investments':
        return 'Investments';
      default:
        return type;
    }
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.summary, required this.currency});

  final PeriodSummary summary;
  final CurrencyOption currency;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickStatCard(
            icon: Icons.receipt_long,
            label: 'Expenses',
            count: summary.expenseCount,
            color: const Color(0xFFFEE2E2),
            iconColor: const Color(0xFFB91C1C),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickStatCard(
            icon: Icons.payments,
            label: 'Income',
            count: summary.incomeCount,
            color: const Color(0xFFDCFCE7),
            iconColor: const Color(0xFF15803D),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickStatCard(
            icon: Icons.category,
            label: 'Categories',
            count: 0,
            color: const Color(0xFFE0E7FF),
            iconColor: const Color(0xFF4F46E5),
          ),
        ),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.item,
    required this.currency,
    required this.maxValue,
  });

  final CategorySpend item;
  final CurrencyOption currency;
  final double maxValue;

  Color _parseColor(String hex) {
    final normalized = hex.replaceFirst('#', '');
    return Color(int.parse('FF$normalized', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final percentage = maxValue > 0 ? (item.total / maxValue) : 0.0;
    final color = _parseColor(item.color);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(item.category),
                ],
              ),
              Text(
                formatMoney(currency, item.total),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetProgressCard extends StatelessWidget {
  const _BudgetProgressCard({required this.budget, required this.currency});

  final BudgetItem budget;
  final CurrencyOption currency;

  @override
  Widget build(BuildContext context) {
    final progress = budget.amount == 0
        ? 0.0
        : (budget.spent / budget.amount).clamp(0.0, 1.0);
    final isOverBudget = budget.remaining < 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    budget.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isOverBudget
                        ? const Color(0xFFFEE2E2)
                        : const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    budget.period,
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverBudget
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
            if (budget.categoryName != null) ...[
              const SizedBox(height: 4),
              Text(
                budget.categoryName!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: AlwaysStoppedAnimation(
                  isOverBudget
                      ? const Color(0xFFB91C1C)
                      : const Color(0xFF0F766E),
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${formatMoney(currency, budget.spent)} spent',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${formatMoney(currency, budget.remaining)} ${isOverBudget ? 'over' : 'left'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isOverBudget
                        ? const Color(0xFFB91C1C)
                        : const Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyExpensesChart extends StatefulWidget {
  const _WeeklyExpensesChart({
    required this.weeklyExpenses,
    required this.currency,
    required this.onWeekTap,
  });

  final List<WeeklyExpense> weeklyExpenses;
  final CurrencyOption currency;
  final void Function(WeeklyExpense) onWeekTap;

  @override
  State<_WeeklyExpensesChart> createState() => _WeeklyExpensesChartState();
}

class _WeeklyExpensesChartState extends State<_WeeklyExpensesChart> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void didUpdateWidget(_WeeklyExpensesChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.weeklyExpenses.length != oldWidget.weeklyExpenses.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.weeklyExpenses.isEmpty) {
      return const _EmptyCard(message: 'No weekly data available');
    }

    final maxTotal = widget.weeklyExpenses
        .map((e) => e.total)
        .fold(0.0, (a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Expenses',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                'Last ${widget.weeklyExpenses.length} weeks',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.weeklyExpenses.length,
            itemBuilder: (context, index) {
              final expense = widget.weeklyExpenses[index];
              final barHeight = maxTotal > 0
                  ? (expense.total / maxTotal) * 85
                  : 0.0;

              final colors = [
                [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                [const Color(0xFFF97316), const Color(0xFFEA580C)],
                [const Color(0xFFEAB308), const Color(0xFFCA8A04)],
                [const Color(0xFF22C55E), const Color(0xFF16A34A)],
                [const Color(0xFF14B8A6), const Color(0xFF0F766E)],
                [const Color(0xFF0EA5E9), const Color(0xFF0284C7)],
                [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
              ];
              final colorPair = colors[index % colors.length];

              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : 8,
                  right: index == widget.weeklyExpenses.length - 1 ? 0 : 0,
                ),
                child: InkWell(
                  onTap: () => widget.onWeekTap(expense),
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 52,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (expense.total > 0)
                          Text(
                            formatMoney(widget.currency, expense.total),
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: colorPair[0],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 2),
                        Container(
                          width: 28,
                          height: barHeight > 0 ? barHeight : 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: colorPair,
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          expense.dateRange,
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          expense.year,
                          style: const TextStyle(
                            fontSize: 7,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MonthlyExpensesChart extends StatefulWidget {
  const _MonthlyExpensesChart({
    required this.monthlyExpenses,
    required this.currency,
    required this.onMonthTap,
  });

  final List<MonthlyExpense> monthlyExpenses;
  final CurrencyOption currency;
  final void Function(MonthlyExpense) onMonthTap;

  @override
  State<_MonthlyExpensesChart> createState() => _MonthlyExpensesChartState();
}

class _MonthlyExpensesChartState extends State<_MonthlyExpensesChart> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void didUpdateWidget(_MonthlyExpensesChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.monthlyExpenses.length != oldWidget.monthlyExpenses.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.monthlyExpenses.isEmpty) {
      return const _EmptyCard(message: 'No monthly data available');
    }

    final maxTotal = widget.monthlyExpenses
        .map((e) => e.total)
        .fold(0.0, (a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Expenses',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                'Last ${widget.monthlyExpenses.length} months',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.monthlyExpenses.length,
            itemBuilder: (context, index) {
              final expense = widget.monthlyExpenses[index];
              final barHeight = maxTotal > 0
                  ? (expense.total / maxTotal) * 85
                  : 0.0;

              final colors = [
                [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                [const Color(0xFFF97316), const Color(0xFFEA580C)],
                [const Color(0xFFEAB308), const Color(0xFFCA8A04)],
                [const Color(0xFF22C55E), const Color(0xFF16A34A)],
                [const Color(0xFF14B8A6), const Color(0xFF0F766E)],
                [const Color(0xFF0EA5E9), const Color(0xFF0284C7)],
                [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
              ];
              final colorPair = colors[index % colors.length];

              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : 8,
                  right: index == widget.monthlyExpenses.length - 1 ? 0 : 0,
                ),
                child: InkWell(
                  onTap: () => widget.onMonthTap(expense),
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (expense.total > 0)
                          Text(
                            formatMoney(widget.currency, expense.total),
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: colorPair[0],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 2),
                        Container(
                          width: 32,
                          height: barHeight > 0 ? barHeight : 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: colorPair,
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          expense.monthName,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          expense.year,
                          style: const TextStyle(
                            fontSize: 7,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Center(child: Text(message)),
      ),
    );
  }
}
