import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../api/finance_mcp_client.dart';
import '../models/auth_session.dart';
import '../repository/finance_repository.dart';
import '../models/currency_option.dart';
import '../models/finance_models.dart';
import '../models/mcp_tool.dart';
import '../utils/currency_utils.dart';
import 'accounts_screen.dart';
import 'add_budget_screen.dart';
import 'add_category_screen.dart';
import 'category_entries_screen.dart';
import 'chat_db_viewer_screen.dart';
import 'local_database_viewer_screen.dart';
import 'transfer_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    required this.session,
    required this.repository,
    required this.currency,
    required this.onCurrencyChanged,
    required this.onLogout,
    required this.onOpenProfile,
    super.key,
  });

  final AuthSession session;
  final FinanceRepository repository;
  final CurrencyOption currency;
  final Future<void> Function(CurrencyOption currency) onCurrencyChanged;
  final Future<void> Function() onLogout;
  final Future<void> Function() onOpenProfile;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final FinanceMcpClient _toolsClient;
  late Future<_SettingsData> _future;

  @override
  void initState() {
    super.initState();
    _toolsClient = FinanceMcpClient(token: widget.session.token);
    _future = _load();
  }

  Future<_SettingsData> _load() async {
    final month = _currentMonth();
    final results = await Future.wait([
      widget.repository.fetchDashboard(month),
      _toolsClient.listTools(),
    ]);

    return _SettingsData(
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

  Future<void> _openCategoryEntries(FinanceCategory category) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryEntriesScreen(
          session: widget.session,
          repository: widget.repository,
          category: category,
          currency: widget.currency,
        ),
      ),
    );
  }

  Future<void> _openChatDbViewer() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ChatDbViewerScreen()));
  }

  Future<void> _openAccounts() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            AccountsScreen(
              session: widget.session,
              repository: widget.repository,
              currency: widget.currency,
            ),
      ),
    );
    await _refresh();
  }

  Future<void> _openTransfers() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            TransferScreen(
              session: widget.session,
              repository: widget.repository,
              currency: widget.currency,
            ),
      ),
    );
    await _refresh();
  }

  Future<void> _importAllData() async {
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

    if (!mounted || confirmed != true) {
      return;
    }

    try {
      await widget.repository.importAllFromServer();
      if (!mounted) {
        return;
      }
      _showMessage('Import finished');
      await _refresh();
    } catch (e) {
      if (!mounted) {
        return;
      }
      _showMessage('Import failed: $e');
    }
  }

  Future<void> _openLocalDatabaseViewer() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const LocalDatabaseViewerScreen(),
      ),
    );
  }

  Future<void> _selectCurrency() async {
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
                  trailing: option.code == widget.currency.code
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.pop(context, option),
                ),
              )
              .toList(),
        ),
      ),
    );

    if (!mounted || selected == null || selected.code == widget.currency.code) {
      return;
    }

    await widget.onCurrencyChanged(selected);
    if (!mounted) {
      return;
    }

    _showMessage('${selected.currency} selected');
  }

  Future<void> _editCategory(FinanceCategory category) async {
    final payload = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => AddCategoryScreen(category: category)),
    );

    if (!mounted || payload == null) {
      return;
    }

    await widget.repository.updateCategory(
      uuid: payload['uuid'] as String,
      name: payload['name'] as String,
      kind: payload['kind'] as String,
      color: payload['color'] as String,
      icon: payload['icon'] as String,
    );
    _showMessage('Category updated');
    await _refresh();
  }

  Future<void> _deleteCategory(FinanceCategory category) async {
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

    if (!mounted || confirmed != true) {
      return;
    }

    await widget.repository.deleteCategoryByUuid(category.uuid);
    _showMessage('Category deleted');
    await _refresh();
  }

  Future<void> _editBudget(BudgetItem budget, _SettingsData data) async {
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

    if (!mounted || payload == null) {
      return;
    }

    await widget.repository.updateBudget(
      uuid: payload['uuid'] as String,
      name: payload['name'] as String,
      amount: payload['amount'] as double,
      period: payload['period'] as String,
      startDate: payload['startDate'] as String,
      categoryUuid: payload['categoryUuid'] as String?,
      notes: payload['notes'] as String? ?? '',
    );
    _showMessage('Budget updated');
    await _refresh();
  }

  Future<void> _deleteBudget(BudgetItem budget) async {
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

    if (!mounted || confirmed != true) {
      return;
    }

    await widget.repository.deleteBudgetByUuid(budget.uuid);
    _showMessage('Budget deleted');
    await _refresh();
  }

  Future<void> _openActionSheet(_SettingsData data) async {
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

    if (!mounted || action == null) {
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

      if (!mounted) {
        return;
      }

      if (payload != null) {
        await widget.repository.createBudget(
          name: payload['name'] as String,
          amount: payload['amount'] as double,
          period: payload['period'] as String,
          startDate: payload['startDate'] as String,
          categoryUuid: payload['categoryUuid'] as String?,
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
        await widget.repository.createCategory(
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
        title: const Text('Settings'),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<_SettingsData>(
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
            onRefresh: _refresh,
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
                          widget.session.user.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.session.user.email,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.tonalIcon(
                          onPressed: widget.onOpenProfile,
                          icon: const Icon(Icons.person_outline),
                          label: const Text('Open profile'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _selectCurrency,
                          icon: const Icon(Icons.currency_exchange),
                          label: Text(
                            'Currency: ${widget.currency.code} (${widget.currency.symbol})',
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
                          onTap: _importAllData,
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.table_rows),
                          title: const Text('View local database'),
                          subtitle: const Text(
                            'Inspect SQLite tables stored on device (debug).',
                          ),
                          onTap: _openLocalDatabaseViewer,
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
                      currency: widget.currency,
                      spend: item.spend,
                      onTap: item.category.id == -1
                          ? null
                          : () => _openCategoryEntries(item.category),
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
                      currency: widget.currency,
                      onEdit: () => _editBudget(budget, data),
                      onDelete: () => _deleteBudget(budget),
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
                        onTap: _openAccounts,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.swap_horiz),
                        title: const Text('Transfers'),
                        subtitle: const Text('Move money between accounts'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _openTransfers,
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
                      onEdit: () => _editCategory(category),
                      onDelete: () => _deleteCategory(category),
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
                      onTap: _openChatDbViewer,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: widget.onLogout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Log out'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FutureBuilder<_SettingsData>(
        future: _future,
        builder: (context, snapshot) {
          return FloatingActionButton.extended(
            heroTag: 'settings_fab',
            onPressed: snapshot.hasData
                ? () => _openActionSheet(snapshot.data!)
                : null,
            icon: const Icon(Icons.tune),
            label: const Text('Manage'),
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

class _SettingsData {
  const _SettingsData({required this.dashboard, required this.tools});

  final FinanceDashboard dashboard;
  final List<McpTool> tools;
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
