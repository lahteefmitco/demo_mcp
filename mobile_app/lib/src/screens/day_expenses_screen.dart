import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../repository/finance_repository.dart';
import '../models/currency_option.dart';
import '../models/finance_models.dart';
import '../utils/currency_utils.dart';

class DayExpensesScreen extends StatefulWidget {
  const DayExpensesScreen({
    required this.session,
    required this.repository,
    required this.currency,
    required this.date,
    required this.dayName,
    super.key,
  });

  final AuthSession session;
  final FinanceRepository repository;
  final CurrencyOption currency;
  final String date;
  final String dayName;

  @override
  State<DayExpensesScreen> createState() => _DayExpensesScreenState();
}

class _DayExpensesScreenState extends State<DayExpensesScreen> {
  late Future<List<FinanceEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  String _spentOnDayKey() {
    final t = widget.date.trim();
    if (t.length >= 10 && t[4] == '-') {
      final p = t.substring(0, 10).split('-');
      if (p.length == 3) {
        return '${p[2].padLeft(2, '0')}-${p[1].padLeft(2, '0')}-${p[0]}';
      }
    }
    return t;
  }

  Future<List<FinanceEntry>> _load() async {
    return widget.repository.listExpensesLocal(
      spentOnEquals: _spentOnDayKey(),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.dayName} - ${widget.date}')),
      body: FutureBuilder<List<FinanceEntry>>(
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
                      onPressed: _refresh,
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
            onRefresh: _refresh,
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
                            formatMoney(widget.currency, total),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
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
