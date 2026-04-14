import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/auth_session.dart';
import '../repository/finance_repository.dart';
import '../cubits/category_entries/category_entries_cubit.dart';
import '../cubits/category_entries/category_entries_state.dart';
import '../models/currency_option.dart';
import '../models/finance_models.dart';
import '../utils/currency_utils.dart';

class CategoryEntriesScreen extends StatefulWidget {
  const CategoryEntriesScreen({
    required this.session,
    required this.category,
    required this.currency,
    super.key,
  });

  final AuthSession session;
  final FinanceCategory category;
  final CurrencyOption currency;

  @override
  State<CategoryEntriesScreen> createState() => _CategoryEntriesScreenState();
}

class _CategoryEntriesScreenState extends State<CategoryEntriesScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  late final CategoryEntriesCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = CategoryEntriesCubit(
      repository: context.read<FinanceRepository>(),
      category: widget.category,
    );
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

  Future<void> _refresh() async {
    await _cubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;

    return BlocProvider.value(
      value: _cubit,
      child: Builder(
        builder: (context) {
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
            body: FutureBuilder<CategoryEntriesData>(
              future: context.watch<CategoryEntriesCubit>().state.future,
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
                        currency: widget.currency,
                        entries: data.expenses,
                        isIncome: false,
                        emptyMessage:
                            'No expense records in this category.',
                        onRefresh: _refresh,
                      ),
                      _CategoryEntryList(
                        currency: widget.currency,
                        entries: data.incomes,
                        isIncome: true,
                        emptyMessage:
                            'No income records in this category.',
                        onRefresh: _refresh,
                      ),
                    ],
                  );
                }

                return _CategoryEntryList(
                  currency: widget.currency,
                  entries: category.kind == 'income'
                      ? data.incomes
                      : data.expenses,
                  isIncome: category.kind == 'income',
                  emptyMessage: category.kind == 'income'
                      ? 'No income records in this category.'
                      : 'No expense records in this category.',
                  onRefresh: _refresh,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CategoryEntryList extends StatelessWidget {
  const _CategoryEntryList({
    required this.currency,
    required this.entries,
    required this.isIncome,
    required this.emptyMessage,
    required this.onRefresh,
  });

  final CurrencyOption currency;
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
                      formatSignedMoney(
                        currency,
                        item.amount,
                        isPositive: isIncome,
                      ),
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
