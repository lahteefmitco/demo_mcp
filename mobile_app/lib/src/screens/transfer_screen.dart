import 'package:flutter/material.dart';

import '../api/finance_mcp_client.dart';
import '../models/auth_session.dart';
import '../models/currency_option.dart';
import '../models/finance_models.dart';
import '../utils/currency_utils.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({
    super.key,
    required this.session,
    required this.currency,
  });

  final AuthSession session;
  final CurrencyOption currency;

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  late final FinanceMcpClient _client;
  late Future<List<FinanceAccount>> _accountsFuture;
  late Future<List<Transfer>> _transfersFuture;

  @override
  void initState() {
    super.initState();
    _client = FinanceMcpClient(token: widget.session.token);
    _accountsFuture = _client.fetchAccounts();
    _transfersFuture = _client.fetchTransfers(limit: 20);
  }

  Future<void> _refresh() async {
    setState(() {
      _accountsFuture = _client.fetchAccounts();
      _transfersFuture = _client.fetchTransfers(limit: 20);
    });
  }

  Future<void> _openTransferDialog(List<FinanceAccount> accounts) async {
    final payload = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => AddTransferScreen(accounts: accounts)),
    );

    if (!mounted || payload == null) {
      return;
    }

    await _client.transferBetweenAccounts(
      fromAccountId: payload['fromAccountId'] as int,
      toAccountId: payload['toAccountId'] as int,
      amount: payload['amount'] as double,
      notes: payload['notes'] as String? ?? '',
    );
    _showMessage('Transfer completed');
    await _refresh();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfers')),
      body: FutureBuilder<List<FinanceAccount>>(
        future: _accountsFuture,
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
                  FilledButton(onPressed: _refresh, child: const Text('Retry')),
                ],
              ),
            );
          }

          final accounts = snapshot.data!;

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
                                ? () => _openTransferDialog(accounts)
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
                  future: _transfersFuture,
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
                              currency: widget.currency,
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
  }
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
  int? _fromAccountId;
  int? _toAccountId;

  @override
  void initState() {
    super.initState();
    if (widget.accounts.length >= 2) {
      _fromAccountId = widget.accounts[0].id;
      _toAccountId = widget.accounts[1].id;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop({
      'fromAccountId': _fromAccountId!,
      'toAccountId': _toAccountId!,
      'amount': double.parse(_amountController.text.trim()),
      'notes': _notesController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeAccounts = widget.accounts.where((a) => a.isActive).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('New Transfer')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<int>(
              initialValue: _fromAccountId,
              decoration: const InputDecoration(
                labelText: 'From Account',
                prefixIcon: Icon(Icons.arrow_outward),
              ),
              items: activeAccounts
                  .map(
                    (account) => DropdownMenuItem(
                      value: account.id,
                      child: Text(account.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _fromAccountId = value;
                });
              },
              validator: (value) => value == null ? 'Select an account' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _toAccountId,
              decoration: const InputDecoration(
                labelText: 'To Account',
                prefixIcon: Icon(Icons.arrow_downward),
              ),
              items: activeAccounts
                  .map(
                    (account) => DropdownMenuItem(
                      value: account.id,
                      child: Text(account.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _toAccountId = value;
                });
              },
              validator: (value) => value == null ? 'Select an account' : null,
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
              onPressed: _fromAccountId != _toAccountId ? _submit : null,
              child: const Text('Transfer'),
            ),
            if (_fromAccountId == _toAccountId && _fromAccountId != null)
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
      ),
    );
  }
}
