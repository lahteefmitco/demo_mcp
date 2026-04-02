import 'package:flutter/material.dart';

import '../api/finance_mcp_client.dart';
import '../models/auth_session.dart';
import '../models/finance_models.dart';
import '../models/mcp_tool.dart';
import 'add_budget_screen.dart';
import 'add_category_screen.dart';
import 'add_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.session, required this.onLogout, super.key});

  final AuthSession session;
  final Future<void> Function() onLogout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final FinanceMcpClient _client;
  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _client = FinanceMcpClient(token: widget.session.token);
    _future = _load();
  }

  Future<_HomeData> _load() async {
    final month = _currentMonth();
    final results = await Future.wait([
      _client.fetchDashboard(month),
      _client.listTools(),
    ]);

    return _HomeData(
      dashboard: results[0] as FinanceDashboard,
      tools: results[1] as List<McpTool>,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  Future<void> _openExpenseActions(_HomeData data, FinanceEntry expense) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit expense'),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete expense'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );

    if (!mounted || action == null) {
      return;
    }

    if (action == 'edit') {
      await _editExpense(data, expense);
    }

    if (action == 'delete') {
      await _confirmDeleteExpense(expense);
    }
  }

  Future<void> _editExpense(_HomeData data, FinanceEntry expense) async {
    final categories = data.dashboard.categories
        .where(
          (category) => category.kind == 'expense' || category.kind == 'both',
        )
        .toList();
    final payload = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => AddEntryScreen(
          title: 'Edit Expense',
          categories: categories,
          dateLabel: 'Spent on',
          dateKey: 'spentOn',
          initialEntry: expense,
          saveLabel: 'Update',
        ),
      ),
    );

    if (!mounted || payload == null) {
      return;
    }

    await _client.updateExpense(
      id: expense.id,
      title: payload['title'] as String,
      amount: payload['amount'] as double,
      categoryId: payload['categoryId'] as int,
      spentOn: payload['spentOn'] as String,
      notes: payload['notes'] as String? ?? '',
    );
    _showMessage('Expense updated');
    await _refresh();
  }

  Future<void> _confirmDeleteExpense(FinanceEntry expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete expense?'),
        content: Text(
          'Delete "${expense.title}" for \$${expense.amount.toStringAsFixed(2)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await _client.deleteExpense(expense.id);
    _showMessage('Expense deleted');
    await _refresh();
  }

  Future<void> _openActionSheet(_HomeData data) async {
    final navigator = Navigator.of(context);
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: const Text('Add expense'),
              onTap: () => Navigator.pop(context, 'expense'),
            ),
            ListTile(
              leading: const Icon(Icons.add_card),
              title: const Text('Add income'),
              onTap: () => Navigator.pop(context, 'income'),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Add budget'),
              onTap: () => Navigator.pop(context, 'budget'),
            ),
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('Add category'),
              onTap: () => Navigator.pop(context, 'category'),
            ),
          ],
        ),
      ),
    );

    if (!mounted || action == null) {
      return;
    }

    if (action == 'expense') {
      final categories = data.dashboard.categories
          .where(
            (category) => category.kind == 'expense' || category.kind == 'both',
          )
          .toList();
      final payload = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (_) => AddEntryScreen(
            title: 'Add Expense',
            categories: categories,
            dateLabel: 'Spent on',
            dateKey: 'spentOn',
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      if (payload != null) {
        await _client.createExpense(
          title: payload['title'] as String,
          amount: payload['amount'] as double,
          categoryId: payload['categoryId'] as int,
          spentOn: payload['spentOn'] as String,
          notes: payload['notes'] as String? ?? '',
        );
        _showMessage('Expense added');
        await _refresh();
      }
    }

    if (action == 'income') {
      final categories = data.dashboard.categories
          .where(
            (category) => category.kind == 'income' || category.kind == 'both',
          )
          .toList();
      final payload = await navigator.push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (_) => AddEntryScreen(
            title: 'Add Income',
            categories: categories,
            dateLabel: 'Received on',
            dateKey: 'receivedOn',
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      if (payload != null) {
        await _client.createIncome(
          title: payload['title'] as String,
          amount: payload['amount'] as double,
          categoryId: payload['categoryId'] as int,
          receivedOn: payload['receivedOn'] as String,
          notes: payload['notes'] as String? ?? '',
        );
        _showMessage('Income added');
        await _refresh();
      }
    }

    if (action == 'budget') {
      final categories = data.dashboard.categories
          .where(
            (category) => category.kind == 'expense' || category.kind == 'both',
          )
          .toList();
      final payload = await navigator.push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (_) => AddBudgetScreen(categories: categories),
        ),
      );

      if (!mounted) {
        return;
      }

      if (payload != null) {
        await _client.createBudget(
          name: payload['name'] as String,
          amount: payload['amount'] as double,
          period: payload['period'] as String,
          startDate: payload['startDate'] as String,
          categoryId: payload['categoryId'] as int?,
          notes: payload['notes'] as String? ?? '',
        );
        _showMessage('Budget added');
        await _refresh();
      }
    }

    if (action == 'category') {
      final payload = await navigator.push<Map<String, dynamic>>(
        MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
      );

      if (!mounted) {
        return;
      }

      if (payload != null) {
        await _client.createCategory(
          name: payload['name'] as String,
          kind: payload['kind'] as String,
          color: payload['color'] as String,
          icon: payload['icon'] as String,
        );
        _showMessage('Category added');
        await _refresh();
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Finance Mobile'),
            Text(
              widget.session.user.email,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
          IconButton(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
          ),
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
                      'Could not load finance data',
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
          final dashboard = data.dashboard;
          final summary = dashboard.summary;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _BalanceCard(summary: summary),
                const SizedBox(height: 16),
                _McpBanner(toolCount: data.tools.length),
                const SizedBox(height: 16),
                _SectionTitle(
                  title: 'Budgets',
                  subtitle: '${dashboard.budgets.length} total',
                ),
                const SizedBox(height: 8),
                if (dashboard.budgets.isEmpty)
                  const _EmptyCard(message: 'No budgets set yet.')
                else
                  ...dashboard.budgets.map(_BudgetTile.new),
                const SizedBox(height: 16),
                _SectionTitle(
                  title: 'Categories',
                  subtitle: '${dashboard.categories.length} total',
                ),
                const SizedBox(height: 8),
                if (dashboard.categories.isEmpty)
                  const _EmptyCard(message: 'No categories found.')
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: dashboard.categories
                        .map(
                          (category) => Chip(
                            label: Text('${category.name} • ${category.kind}'),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 16),
                _SectionTitle(
                  title: 'Recent Income',
                  subtitle: '${dashboard.recentIncomes.length} items',
                ),
                const SizedBox(height: 8),
                if (dashboard.recentIncomes.isEmpty)
                  const _EmptyCard(message: 'No income records found.')
                else
                  ...dashboard.recentIncomes.map(
                    (item) => _EntryTile(item: item, isIncome: true),
                  ),
                const SizedBox(height: 16),
                _SectionTitle(
                  title: 'Recent Expenses',
                  subtitle: '${dashboard.recentExpenses.length} items',
                ),
                const SizedBox(height: 8),
                if (dashboard.recentExpenses.isEmpty)
                  const _EmptyCard(message: 'No expense records found.')
                else
                  ...dashboard.recentExpenses.map(
                    (item) => _EntryTile(
                      item: item,
                      isIncome: false,
                      onTap: () => _openExpenseActions(data, item),
                    ),
                  ),
                const SizedBox(height: 16),
                _SectionTitle(
                  title: 'Spending by Category',
                  subtitle: summary.month,
                ),
                const SizedBox(height: 8),
                if (summary.expenseByCategory.isEmpty)
                  const _EmptyCard(message: 'No category spending yet.')
                else
                  ...summary.expenseByCategory.map(_CategorySpendTile.new),
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
                ? () => _openActionSheet(snapshot.data!)
                : null,
            icon: const Icon(Icons.add),
            label: const Text('Add'),
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
  const _HomeData({required this.dashboard, required this.tools});

  final FinanceDashboard dashboard;
  final List<McpTool> tools;
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.summary});

  final PeriodSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF155E75)],
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
          const SizedBox(height: 12),
          Text(
            'Balance \$${summary.balance.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Income \$${summary.incomeTotal.toStringAsFixed(2)} • Expenses \$${summary.expenseTotal.toStringAsFixed(2)}',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _McpBanner extends StatelessWidget {
  const _McpBanner({required this.toolCount});

  final int toolCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFDFF7F4),
            child: Icon(Icons.hub_outlined, color: Color(0xFF0F766E)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$toolCount MCP tools available for finance automation',
            ),
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

class _BudgetTile extends StatelessWidget {
  const _BudgetTile(this.budget);

  final BudgetItem budget;

  @override
  Widget build(BuildContext context) {
    final progress = budget.amount == 0
        ? 0.0
        : (budget.spent / budget.amount).clamp(0, 1).toDouble();
    return Card(
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
                Text('\$${budget.remaining.toStringAsFixed(2)} left'),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${budget.period} • ${budget.categoryName ?? 'All categories'}',
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text(
              'Spent \$${budget.spent.toStringAsFixed(2)} of \$${budget.amount.toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.item, required this.isIncome, this.onTap});

  final FinanceEntry item;
  final bool isIncome;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: isIncome
              ? const Color(0xFFDCFCE7)
              : const Color(0xFFFEE2E2),
          child: Icon(
            isIncome ? Icons.south_west : Icons.north_east,
            color: isIncome ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
          ),
        ),
        title: Text(item.title),
        subtitle: Text('${item.categoryName} • ${item.date}'),
        trailing: Text(
          '${isIncome ? '+' : '-'}\$${item.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isIncome ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
          ),
        ),
      ),
    );
  }
}

class _CategorySpendTile extends StatelessWidget {
  const _CategorySpendTile(this.item);

  final CategorySpend item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.pie_chart_outline)),
        title: Text(item.category),
        trailing: Text('\$${item.total.toStringAsFixed(2)}'),
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
