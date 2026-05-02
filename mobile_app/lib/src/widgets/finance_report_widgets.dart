import 'package:flutter/material.dart';

import '../models/currency_option.dart';
import '../models/finance_models.dart';
import '../utils/currency_utils.dart';

/// Section header used on Report and Settings screens.
class FinanceSectionTitle extends StatelessWidget {
  const FinanceSectionTitle({
    required this.title,
    required this.subtitle,
    super.key,
  });

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

class FinanceEmptyCard extends StatelessWidget {
  const FinanceEmptyCard({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(18), child: Text(message)),
    );
  }
}

class FinanceCategorySpendTile extends StatelessWidget {
  const FinanceCategorySpendTile({
    required this.category,
    required this.currency,
    required this.spend,
    this.onTap,
    super.key,
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

class FinanceBudgetTile extends StatelessWidget {
  const FinanceBudgetTile({
    required this.budget,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
    super.key,
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
