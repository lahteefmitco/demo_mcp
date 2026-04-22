import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/period_expenses/period_expenses_cubit.dart';
import '../cubits/period_expenses/period_expenses_state.dart';
import '../models/currency_option.dart';
import '../models/finance_models.dart';
import '../repository/finance_repository.dart';
import '../utils/app_responsive.dart';
import '../utils/currency_utils.dart';

class PeriodExpensesScreen extends StatelessWidget {
  const PeriodExpensesScreen({required this.currency, super.key});

  final CurrencyOption currency;

  String _formatDate(BuildContext context, DateTime d) {
    return MaterialLocalizations.of(context).formatFullDate(d);
  }

  Future<void> _pickDate(
    BuildContext context,
    PeriodExpensesCubit cubit, {
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
      create: (_) => PeriodExpensesCubit(repository: repo),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Expenses by period'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                  onPressed: () =>
                      context.read<PeriodExpensesCubit>().refresh(),
                ),
              ],
            ),
            body: ResponsiveContentWidth(
              child: BlocBuilder<PeriodExpensesCubit, PeriodExpensesState>(
                buildWhen: (p, n) =>
                    p.fromDate != n.fromDate ||
                    p.toDate != n.toDate ||
                    p.limit != n.limit ||
                    p.invalidRangeMessage != n.invalidRangeMessage ||
                    p.future != n.future,
                builder: (context, state) {
                  final cubit = context.read<PeriodExpensesCubit>();
                  final pad = AppResponsive.pagePadding(context);
                  final compact = AppResponsive.isCompactWidth(context);

                  return RefreshIndicator(
                    onRefresh: () async => cubit.refresh(),
                    child: ListView(
                      padding: pad,
                      children: [
                        Text(
                          'Data is read only from this device (offline-first).',
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
                          FutureBuilder<List<FinanceEntry>>(
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
                              final expenses = snapshot.data!;
                              final total = expenses.fold<double>(
                                0,
                                (s, e) => s + e.amount,
                              );
                              final limitNote =
                                  state.limit == PeriodExpenseRowLimit.all
                                  ? 'Newest first (all in range).'
                                  : 'Showing up to ${state.limit.label} newest in range.';

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
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Total (listed)',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                formatMoney(currency, total),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w700,
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
                                        CircleAvatar(
                                          backgroundColor: Colors.white
                                              .withValues(alpha: 0.2),
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
                                    const _EmptyCard(
                                      message:
                                          'No expenses in this range in local data.',
                                    )
                                  else
                                    ...expenses.map(
                                      (e) => _ExpenseTile(
                                        expense: e,
                                        currency: currency,
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
        subtitle: Text('${expense.categoryName} • ${expense.date}'),
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
