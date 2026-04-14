import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/add_transfer/add_transfer_cubit.dart';
import '../cubits/add_transfer/add_transfer_state.dart';
import '../models/auth_session.dart';
import '../repository/finance_repository.dart';
import '../cubits/transfers/transfers_cubit.dart';
import '../cubits/transfers/transfers_state.dart';
import '../models/currency_option.dart';
import '../models/finance_models.dart';
import '../utils/currency_utils.dart';
import '../utils/toast.dart';

class TransferScreen extends StatelessWidget {
  const TransferScreen({
    super.key,
    required this.session,
    required this.currency,
  });

  final AuthSession session;
  final CurrencyOption currency;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<FinanceRepository>();

    return BlocProvider(
      create: (_) => TransfersCubit(repository: repo),
      child: BlocListener<TransfersCubit, TransfersState>(
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
        child: Builder(
          builder: (blocContext) {
            return Scaffold(
              appBar: AppBar(title: const Text('Transfers')),
              body: FutureBuilder<List<FinanceAccount>>(
                future: blocContext.watch<TransfersCubit>().state.accountsFuture,
                builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 52),
                  const SizedBox(height: 12),
                  Text(snapshot.error.toString()),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.read<TransfersCubit>().refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final accounts = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () => context.read<TransfersCubit>().refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF10B981,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.swap_horiz,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Transfer Money',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Move funds between accounts',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: accounts.length >= 2
                                ? () => _openTransferDialog(context, accounts)
                                : null,
                            icon: const Icon(Icons.add),
                            label: const Text('New Transfer'),
                          ),
                        ),
                        if (accounts.length < 2)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'You need at least 2 accounts to transfer',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.orange),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Transfer History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<Transfer>>(
                  future: context.watch<TransfersCubit>().state.transfersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Error loading transfers: ${snapshot.error}',
                          ),
                        ),
                      );
                    }

                    final transfers = snapshot.data!;

                    if (transfers.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'No transfers yet',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: transfers
                          .map(
                            (transfer) => _TransferTile(
                              transfer: transfer,
                              currency: currency,
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<void> _openTransferDialog(
  BuildContext context,
  List<FinanceAccount> accounts,
) async {
  final payload = await Navigator.of(context).push<Map<String, dynamic>>(
    MaterialPageRoute(builder: (_) => AddTransferScreen(accounts: accounts)),
  );
  if (!context.mounted || payload == null) {
    return;
  }
  await context.read<TransfersCubit>().createTransfer(
        fromAccountUuid: payload['fromAccountUuid'] as String,
        toAccountUuid: payload['toAccountUuid'] as String,
        amount: payload['amount'] as double,
        notes: payload['notes'] as String? ?? '',
      );
}

class _TransferTile extends StatelessWidget {
  const _TransferTile({required this.transfer, required this.currency});

  final Transfer transfer;
  final CurrencyOption currency;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.swap_horiz, color: Color(0xFF10B981)),
        ),
        title: Text(
          '${transfer.fromAccountName} → ${transfer.toAccountName}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(transfer.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (transfer.notes.isNotEmpty)
              Text(
                transfer.notes,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
          ],
        ),
        trailing: Text(
          formatMoney(currency, transfer.amount),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF10B981),
          ),
        ),
        isThreeLine: transfer.notes.isNotEmpty,
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }
}

class AddTransferScreen extends StatefulWidget {
  const AddTransferScreen({super.key, required this.accounts});

  final List<FinanceAccount> accounts;

  @override
  State<AddTransferScreen> createState() => _AddTransferScreenState();
}

class _AddTransferScreenState extends State<AddTransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  late final AddTransferCubit _cubit;

  @override
  void initState() {
    super.initState();
    final active = widget.accounts.where((a) => a.isActive).toList();
    if (active.length >= 2) {
      _cubit = AddTransferCubit(
        initialFromAccountUuid: active[0].uuid,
        initialToAccountUuid: active[1].uuid,
      );
    } else {
      _cubit = AddTransferCubit(initialFromAccountUuid: null, initialToAccountUuid: null);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final state = _cubit.state;
    Navigator.of(context).pop({
      'fromAccountUuid': state.fromAccountUuid!,
      'toAccountUuid': state.toAccountUuid!,
      'amount': double.parse(_amountController.text.trim()),
      'notes': _notesController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeAccounts = widget.accounts.where((a) => a.isActive).toList();

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(title: const Text('New Transfer')),
        body: BlocBuilder<AddTransferCubit, AddTransferState>(
          buildWhen: (p, n) =>
              p.fromAccountUuid != n.fromAccountUuid ||
              p.toAccountUuid != n.toAccountUuid,
          builder: (context, state) {
            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: state.fromAccountUuid,
                    decoration: const InputDecoration(
                      labelText: 'From Account',
                      prefixIcon: Icon(Icons.arrow_outward),
                    ),
                    items: activeAccounts
                        .map(
                          (account) => DropdownMenuItem(
                            value: account.uuid,
                            child: Text(account.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        context.read<AddTransferCubit>().setFrom(value),
                    validator: (value) =>
                        value == null ? 'Select an account' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: state.toAccountUuid,
                    decoration: const InputDecoration(
                      labelText: 'To Account',
                      prefixIcon: Icon(Icons.arrow_downward),
                    ),
                    items: activeAccounts
                        .map(
                          (account) => DropdownMenuItem(
                            value: account.uuid,
                            child: Text(account.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        context.read<AddTransferCubit>().setTo(value),
                    validator: (value) =>
                        value == null ? 'Select an account' : null,
                  ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Enter a valid positive amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed:
                  state.fromAccountUuid != state.toAccountUuid ? _submit : null,
              child: const Text('Transfer'),
            ),
            if (state.fromAccountUuid == state.toAccountUuid &&
                state.fromAccountUuid != null)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Select different accounts for transfer',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
