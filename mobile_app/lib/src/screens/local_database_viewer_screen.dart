import 'package:flutter/material.dart';

import '../database/finance_database_holder.dart';

/// Debug screen listing all rows in the local Drift finance database.
class LocalDatabaseViewerScreen extends StatelessWidget {
  const LocalDatabaseViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Local database')),
      body: FutureBuilder<Map<String, String>>(
        future: _loadSnapshot(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: data.entries
                .map(
                  (e) => Card(
                    child: ExpansionTile(
                      title: Text(e.key),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: SelectableText(
                            e.value.isEmpty ? '(empty)' : e.value,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }

  static Future<Map<String, String>> _loadSnapshot() async {
    final db = FinanceDatabaseHolder.instance;
    final accounts = await db.select(db.localAccounts).get();
    final categories = await db.select(db.localCategories).get();
    final expenses = await db.select(db.localExpenses).get();
    final incomes = await db.select(db.localIncomes).get();
    final transfers = await db.select(db.localTransfers).get();
    final budgets = await db.select(db.localBudgets).get();

    return {
      'accounts (${accounts.length})': accounts.map((r) => r.toString()).join('\n'),
      'categories (${categories.length})':
          categories.map((r) => r.toString()).join('\n'),
      'expenses (${expenses.length})': expenses.map((r) => r.toString()).join('\n'),
      'incomes (${incomes.length})': incomes.map((r) => r.toString()).join('\n'),
      'transfers (${transfers.length})':
          transfers.map((r) => r.toString()).join('\n'),
      'budgets (${budgets.length})': budgets.map((r) => r.toString()).join('\n'),
    };
  }
}
