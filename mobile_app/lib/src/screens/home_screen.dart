import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/auth_session.dart';
import '../repository/finance_repository.dart';
import '../cubits/shell/shell_cubit.dart';
import '../cubits/shell/shell_state.dart';
import '../cubits/home/home_cubit.dart';
import '../cubits/home/home_state.dart';
import '../models/currency_option.dart';
import '../models/finance_models.dart';
import 'add_entry_screen.dart' show AddEntryScreen, readLastSelectedAccountUuidIfValid;
import '../utils/currency_utils.dart';
import '../utils/toast.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.session,
    required this.currency,
    required this.onOpenProfile,
    super.key,
  });

  final AuthSession session;
  final CurrencyOption currency;
  final Future<void> Function() onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final month = _currentMonth();
    final repository = context.read<FinanceRepository>();

    return BlocProvider(
      create: (_) => HomeCubit(repository: repository)..load(month),
      child: BlocListener<ShellCubit, ShellState>(
        listenWhen: (prev, next) =>
            next.selectedIndex == 0 && prev.selectedIndex != next.selectedIndex,
        listener: (context, state) {
          context.read<HomeCubit>().refresh(month);
        },
        child: BlocConsumer<HomeCubit, HomeState>(
        listenWhen: (p, n) => p.toastNonce != n.toastNonce,
        listener: (context, state) {
          final msg = state.toastMessage;
          if (msg == null || msg.isEmpty) return;
          if (state.toastIsError) {
            AppToast.error(context, msg);
          } else {
            AppToast.success(context, msg);
          }
        },
        buildWhen: (p, n) =>
            p.isLoading != n.isLoading ||
            p.dashboard != n.dashboard ||
            p.errorMessage != n.errorMessage,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Gulfon Finance'),
                  Text(
                    session.user.email,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: onOpenProfile,
                  icon: const Icon(Icons.person_outline),
                  tooltip: 'Profile',
                ),
                IconButton(
                  onPressed: () => context.read<HomeCubit>().refresh(month),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            body: _HomeBody(
              month: month,
              currency: currency,
              state: state,
              onExpenseTap: (dash, item) =>
                  _openExpenseActions(context, dash, item, month),
              onIncomeTap: (dash, item) =>
                  _openIncomeActions(context, dash, item, month),
              onAddPressed: (dash) => _openActionSheet(context, dash, month),
            ),
            floatingActionButton: state.dashboard == null
                ? null
                : FloatingActionButton.extended(
                    heroTag: 'home_fab',
                    onPressed: () => _openActionSheet(
                      context,
                      state.dashboard!,
                      month,
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
          );
        },
      ),
      ),
    );
  }

  Future<void> _openExpenseActions(
    BuildContext context,
    FinanceDashboard dashboard,
    FinanceEntry expense,
    String month,
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

    if (!context.mounted || action == null) {
      return;
    }

    if (action == 'edit') {
      await _editExpense(context, dashboard, expense, month);
    }

    if (action == 'delete') {
      if (!context.mounted) {
        return;
      }
      await _confirmDeleteExpense(context, expense, month);
    }
  }

  Future<void> _editExpense(
    BuildContext context,
    FinanceDashboard dashboard,
    FinanceEntry expense,
    String month,
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

    if (!context.mounted || payload == null) {
      return;
    }

    await context.read<HomeCubit>().updateExpense(
          uuid: expense.uuid,
          title: payload['title'] as String,
          amount: payload['amount'] as double,
          categoryUuid: payload['categoryUuid'] as String,
          accountUuid: payload['accountUuid'] as String,
          spentOn: payload['spentOn'] as String,
          notes: payload['notes'] as String? ?? '',
          monthYyyyMm: month,
        );
  }

  Future<void> _confirmDeleteExpense(
    BuildContext context,
    FinanceEntry expense,
    String month,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete expense?'),
        content: Text(
          'Delete "${expense.title}" for ${formatMoney(currency, expense.amount)}?',
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

    if (!context.mounted || confirmed != true) {
      return;
    }

    await context.read<HomeCubit>().deleteExpense(
          uuid: expense.uuid,
          monthYyyyMm: month,
        );
  }

  Future<void> _openIncomeActions(
    BuildContext context,
    FinanceDashboard dashboard,
    FinanceEntry income,
    String month,
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

    if (!context.mounted || action == null) {
      return;
    }

    if (action == 'edit') {
      await _editIncome(context, dashboard, income, month);
    }

    if (action == 'delete') {
      if (!context.mounted) {
        return;
      }
      await _confirmDeleteIncome(context, income, month);
    }
  }

  Future<void> _editIncome(
    BuildContext context,
    FinanceDashboard dashboard,
    FinanceEntry income,
    String month,
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

    if (!context.mounted || payload == null) {
      return;
    }

    await context.read<HomeCubit>().updateIncome(
          uuid: income.uuid,
          title: payload['title'] as String,
          amount: payload['amount'] as double,
          categoryUuid: payload['categoryUuid'] as String,
          accountUuid: payload['accountUuid'] as String,
          receivedOn: payload['receivedOn'] as String,
          notes: payload['notes'] as String? ?? '',
          monthYyyyMm: month,
        );
  }

  Future<void> _confirmDeleteIncome(
    BuildContext context,
    FinanceEntry income,
    String month,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete income?'),
        content: Text(
          'Delete "${income.title}" for ${formatMoney(currency, income.amount)}?',
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

    if (!context.mounted || confirmed != true) {
      return;
    }

    await context.read<HomeCubit>().deleteIncome(
          uuid: income.uuid,
          monthYyyyMm: month,
        );
  }

  Future<void> _openActionSheet(
    BuildContext context,
    FinanceDashboard dashboard,
    String month,
  ) async {
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

    if (!context.mounted || action == null) {
      return;
    }

    if (action == 'expense') {
      final categories = dashboard.categories
          .where(
            (category) => category.kind == 'expense' || category.kind == 'both',
          )
          .toList();
      final initialAccountUuid =
          await readLastSelectedAccountUuidIfValid(dashboard.accounts);
      final payload = await navigator.push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (_) => AddEntryScreen(
            title: 'Add Expense',
            categories: categories,
            accounts: dashboard.accounts,
            dateLabel: 'Spent on',
            dateKey: 'spentOn',
            initialAccountUuid: initialAccountUuid,
          ),
        ),
      );

      if (!context.mounted) {
        return;
      }
      if (payload != null) {
        await context.read<HomeCubit>().createExpense(
              title: payload['title'] as String,
              amount: payload['amount'] as double,
              categoryUuid: payload['categoryUuid'] as String,
              accountUuid: payload['accountUuid'] as String,
              spentOn: payload['spentOn'] as String,
              notes: payload['notes'] as String? ?? '',
              monthYyyyMm: month,
            );
      }
    }

    if (action == 'income') {
      final categories = dashboard.categories
          .where(
            (category) => category.kind == 'income' || category.kind == 'both',
          )
          .toList();
      final initialAccountUuid =
          await readLastSelectedAccountUuidIfValid(dashboard.accounts);
      final payload = await navigator.push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (_) => AddEntryScreen(
            title: 'Add Income',
            categories: categories,
            accounts: dashboard.accounts,
            dateLabel: 'Received on',
            dateKey: 'receivedOn',
            initialAccountUuid: initialAccountUuid,
          ),
        ),
      );

      if (!context.mounted) {
        return;
      }
      if (payload != null) {
        await context.read<HomeCubit>().createIncome(
              title: payload['title'] as String,
              amount: payload['amount'] as double,
              categoryUuid: payload['categoryUuid'] as String,
              accountUuid: payload['accountUuid'] as String,
              receivedOn: payload['receivedOn'] as String,
              notes: payload['notes'] as String? ?? '',
              monthYyyyMm: month,
            );
      }
    }
  }

  String _currentMonth() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    return '${now.year}-$month';
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.month,
    required this.currency,
    required this.state,
    required this.onExpenseTap,
    required this.onIncomeTap,
    required this.onAddPressed,
  });

  final String month;
  final CurrencyOption currency;
  final HomeState state;
  final Future<void> Function(FinanceDashboard dashboard) onAddPressed;
  final Future<void> Function(FinanceDashboard dashboard, FinanceEntry entry)
      onExpenseTap;
  final Future<void> Function(FinanceDashboard dashboard, FinanceEntry entry)
      onIncomeTap;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
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
              Text(state.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.read<HomeCubit>().load(month),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final dashboard = state.dashboard!;
    final summary = dashboard.summary;

    return RefreshIndicator(
      onRefresh: () => context.read<HomeCubit>().refresh(month),
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
            child: _RecentTabs(
              currency: currency,
              expenses: dashboard.recentExpenses,
              incomes: dashboard.recentIncomes,
              onExpenseTap: (e) => onExpenseTap(dashboard, e),
              onIncomeTap: (i) => onIncomeTap(dashboard, i),
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
              (item) => _CategorySpendTile(item: item, currency: currency),
            ),
        ],
      ),
    );
  }
}

class _RecentTabs extends StatefulWidget {
  const _RecentTabs({
    required this.currency,
    required this.expenses,
    required this.incomes,
    required this.onExpenseTap,
    required this.onIncomeTap,
  });

  final CurrencyOption currency;
  final List<FinanceEntry> expenses;
  final List<FinanceEntry> incomes;
  final ValueChanged<FinanceEntry> onExpenseTap;
  final ValueChanged<FinanceEntry> onIncomeTap;

  @override
  State<_RecentTabs> createState() => _RecentTabsState();
}

class _RecentTabsState extends State<_RecentTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _controller,
          tabs: const [
            Tab(text: 'Expenses'),
            Tab(text: 'Income'),
          ],
        ),
        SizedBox(
          height: 360,
          child: TabBarView(
            controller: _controller,
            children: [
              _EntryList(
                currency: widget.currency,
                items: widget.expenses,
                isIncome: false,
                emptyMessage: 'No expense records found.',
                onTap: widget.onExpenseTap,
              ),
              _EntryList(
                currency: widget.currency,
                items: widget.incomes,
                isIncome: true,
                emptyMessage: 'No income records found.',
                onTap: widget.onIncomeTap,
              ),
            ],
          ),
        ),
      ],
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
