import 'package:flutter/material.dart';

import '../api/expense_api.dart';
import '../models/bootstrap_data.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ExpenseApi _api = ExpenseApi();
  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HomeData> _load() async {
    final month = _currentMonth();
    final results = await Future.wait([
      _api.fetchBootstrap(month),
      _api.fetchExpenses(limit: 50),
    ]);

    return _HomeData(
      bootstrap: results[0] as BootstrapData,
      expenses: results[1] as List<Expense>,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  Future<void> _openAddExpense(_HomeData data) async {
    final payload = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(
          categories: data.bootstrap.categories.isEmpty
              ? const ['Food', 'Transport', 'Bills', 'Shopping', 'General']
              : data.bootstrap.categories,
        ),
      ),
    );

    if (payload == null) {
      return;
    }

    try {
      await _api.createExpense(
        title: payload['title'] as String,
        amount: payload['amount'] as double,
        category: payload['category'] as String,
        spentOn: payload['spentOn'] as String,
        notes: payload['notes'] as String? ?? '',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense created successfully')),
      );
      await _refresh();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Mobile'),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<_HomeData>(
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
                      'Could not load expenses',
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

          final data = snapshot.data!;
          final summary = data.bootstrap.summary;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SummaryCard(summary: summary),
                const SizedBox(height: 16),
                _SectionTitle(title: 'Top Categories', subtitle: 'This month'),
                const SizedBox(height: 8),
                if (summary.byCategory.isEmpty)
                  const _EmptyCard(message: 'No spending this month yet.')
                else
                  ...summary.byCategory.take(4).map(_CategoryTile.new),
                const SizedBox(height: 16),
                _SectionTitle(
                  title: 'Recent Expenses',
                  subtitle: '${data.expenses.length} loaded',
                ),
                const SizedBox(height: 8),
                if (data.expenses.isEmpty)
                  const _EmptyCard(message: 'No expenses found.')
                else
                  ...data.expenses.map(_ExpenseTile.new),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FutureBuilder<_HomeData>(
        future: _future,
        builder: (context, snapshot) {
          return FloatingActionButton.extended(
            onPressed: snapshot.hasData
                ? () => _openAddExpense(snapshot.data!)
                : null,
            icon: const Icon(Icons.add),
            label: const Text('Add Expense'),
          );
        },
      ),
    );
  }

  String _currentMonth() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    return '${now.year}-$month';
  }
}

class _HomeData {
  const _HomeData({required this.bootstrap, required this.expenses});

  final BootstrapData bootstrap;
  final List<Expense> expenses;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final MonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF0EA5A4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Month ${summary.month}',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Text(
            '\$${summary.total.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${summary.expenseCount} expenses tracked',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white),
          ),
        ],
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

class _CategoryTile extends StatelessWidget {
  const _CategoryTile(this.item);

  final CategoryTotal item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.pie_chart_outline)),
        title: Text(item.category),
        trailing: Text(
          '\$${item.total.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile(this.expense);

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFDFF7F4),
          child: Text(
            expense.category.isNotEmpty
                ? expense.category[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: Color(0xFF0F766E),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(expense.title),
        subtitle: Text('${expense.category} • ${expense.spentOn}'),
        trailing: Text(
          '\$${expense.amount.toStringAsFixed(2)}',
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
      child: Padding(padding: const EdgeInsets.all(18), child: Text(message)),
    );
  }
}
