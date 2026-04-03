import 'package:flutter/material.dart';

import '../api/finance_mcp_client.dart';
import '../models/auth_session.dart';
import '../models/finance_models.dart';

class CategoryEntriesScreen extends StatefulWidget {
  const CategoryEntriesScreen({
    required this.session,
    required this.category,
    super.key,
  });

  final AuthSession session;
  final FinanceCategory category;

  @override
  State<CategoryEntriesScreen> createState() => _CategoryEntriesScreenState();
}

class _CategoryEntriesScreenState extends State<CategoryEntriesScreen>
    with SingleTickerProviderStateMixin {
  late final FinanceMcpClient _client;
  late Future<_CategoryEntriesData> _future;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _client = FinanceMcpClient(token: widget.session.token);
    _future = _load();
    if (_showsBothTabs) {
      _tabController = TabController(length: 2, vsync: this);
    }
  }

  bool get _showsBothTabs => widget.category.kind == 'both';

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<_CategoryEntriesData> _load() async {
    final futures = <Future<dynamic>>[];

    if (widget.category.kind == 'expense' || widget.category.kind == 'both') {
      futures.add(_client.listExpenses(categoryId: widget.category.id));
    }

    if (widget.category.kind == 'income' || widget.category.kind == 'both') {
      futures.add(_client.listIncomes(categoryId: widget.category.id));
    }

    final results = await Future.wait(futures);
    var resultIndex = 0;

    List<FinanceEntry> expenses = const [];
    if (widget.category.kind == 'expense' || widget.category.kind == 'both') {
      expenses = results[resultIndex] as List<FinanceEntry>;
      resultIndex += 1;
    }

    List<FinanceEntry> incomes = const [];
    if (widget.category.kind == 'income' || widget.category.kind == 'both') {
      incomes = results[resultIndex] as List<FinanceEntry>;
    }

    return _CategoryEntriesData(expenses: expenses, incomes: incomes);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        bottom: _showsBothTabs
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Expenses'),
                  Tab(text: 'Income'),
                ],
              )
            : null,
      ),
      body: FutureBuilder<_CategoryEntriesData>(
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
                    const Icon(Icons.receipt_long_outlined, size: 52),
                    const SizedBox(height: 12),
                    Text(
                      'Could not load category entries',
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

          if (_showsBothTabs) {
            return TabBarView(
              controller: _tabController,
              children: [
                _CategoryEntryList(
                  entries: data.expenses,
                  isIncome: false,
                  emptyMessage: 'No expense records in this category.',
                  onRefresh: _refresh,
                ),
                _CategoryEntryList(
                  entries: data.incomes,
                  isIncome: true,
                  emptyMessage: 'No income records in this category.',
                  onRefresh: _refresh,
                ),
              ],
            );
          }

          return _CategoryEntryList(
            entries: category.kind == 'income' ? data.incomes : data.expenses,
            isIncome: category.kind == 'income',
            emptyMessage: category.kind == 'income'
                ? 'No income records in this category.'
                : 'No expense records in this category.',
            onRefresh: _refresh,
          );
        },
      ),
    );
  }
}

class _CategoryEntriesData {
  const _CategoryEntriesData({required this.expenses, required this.incomes});

  final List<FinanceEntry> expenses;
  final List<FinanceEntry> incomes;
}

class _CategoryEntryList extends StatelessWidget {
  const _CategoryEntryList({
    required this.entries,
    required this.isIncome,
    required this.emptyMessage,
    required this.onRefresh,
  });

  final List<FinanceEntry> entries;
  final bool isIncome;
  final String emptyMessage;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: entries.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [_EmptyCard(message: emptyMessage)],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final item = entries[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isIncome
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEE2E2),
                      child: Icon(
                        isIncome ? Icons.south_west : Icons.north_east,
                        color: isIncome
                            ? const Color(0xFF15803D)
                            : const Color(0xFFB91C1C),
                      ),
                    ),
                    title: Text(item.title),
                    subtitle: Text(item.date),
                    trailing: Text(
                      '${isIncome ? '+' : '-'}\$${item.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isIncome
                            ? const Color(0xFF15803D)
                            : const Color(0xFFB91C1C),
                      ),
                    ),
                  ),
                );
              },
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
