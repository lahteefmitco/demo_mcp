import 'package:flutter/material.dart';

import '../api/finance_mcp_client.dart';
import '../models/auth_session.dart';
import '../models/currency_option.dart';
import '../models/finance_models.dart';
import '../utils/currency_utils.dart';

class _DailyExpensesChart extends StatelessWidget {
  const _DailyExpensesChart({
    required this.dailyExpenses,
    required this.currency,
  });

  final List<DailyExpense> dailyExpenses;
  final CurrencyOption currency;

  @override
  Widget build(BuildContext context) {
    if (dailyExpenses.isEmpty) {
      return const _EmptyCard(message: 'No expense data available');
    }

    final maxTotal = dailyExpenses
        .map((e) => e.total)
        .fold(0.0, (a, b) => a > b ? a : b);
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Expenses',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              'Last ${dailyExpenses.length} days',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dailyExpenses.length,
            itemBuilder: (context, index) {
              final expense = dailyExpenses[index];
              final isToday = expense.date == todayStr;
              final barHeight = maxTotal > 0
                  ? (expense.total / maxTotal) * 100
                  : 0.0;

              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : 12,
                  right: index == dailyExpenses.length - 1 ? 0 : 0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (expense.total > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          formatMoney(currency, expense.total),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Container(
                      width: 36,
                      height: barHeight > 0 ? barHeight : 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isToday
                              ? [
                                  const Color(0xFF0F766E),
                                  const Color(0xFF155E75),
                                ]
                              : [
                                  const Color(0xFF94A3B8),
                                  const Color(0xFF64748B),
                                ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(6),
                        border: isToday
                            ? Border.all(
                                color: const Color(0xFF0F766E),
                                width: 2,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      expense.dayName.substring(0, 3),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                        color: isToday
                            ? const Color(0xFF0F766E)
                            : Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    Text(
                      expense.dayNumber,
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    required this.session,
    required this.currency,
    super.key,
  });

  final AuthSession session;
  final CurrencyOption currency;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final FinanceMcpClient _client;
  late Future<FinanceDashboard> _future;
  late Future<List<DailyExpense>> _dailyFuture;

  @override
  void initState() {
    super.initState();
    _client = FinanceMcpClient(token: widget.session.token);
    _future = _load();
    _dailyFuture = _loadDaily();
  }

  Future<FinanceDashboard> _load() async {
    return _client.fetchDashboard(_currentMonth());
  }

  Future<List<DailyExpense>> _loadDaily() async {
    return _client.fetchDailyExpenses(days: 30);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
      _dailyFuture = _loadDaily();
    });
    await Future.wait([_future, _dailyFuture]);
  }

  String _currentMonth() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    return '${now.year}-$month';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<FinanceDashboard>(
        future: _future,
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
                      onPressed: _refresh,
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
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _BalanceCard(summary: summary, currency: widget.currency),
                const SizedBox(height: 24),
                FutureBuilder<List<DailyExpense>>(
                  future: _dailyFuture,
                  builder: (context, dailySnapshot) {
                    if (dailySnapshot.connectionState != ConnectionState.done) {
                      return const SizedBox(
                        height: 180,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (dailySnapshot.hasError) {
                      return _EmptyCard(message: 'Could not load daily data');
                    }
                    return _DailyExpensesChart(
                      dailyExpenses: dailySnapshot.data!,
                      currency: widget.currency,
                    );
                  },
                ),
                const SizedBox(height: 24),
                _StatsRow(summary: summary, currency: widget.currency),
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
                      currency: widget.currency,
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
                      currency: widget.currency,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.summary, required this.currency});

  final PeriodSummary summary;
  final CurrencyOption currency;

  @override
  Widget build(BuildContext context) {
    final isPositive = summary.balance >= 0;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [const Color(0xFF0F766E), const Color(0xFF155E75)]
              : [const Color(0xFFB91C1C), const Color(0xFF991B1B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
                (isPositive ? const Color(0xFF0F766E) : const Color(0xFFB91C1C))
                    .withValues(alpha: 0.3),
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
                'Current Balance',
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
                  summary.month,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formatMoney(currency, summary.balance),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.arrow_downward,
                  label: 'Income',
                  value: formatMoney(currency, summary.incomeTotal),
                  color: const Color(0xFF4ADE80),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatItem(
                  icon: Icons.arrow_upward,
                  label: 'Expenses',
                  value: formatMoney(currency, summary.expenseTotal),
                  color: const Color(0xFFFCA5A5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
