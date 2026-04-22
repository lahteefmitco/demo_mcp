import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/account_transactions/account_transactions_cubit.dart';
import '../cubits/account_transactions/account_transactions_state.dart';
import '../cubits/period_expenses/period_expenses_state.dart';
import '../models/currency_option.dart';
import '../models/finance_models.dart';
import '../repository/finance_repository.dart';
import '../utils/app_responsive.dart';
import '../utils/currency_utils.dart';

class AccountTransactionsScreen extends StatefulWidget {
  const AccountTransactionsScreen({
    required this.account,
    required this.currency,
    super.key,
  });

  final FinanceAccount account;
  final CurrencyOption currency;

  @override
  State<AccountTransactionsScreen> createState() =>
      _AccountTransactionsScreenState();
}

class _AccountTransactionsScreenState extends State<AccountTransactionsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _scheduleSearchApply() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) {
        return;
      }
      context.read<AccountTransactionsCubit>().setSearchQuery(_searchCtrl.text);
    });
  }

  String _formatDate(BuildContext context, DateTime d) {
    return MaterialLocalizations.of(context).formatFullDate(d);
  }

  Future<void> _pickDate(
    BuildContext context,
    AccountTransactionsCubit cubit, {
    required bool isFrom,
  }) async {
    final state = cubit.state;
    final initial = isFrom ? state.fromDate : state.toDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !context.mounted) {
      return;
    }
    if (isFrom) {
      cubit.setFromDate(picked);
    } else {
      cubit.setToDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<FinanceRepository>();
    return BlocProvider(
      create: (_) =>
          AccountTransactionsCubit(repository: repo, account: widget.account),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.account.name),
                  Text(
                    'Local transactions',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                  onPressed: () =>
                      context.read<AccountTransactionsCubit>().refresh(),
                ),
              ],
            ),
            body: ResponsiveContentWidth(
              child: BlocBuilder<AccountTransactionsCubit, AccountTransactionsState>(
                buildWhen: (p, n) =>
                    p.fromDate != n.fromDate ||
                    p.toDate != n.toDate ||
                    p.limit != n.limit ||
                    p.ledgerKind != n.ledgerKind ||
                    p.searchQuery != n.searchQuery ||
                    p.invalidRangeMessage != n.invalidRangeMessage ||
                    p.future != n.future,
                builder: (context, state) {
                  final cubit = context.read<AccountTransactionsCubit>();
                  final pad = AppResponsive.pagePadding(context);
                  final compact = AppResponsive.isCompactWidth(context);

                  return RefreshIndicator(
                    onRefresh: () async => cubit.refresh(),
                    child: ListView(
                      padding: pad,
                      children: [
                        Text(
                          'Offline-first: expenses and incomes stored on this device.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 12),
                        if (state.invalidRangeMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: Theme.of(
                                context,
                              ).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onErrorContainer,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        state.invalidRangeMessage!,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onErrorContainer,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            labelText: 'Search',
                            hintText: 'Title, category, notes, amount…',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchCtrl.text.isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(() {});
                                      _scheduleSearchApply();
                                    },
                                  ),
                          ),
                          textInputAction: TextInputAction.search,
                          onChanged: (_) {
                            setState(() {});
                            _scheduleSearchApply();
                          },
                          onSubmitted: (_) => _scheduleSearchApply(),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Type',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<AccountLedgerKind>(
                          segments: const [
                            ButtonSegment(
                              value: AccountLedgerKind.all,
                              label: Text('All'),
                            ),
                            ButtonSegment(
                              value: AccountLedgerKind.expense,
                              label: Text('Expense'),
                            ),
                            ButtonSegment(
                              value: AccountLedgerKind.income,
                              label: Text('Income'),
                            ),
                          ],
                          selected: {state.ledgerKind},
                          onSelectionChanged: (selection) {
                            if (selection.isNotEmpty) {
                              cubit.setLedgerKind(selection.first);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: compact
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _DateRow(
                                        label: 'From date',
                                        value: _formatDate(
                                          context,
                                          state.fromDate,
                                        ),
                                        onTap: () => _pickDate(
                                          context,
                                          cubit,
                                          isFrom: true,
                                        ),
                                      ),
                                      const Divider(height: 20),
                                      _DateRow(
                                        label: 'To date',
                                        value: _formatDate(
                                          context,
                                          state.toDate,
                                        ),
                                        onTap: () => _pickDate(
                                          context,
                                          cubit,
                                          isFrom: false,
                                        ),
                                      ),
                                      const Divider(height: 20),
                                      _LimitRow(
                                        value: state.limit,
                                        onChanged: cubit.setLimit,
                                      ),
                                    ],
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _DateRow(
                                          label: 'From date',
                                          value: _formatDate(
                                            context,
                                            state.fromDate,
                                          ),
                                          onTap: () => _pickDate(
                                            context,
                                            cubit,
                                            isFrom: true,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _DateRow(
                                          label: 'To date',
                                          value: _formatDate(
                                            context,
                                            state.toDate,
                                          ),
                                          onTap: () => _pickDate(
                                            context,
                                            cubit,
                                            isFrom: false,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _LimitRow(
                                          value: state.limit,
                                          onChanged: cubit.setLimit,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (state.invalidRangeMessage == null)
                          FutureBuilder<List<AccountLedgerItem>>(
                            future: state.future,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState !=
                                  ConnectionState.done) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 48),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              if (snapshot.hasError) {
                                return _ErrorCard(
                                  message: snapshot.error.toString(),
                                  onRetry: cubit.refresh,
                                );
                              }
                              final items = snapshot.data!;
                              final totalExpense = items
                                  .where((i) => i.isExpense)
                                  .fold<double>(
                                    0,
                                    (s, i) => s + i.entry.amount,
                                  );
                              final totalIncome = items
                                  .where((i) => !i.isExpense)
                                  .fold<double>(
                                    0,
                                    (s, i) => s + i.entry.amount,
                                  );
                              final limitNote =
                                  state.limit == PeriodExpenseRowLimit.all
                                  ? 'Newest first (all matching rows).'
                                  : 'Up to ${state.limit.label} newest matching rows.';

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF0F766E),
                                          Color(0xFF155E75),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${items.length} listed',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (state.searchQuery.isNotEmpty)
                                              Text(
                                                'Search: "${state.searchQuery}"',
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Expenses ${formatMoney(widget.currency, totalExpense)}',
                                          style: const TextStyle(
                                            color: Color(0xFFFCA5A5),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Income ${formatMoney(widget.currency, totalIncome)}',
                                          style: const TextStyle(
                                            color: Color(0xFF4ADE80),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          limitNote,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (items.isEmpty)
                                    const _EmptyCard(
                                      message:
                                          'No transactions in this range for '
                                          'this account in local data.',
                                    )
                                  else
                                    ...items.map(
                                      (i) => _LedgerTile(
                                        item: i,
                                        currency: widget.currency,
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LimitRow extends StatelessWidget {
  const _LimitRow({required this.value, required this.onChanged});

  final PeriodExpenseRowLimit value;
  final ValueChanged<PeriodExpenseRowLimit> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Row limit',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<PeriodExpenseRowLimit>(
          segments: PeriodExpenseRowLimit.values
              .map(
                (l) => ButtonSegment<PeriodExpenseRowLimit>(
                  value: l,
                  label: Text(l.label),
                ),
              )
              .toList(),
          selected: {value},
          onSelectionChanged: (selection) {
            if (selection.isNotEmpty) {
              onChanged(selection.first);
            }
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Smaller limits keep queries fast on large local databases.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LedgerTile extends StatelessWidget {
  const _LedgerTile({required this.item, required this.currency});

  final AccountLedgerItem item;
  final CurrencyOption currency;

  Color _parseColor(String hex) {
    final normalized = hex.replaceFirst('#', '');
    return Color(int.parse('FF$normalized', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final e = item.entry;
    final color = _parseColor(e.categoryColor);
    final isExpense = item.isExpense;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(
            isExpense ? Icons.south_west : Icons.north_east,
            color: color,
          ),
        ),
        title: Text(e.title),
        subtitle: Text(
          '${isExpense ? 'Expense' : 'Income'} • ${e.categoryName} • ${e.date}'
          '${e.notes.isNotEmpty ? '\n${e.notes}' : ''}',
        ),
        isThreeLine: e.notes.isNotEmpty,
        trailing: Text(
          '${isExpense ? '−' : '+'}${formatMoney(currency, e.amount)}',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isExpense
                ? Theme.of(context).colorScheme.error
                : const Color(0xFF15803D),
          ),
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
        child: Center(child: Text(message, textAlign: TextAlign.center)),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
