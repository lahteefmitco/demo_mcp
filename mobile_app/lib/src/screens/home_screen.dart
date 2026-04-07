import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../repository/finance_repository.dart';
import '../models/currency_option.dart';
import '../models/finance_models.dart';
import 'add_entry_screen.dart';
import '../utils/currency_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.session,
    required this.repository,
    required this.currency,
    required this.onOpenProfile,
    super.key,
  });

  final AuthSession session;
  final FinanceRepository repository;
  final CurrencyOption currency;
  final Future<void> Function() onOpenProfile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late Future<FinanceDashboard> _future;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _future = _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<FinanceDashboard> _load() async {
    return widget.repository.fetchDashboard(_currentMonth());
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  Future<void> _openExpenseActions(
    FinanceDashboard dashboard,
    FinanceEntry expense,
  ) async {
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
      await _editExpense(dashboard, expense);
    }

    if (action == 'delete') {
      await _confirmDeleteExpense(expense);
    }
  }

  Future<void> _editExpense(
    FinanceDashboard dashboard,
    FinanceEntry expense,
  ) async {
    final categories = dashboard.categories
        .where(
          (category) => category.kind == 'expense' || category.kind == 'both',
        )
        .toList();
    final payload = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => AddEntryScreen(
          title: 'Edit Expense',
          categories: categories,
          accounts: dashboard.accounts,
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

    await widget.repository.updateExpense(
      uuid: expense.uuid,
      title: payload['title'] as String,
      amount: payload['amount'] as double,
      categoryUuid: payload['categoryUuid'] as String,
      accountUuid: payload['accountUuid'] as String,
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
          'Delete "${expense.title}" for ${formatMoney(widget.currency, expense.amount)}?',
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

    await widget.repository.deleteExpenseByUuid(expense.uuid);
    _showMessage('Expense deleted');
    await _refresh();
  }

  Future<void> _openIncomeActions(
    FinanceDashboard dashboard,
    FinanceEntry income,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit income'),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete income'),
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
      await _editIncome(dashboard, income);
    }

    if (action == 'delete') {
      await _confirmDeleteIncome(income);
    }
  }

  Future<void> _editIncome(
    FinanceDashboard dashboard,
    FinanceEntry income,
  ) async {
    final categories = dashboard.categories
        .where(
          (category) => category.kind == 'income' || category.kind == 'both',
        )
        .toList();
    final payload = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => AddEntryScreen(
          title: 'Edit Income',
          categories: categories,
          accounts: dashboard.accounts,
          dateLabel: 'Received on',
          dateKey: 'receivedOn',
          initialEntry: income,
          saveLabel: 'Update',
        ),
      ),
    );

    if (!mounted || payload == null) {
      return;
    }

    await widget.repository.updateIncome(
      uuid: income.uuid,
      title: payload['title'] as String,
      amount: payload['amount'] as double,
      categoryUuid: payload['categoryUuid'] as String,
      accountUuid: payload['accountUuid'] as String,
      receivedOn: payload['receivedOn'] as String,
      notes: payload['notes'] as String? ?? '',
    );
    _showMessage('Income updated');
    await _refresh();
  }

  Future<void> _confirmDeleteIncome(FinanceEntry income) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete income?'),
        content: Text(
          'Delete "${income.title}" for ${formatMoney(widget.currency, income.amount)}?',
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

    await widget.repository.deleteIncomeByUuid(income.uuid);
    _showMessage('Income deleted');
    await _refresh();
  }

  Future<void> _openActionSheet(FinanceDashboard dashboard) async {
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
          ],
        ),
      ),
    );

    if (!mounted || action == null) {
      return;
    }

    if (action == 'expense') {
      final categories = dashboard.categories
          .where(
            (category) => category.kind == 'expense' || category.kind == 'both',
          )
          .toList();
      final payload = await navigator.push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (_) => AddEntryScreen(
            title: 'Add Expense',
            categories: categories,
            accounts: dashboard.accounts,
            dateLabel: 'Spent on',
            dateKey: 'spentOn',
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      if (payload != null) {
        await widget.repository.createExpense(
          title: payload['title'] as String,
          amount: payload['amount'] as double,
          categoryUuid: payload['categoryUuid'] as String,
          accountUuid: payload['accountUuid'] as String,
          spentOn: payload['spentOn'] as String,
          notes: payload['notes'] as String? ?? '',
        );
        _showMessage('Expense added');
        await _refresh();
      }
    }

    if (action == 'income') {
      final categories = dashboard.categories
          .where(
            (category) => category.kind == 'income' || category.kind == 'both',
          )
          .toList();
      final payload = await navigator.push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (_) => AddEntryScreen(
            title: 'Add Income',
            categories: categories,
            accounts: dashboard.accounts,
            dateLabel: 'Received on',
            dateKey: 'receivedOn',
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      if (payload != null) {
        await widget.repository.createIncome(
          title: payload['title'] as String,
          amount: payload['amount'] as double,
          categoryUuid: payload['categoryUuid'] as String,
          accountUuid: payload['accountUuid'] as String,
          receivedOn: payload['receivedOn'] as String,
          notes: payload['notes'] as String? ?? '',
        );
        _showMessage('Income added');
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
            const Text('Gulfon Finance'),
            Text(
              widget.session.user.email,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: widget.onOpenProfile,
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
          ),
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

          final dashboard = snapshot.data!;
          final summary = dashboard.summary;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionTitle(
                  title: 'Recent Activity',
                  subtitle:
                      '${dashboard.recentExpenses.length + dashboard.recentIncomes.length} items',
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Expenses'),
                          Tab(text: 'Income'),
                        ],
                      ),
                      SizedBox(
                        height: 360,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _EntryList(
                              currency: widget.currency,
                              items: dashboard.recentExpenses,
                              isIncome: false,
                              emptyMessage: 'No expense records found.',
                              onTap: (item) =>
                                  _openExpenseActions(dashboard, item),
                            ),
                            _EntryList(
                              currency: widget.currency,
                              items: dashboard.recentIncomes,
                              isIncome: true,
                              emptyMessage: 'No income records found.',
                              onTap: (item) =>
                                  _openIncomeActions(dashboard, item),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                  ...summary.expenseByCategory.map(
                    (item) => _CategorySpendTile(
                      item: item,
                      currency: widget.currency,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FutureBuilder<FinanceDashboard>(
        future: _future,
        builder: (context, snapshot) {
          return FloatingActionButton.extended(
            heroTag: 'home_fab',
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

class _EntryList extends StatelessWidget {
  const _EntryList({
    required this.currency,
    required this.items,
    required this.isIncome,
    required this.emptyMessage,
    required this.onTap,
  });

  final CurrencyOption currency;
  final List<FinanceEntry> items;
  final bool isIncome;
  final String emptyMessage;
  final ValueChanged<FinanceEntry> onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: _EmptyCard(message: emptyMessage),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _EntryTile(
          currency: currency,
          item: item,
          isIncome: isIncome,
          onTap: () => onTap(item),
        );
      },
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.currency,
    required this.item,
    required this.isIncome,
    this.onTap,
  });

  final CurrencyOption currency;
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.categoryName} • ${item.date}'),
            Text(
              item.accountName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _parseColor(item.accountColor),
              ),
            ),
          ],
        ),
        trailing: Text(
          formatSignedMoney(currency, item.amount, isPositive: isIncome),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isIncome ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
          ),
        ),
      ),
    );
  }

  Color _parseColor(String colorStr) {
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF10B981);
    }
  }
}

class _CategorySpendTile extends StatelessWidget {
  const _CategorySpendTile({required this.item, required this.currency});

  final CategorySpend item;
  final CurrencyOption currency;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.pie_chart_outline)),
        title: Text(item.category),
        trailing: Text(formatMoney(currency, item.total)),
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
