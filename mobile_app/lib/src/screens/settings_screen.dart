import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/finance_mcp_client.dart';
import '../database/chat_database.dart';
import '../database/finance_database_holder.dart';
import '../cubits/settings/settings_cubit.dart';
import '../cubits/settings/settings_state.dart';
import '../cubits/shell/shell_cubit.dart';
import '../cubits/shell/shell_state.dart';
import '../models/auth_session.dart';
import '../repository/finance_repository.dart';
import '../models/currency_option.dart';
import '../models/finance_models.dart';
import '../utils/currency_utils.dart';
import '../utils/finance_repository_scope.dart';
import '../utils/toast.dart';
import 'accounts_screen.dart';
import 'add_budget_screen.dart';
import 'add_category_screen.dart';
import 'category_entries_screen.dart';
import 'chat_db_viewer_screen.dart';
import 'local_database_viewer_screen.dart';
import 'period_expenses_screen.dart';
import 'transfer_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.session,
    required this.currency,
    required this.onCurrencyChanged,
    required this.onLogout,
    required this.onOpenProfile,
    super.key,
  });

  final AuthSession session;
  final CurrencyOption currency;
  final Future<void> Function(CurrencyOption currency) onCurrencyChanged;
  final Future<void> Function() onLogout;
  final Future<void> Function() onOpenProfile;

  Future<void> _openCategoryEntries(
    BuildContext context,
    FinanceCategory category,
  ) async {
    await pushRouteWithFinanceRepository<void>(
      context,
      CategoryEntriesScreen(
        session: session,
        category: category,
        currency: currency,
      ),
    );
  }

  Future<void> _openChatDbViewer(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ChatDbViewerScreen()));
  }

  Future<void> _openAccounts(BuildContext context) async {
    final cubit = context.read<SettingsCubit>();
    await pushRouteWithFinanceRepository<void>(
      context,
      AccountsScreen(
        session: session,
        currency: currency,
      ),
    );
    await cubit.refresh();
  }

  Future<void> _openTransfers(BuildContext context) async {
    final cubit = context.read<SettingsCubit>();
    await pushRouteWithFinanceRepository<void>(
      context,
      TransferScreen(
        session: session,
        currency: currency,
      ),
    );
    await cubit.refresh();
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'Logging out will permanently delete all finance records and chat '
          'history stored in the local database on this device. '
          'Your account on the server is not removed; you can sign in again to '
          'download your data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete local data & log out'),
          ),
        ],
      ),
    );

    if (!context.mounted || confirmed != true) {
      return;
    }

    try {
      await FinanceDatabaseHolder.instance.deleteAllLocalData();
      await ChatDatabase().deleteAllData();
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context, 'Could not clear local data: $e');
      }
      return;
    }

    if (!context.mounted) {
      return;
    }
    await onLogout();
  }

  Future<void> _importAllData(BuildContext context) async {
    final cubit = context.read<SettingsCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import all data'),
        content: const Text(
          'This will download your finance data from the server and replace matching rows in the local database. '
          'A network connection is required. Background sync may also run periodically to upload unsynced changes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (!context.mounted || confirmed != true) {
      return;
    }

    await cubit.importAllFromServer();
  }

  Future<void> _openLocalDatabaseViewer(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const LocalDatabaseViewerScreen(),
      ),
    );
  }

  Future<void> _openPeriodExpenses(BuildContext context) async {
    await pushRouteWithFinanceRepository<void>(
      context,
      PeriodExpensesScreen(currency: currency),
    );
  }

  Future<void> _selectCurrency(BuildContext context) async {
    final selected = await showModalBottomSheet<CurrencyOption>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: currencyOptions
              .map(
                (option) => ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      option.symbol,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  title: Text(option.label),
                  subtitle: Text('${option.code} • ${option.symbol}'),
                  trailing: option.code == currency.code
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.pop(context, option),
                ),
              )
              .toList(),
        ),
      ),
    );

    if (!context.mounted || selected == null || selected.code == currency.code) {
      return;
    }

    await onCurrencyChanged(selected);
    if (!context.mounted) {
      return;
    }

    _showMessage(context, '${selected.currency} selected');
  }

  Future<void> _editCategory(
    BuildContext context,
    FinanceCategory category,
  ) async {
    final cubit = context.read<SettingsCubit>();
    final payload = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => AddCategoryScreen(category: category)),
    );

    if (!context.mounted || payload == null) {
      return;
    }

    await cubit.updateCategory(
      uuid: payload['uuid'] as String,
      name: payload['name'] as String,
      kind: payload['kind'] as String,
      color: payload['color'] as String,
      icon: payload['icon'] as String,
    );
  }

  Future<void> _deleteCategory(
    BuildContext context,
    FinanceCategory category,
  ) async {
    final cubit = context.read<SettingsCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
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

    await cubit.deleteCategoryByUuid(category.uuid);
  }

  Future<void> _editBudget(
    BuildContext context,
    BudgetItem budget,
    SettingsData data,
  ) async {
    final cubit = context.read<SettingsCubit>();
    final categories = data.dashboard.categories
        .where(
          (category) => category.kind == 'expense' || category.kind == 'both',
        )
        .toList();
    final payload = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => AddBudgetScreen(categories: categories, budget: budget),
      ),
    );

    if (!context.mounted || payload == null) {
      return;
    }

    await cubit.updateBudget(
      uuid: payload['uuid'] as String,
      name: payload['name'] as String,
      amount: payload['amount'] as double,
      period: payload['period'] as String,
      startDate: payload['startDate'] as String,
      categoryUuid: payload['categoryUuid'] as String?,
      notes: payload['notes'] as String? ?? '',
    );
  }

  Future<void> _deleteBudget(BuildContext context, BudgetItem budget) async {
    final cubit = context.read<SettingsCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text('Are you sure you want to delete "${budget.name}"?'),
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

    await cubit.deleteBudgetByUuid(budget.uuid);
  }

  Future<void> _openActionSheet(
    BuildContext context,
    SettingsData data,
  ) async {
    final cubit = context.read<SettingsCubit>();
    final navigator = Navigator.of(context);
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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

    if (!context.mounted || action == null) {
      return;
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

      if (!context.mounted) {
        return;
      }

      if (payload != null) {
        await cubit.createBudget(
          name: payload['name'] as String,
          amount: payload['amount'] as double,
          period: payload['period'] as String,
          startDate: payload['startDate'] as String,
          categoryUuid: payload['categoryUuid'] as String?,
          notes: payload['notes'] as String? ?? '',
        );
      }
    }

    if (action == 'category') {
      final payload = await navigator.push<Map<String, dynamic>>(
        MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
      );

      if (!context.mounted) {
        return;
      }

      if (payload != null) {
        await cubit.createCategory(
          name: payload['name'] as String,
          kind: payload['kind'] as String,
          color: payload['color'] as String,
          icon: payload['icon'] as String,
        );
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    AppToast.success(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final toolsClient = FinanceMcpClient(token: session.token);
    return BlocProvider(
      create: (_) => SettingsCubit(
        repository: context.read<FinanceRepository>(),
        toolsClient: toolsClient,
      ),
      child: BlocListener<ShellCubit, ShellState>(
        listenWhen: (prev, next) =>
            next.selectedIndex == 3 && prev.selectedIndex != next.selectedIndex,
        listener: (context, state) {
          context.read<SettingsCubit>().refresh();
        },
        child: Builder(
          builder: (blocContext) {
            return BlocListener<SettingsCubit, SettingsState>(
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
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Settings'),
                actions: [
                  IconButton(
                    onPressed: () =>
                        blocContext.read<SettingsCubit>().refresh(),
                    icon: const Icon(Icons.refresh),
                  ),
                  IconButton(
                    onPressed: () => _confirmLogout(blocContext),
                    icon: const Icon(Icons.logout),
                    tooltip: 'Log out',
                  ),
                ],
              ),
              body: FutureBuilder<SettingsData>(
                future: blocContext.watch<SettingsCubit>().state.future,
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
                    const Icon(Icons.settings_backup_restore, size: 52),
                    const SizedBox(height: 12),
                    Text(
                      'Could not load settings',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.read<SettingsCubit>().refresh(),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final dashboard = data.dashboard;
          final topExpenseCategories = dashboard.summary.expenseByCategory
              .take(5)
              .map(
                (item) => (
                  spend: item,
                  category: dashboard.categories.firstWhere(
                    (category) => category.name == item.category,
                    orElse: () => FinanceCategory(
                      id: -1,
                      uuid: '',
                      name: item.category,
                      kind: 'expense',
                      color: item.color,
                      icon: 'tag',
                    ),
                  ),
                ),
              )
              .toList();

          return RefreshIndicator(
            onRefresh: () => context.read<SettingsCubit>().refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.user.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          session.user.email,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.tonalIcon(
                          onPressed: onOpenProfile,
                          icon: const Icon(Icons.person_outline),
                          label: const Text('Open profile'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => _selectCurrency(context),
                          icon: const Icon(Icons.currency_exchange),
                          label: Text(
                            'Currency: ${currency.code} (${currency.symbol})',
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.cloud_download_outlined),
                          title: const Text('Import all data'),
                          subtitle: const Text(
                            'Loads accounts, categories, transactions, and budgets from the server into this device.',
                          ),
                          onTap: () {
                            _importAllData(context);
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.date_range_outlined),
                          title: const Text('View Expenses by Period'),
                          subtitle: const Text(
                            'Browse local expense rows by date range (works offline).',
                          ),
                          onTap: () {
                            _openPeriodExpenses(context);
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.table_rows),
                          title: const Text('View local database'),
                          subtitle: const Text(
                            'Inspect SQLite tables stored on device (debug).',
                          ),
                          onTap: () {
                            _openLocalDatabaseViewer(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _SectionTitle(
                  title: 'Automation',
                  subtitle: '${data.tools.length} MCP tools',
                ),
                const SizedBox(height: 8),
                _InfoCard(
                  icon: Icons.hub_outlined,
                  text:
                      '${data.tools.length} MCP tools available for finance automation',
                ),
                const SizedBox(height: 16),
                _SectionTitle(
                  title: 'Top Expense Categories',
                  subtitle: '${topExpenseCategories.length} items',
                ),
                const SizedBox(height: 8),
                if (topExpenseCategories.isEmpty)
                  const _EmptyCard(message: 'No category spending yet.')
                else
                  ...topExpenseCategories.map(
                    (item) => _CategoryTotalTile(
                      category: item.category,
                      currency: currency,
                      spend: item.spend,
                      onTap: item.category.id == -1
                          ? null
                          : () => _openCategoryEntries(context, item.category),
                    ),
                  ),
                const SizedBox(height: 16),
                _SectionTitle(
                  title: 'Budgets',
                  subtitle: '${dashboard.budgets.length} total',
                ),
                const SizedBox(height: 8),
                if (dashboard.budgets.isEmpty)
                  const _EmptyCard(message: 'No budgets set yet.')
                else
                  ...dashboard.budgets.map(
                    (budget) => _BudgetTile(
                      budget: budget,
                      currency: currency,
                      onEdit: () => _editBudget(context, budget, data),
                      onDelete: () => _deleteBudget(context, budget),
                    ),
                  ),
                const SizedBox(height: 16),
                _SectionTitle(
                  title: 'Accounts',
                  subtitle: '${dashboard.accounts.length} total',
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.account_balance_wallet_outlined,
                        ),
                        title: const Text('Manage Accounts'),
                        subtitle: const Text('Add, edit, or delete accounts'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openAccounts(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.swap_horiz),
                        title: const Text('Transfers'),
                        subtitle: const Text('Move money between accounts'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openTransfers(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionTitle(
                  title: 'Categories',
                  subtitle: '${dashboard.categories.length} total',
                ),
                const SizedBox(height: 8),
                if (dashboard.categories.isEmpty)
                  const _EmptyCard(message: 'No categories found.')
                else
                  ...dashboard.categories.map(
                    (category) => _CategoryTile(
                      category: category,
                      onEdit: () => _editCategory(context, category),
                      onDelete: () => _deleteCategory(context, category),
                    ),
                  ),
                if (kDebugMode) ...[
                  const SizedBox(height: 16),
                  _SectionTitle(title: 'Developer', subtitle: 'Debug tools'),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.storage_outlined),
                      title: const Text('Chat History DB'),
                      subtitle: const Text('View stored chat sessions'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openChatDbViewer(context),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Log out'),
                ),
              ],
            ),
          );
                },
              ),
              floatingActionButton: FutureBuilder<SettingsData>(
                future: blocContext.watch<SettingsCubit>().state.future,
                builder: (context, snapshot) {
                  return FloatingActionButton.extended(
                    heroTag: 'settings_fab',
                    onPressed: snapshot.hasData
                        ? () => _openActionSheet(context, snapshot.data!)
                        : null,
                    icon: const Icon(Icons.tune),
                    label: const Text('Manage'),
                  );
                },
              ),
            ),
          );
        },
        ),
      ),
    );
  }

  // Month selection is owned by SettingsCubit (same month format: YYYY-MM).
}

// _SettingsData moved to cubit layer as SettingsData.

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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFDFF7F4),
              child: Icon(icon, color: const Color(0xFF0F766E)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

class _BudgetTile extends StatelessWidget {
  const _BudgetTile({
    required this.budget,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });

  final BudgetItem budget;
  final CurrencyOption currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${formatMoney(currency, budget.remaining)} left',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: onEdit,
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: onDelete,
                      tooltip: 'Delete',
                    ),
                  ],
                ),
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
              'Spent ${formatMoney(currency, budget.spent)} of ${formatMoney(currency, budget.amount)}',
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTotalTile extends StatelessWidget {
  const _CategoryTotalTile({
    required this.category,
    required this.currency,
    required this.spend,
    this.onTap,
  });

  final FinanceCategory category;
  final CurrencyOption currency;
  final CategorySpend spend;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFDFF7F4),
          child: Text(
            category.name.isEmpty ? '?' : category.name[0].toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF0F766E),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text(spend.category),
        subtitle: Text(
          onTap == null
              ? 'Category details unavailable'
              : 'Tap to view entries',
        ),
        trailing: Text(
          formatMoney(currency, spend.total),
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

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final FinanceCategory category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color _parseColor(String hex) {
    final normalized = hex.replaceFirst('#', '');
    return Color(int.parse('FF$normalized', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _parseColor(category.color).withValues(alpha: 0.2),
          child: Icon(Icons.tag, color: _parseColor(category.color)),
        ),
        title: Text(category.name),
        subtitle: Text(category.kind),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}
