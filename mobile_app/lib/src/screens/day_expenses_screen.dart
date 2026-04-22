import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/auth_session.dart';
import '../repository/finance_repository.dart';
import '../cubits/day_expenses/day_expenses_cubit.dart';
import '../cubits/day_expenses/day_expenses_state.dart';
import '../models/currency_option.dart';
import '../models/finance_models.dart';
import '../utils/currency_utils.dart';

class DayExpensesScreen extends StatelessWidget {
  const DayExpensesScreen({
    required this.session,
    required this.currency,
    required this.date,
    required this.dayName,
    super.key,
  });

  final AuthSession session;
  final CurrencyOption currency;
  final String date;
  final String dayName;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<FinanceRepository>();
    return Scaffold(
      appBar: AppBar(title: Text('$dayName - $date')),
      body: BlocProvider(
        create: (_) => DayExpensesCubit(repository: repo, date: date),
        child: BlocBuilder<DayExpensesCubit, DayExpensesState>(
          buildWhen: (p, n) => p.future != n.future,
          builder: (context, state) {
            return FutureBuilder<List<FinanceEntry>>(
              future: state.future,
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
                          const Icon(Icons.error_outline, size: 52),
                          const SizedBox(height: 12),
                          Text(
                            'Could not load expenses',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(snapshot.error.toString()),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () =>
                                context.read<DayExpensesCubit>().refresh(),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final expenses = snapshot.data!;
                final total = expenses.fold(0.0, (sum, e) => sum + e.amount);

                return RefreshIndicator(
                  onRefresh: () => context.read<DayExpensesCubit>().refresh(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F766E), Color(0xFF155E75)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Expenses',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatMoney(currency, total),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              child: Text(
                                '${expenses.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (expenses.isEmpty)
                        const _EmptyCard(message: 'No expenses for this day.')
                      else
                        ...expenses.map(
                          (expense) => _ExpenseTile(
                            expense: expense,
                            currency: currency,
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({required this.expense, required this.currency});

  final FinanceEntry expense;
  final CurrencyOption currency;

  Color _parseColor(String hex) {
    final normalized = hex.replaceFirst('#', '');
    return Color(int.parse('FF$normalized', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(expense.categoryColor);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(Icons.receipt_long, color: color),
        ),
        title: Text(expense.title),
        subtitle: Text(expense.categoryName),
        trailing: Text(
          formatMoney(currency, expense.amount),
          style: const TextStyle(fontWeight: FontWeight.w700),
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
        padding: const EdgeInsets.all(24),
        child: Center(child: Text(message)),
      ),
    );
  }
}
