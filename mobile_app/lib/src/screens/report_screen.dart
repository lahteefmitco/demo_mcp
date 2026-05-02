import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/finance_mcp_client.dart';
import '../cubits/settings/settings_cubit.dart';
import '../cubits/settings/settings_state.dart' show SettingsData, SettingsState;
import '../cubits/shell/shell_cubit.dart';
import '../cubits/shell/shell_state.dart';
import '../models/auth_session.dart';
import '../models/currency_option.dart';
import '../models/finance_models.dart';
import '../repository/finance_repository.dart';
import '../utils/finance_repository_scope.dart';
import '../utils/toast.dart';
import '../widgets/finance_report_widgets.dart';
import 'add_budget_screen.dart';
import 'add_category_screen.dart';
import 'category_entries_screen.dart';
import 'period_expenses_screen.dart';
import 'period_incomes_screen.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({
    required this.session,
    required this.currency,
    super.key,
  });

  final AuthSession session;
  final CurrencyOption currency;

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

  Future<void> _openPeriodExpenses(BuildContext context) async {
    await pushRouteWithFinanceRepository<void>(
      context,
      PeriodExpensesScreen(currency: currency),
    );
  }

  Future<void> _openPeriodIncomes(BuildContext context) async {
    await pushRouteWithFinanceRepository<void>(
      context,
      PeriodIncomesScreen(currency: currency),
    );
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

  Future<void> _openManageSheet(BuildContext context, SettingsData data) async {
    final cubit = context.read<SettingsCubit>();
    final navigator = Navigator.of(context);
    final repository = context.read<FinanceRepository>();
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
        MaterialPageRoute(
          builder: (_) => RepositoryProvider<FinanceRepository>.value(
            value: repository,
            child: AddCategoryScreen(repository: repository),
          ),
        ),
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
          parentId: payload['parentId'] as String?,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    log('Build ReportScreen');
    final toolsClient = FinanceMcpClient(token: session.token);
    return BlocProvider(
      create: (_) => SettingsCubit(
        repository: context.read<FinanceRepository>(),
        toolsClient: toolsClient,
      ),
      child: BlocListener<ShellCubit, ShellState>(
        listenWhen: (prev, next) =>
            next.selectedIndex == 2 && prev.selectedIndex != next.selectedIndex,
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
                  title: const Text('Report'),
                  actions: [
                    IconButton(
                      onPressed: () =>
                          blocContext.read<SettingsCubit>().refresh(),
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                body: FutureBuilder<SettingsData>(
                  future: blocContext.watch<SettingsCubit>().state.future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.assessment_outlined, size: 52),
                              const SizedBox(height: 12),
                              Text(
                                'Could not load reports',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                snapshot.error.toString(),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: () =>
                                    context.read<SettingsCubit>().refresh(),
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
                          FinanceSectionTitle(
                            title: 'Period reports',
                            subtitle: 'Local data',
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.date_range_outlined),
                                  title: const Text('View Expenses by Period'),
                                  subtitle: const Text(
                                    'Browse local expense rows by date range (works offline).',
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => _openPeriodExpenses(context),
                                ),
                                const Divider(height: 1),
                                ListTile(
                                  leading: const Icon(Icons.savings_outlined),
                                  title: const Text('View Incomes by Period'),
                                  subtitle: const Text(
                                    'Browse local income rows by date range (works offline).',
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => _openPeriodIncomes(context),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          FinanceSectionTitle(
                            title: 'Top Expense Categories',
                            subtitle: '${topExpenseCategories.length} items',
                          ),
                          const SizedBox(height: 8),
                          if (topExpenseCategories.isEmpty)
                            const FinanceEmptyCard(
                              message: 'No category spending yet.',
                            )
                          else
                            ...topExpenseCategories.map(
                              (item) => FinanceCategorySpendTile(
                                category: item.category,
                                currency: currency,
                                spend: item.spend,
                                onTap: item.category.id == -1
                                    ? null
                                    : () => _openCategoryEntries(
                                          context,
                                          item.category,
                                        ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          FinanceSectionTitle(
                            title: 'Budgets',
                            subtitle: '${dashboard.budgets.length} total',
                          ),
                          const SizedBox(height: 8),
                          if (dashboard.budgets.isEmpty)
                            const FinanceEmptyCard(message: 'No budgets set yet.')
                          else
                            ...dashboard.budgets.map(
                              (budget) => FinanceBudgetTile(
                                budget: budget,
                                currency: currency,
                                onEdit: () =>
                                    _editBudget(context, budget, data),
                                onDelete: () =>
                                    _deleteBudget(context, budget),
                              ),
                            ),
                          const SizedBox(height: 88),
                        ],
                      ),
                    );
                  },
                ),
                floatingActionButton: FutureBuilder<SettingsData>(
                  future: blocContext.watch<SettingsCubit>().state.future,
                  builder: (context, snapshot) {
                    return FloatingActionButton.extended(
                      heroTag: 'report_fab',
                      onPressed: snapshot.hasData
                          ? () => _openManageSheet(context, snapshot.data!)
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
}
