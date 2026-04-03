import 'package:flutter/material.dart';

import '../api/finance_mcp_client.dart';
import '../models/auth_session.dart';
import '../models/finance_models.dart';
import '../models/mcp_tool.dart';
import 'add_budget_screen.dart';
import 'add_category_screen.dart';
import 'category_entries_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    required this.session,
    required this.onLogout,
    required this.onOpenProfile,
    super.key,
  });

  final AuthSession session;
  final Future<void> Function() onLogout;
  final Future<void> Function() onOpenProfile;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final FinanceMcpClient _client;
  late Future<_SettingsData> _future;

  @override
  void initState() {
    super.initState();
    _client = FinanceMcpClient(token: widget.session.token);
    _future = _load();
  }

  Future<_SettingsData> _load() async {
    final month = _currentMonth();
    final results = await Future.wait([
      _client.fetchDashboard(month),
      _client.listTools(),
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
        builder: (_) =>
            CategoryEntriesScreen(session: widget.session, category: category),
      ),
    );
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

class _CategoryTotalTile extends StatelessWidget {
  const _CategoryTotalTile({
    required this.category,
    required this.spend,
    this.onTap,
  });

  final FinanceCategory category;
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
          '\$${spend.total.toStringAsFixed(2)}',
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
