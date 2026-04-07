import 'package:flutter/material.dart';

import '../api/finance_mcp_client.dart';
import '../models/auth_session.dart';
import '../models/currency_option.dart';
import '../models/finance_models.dart';
import '../services/finance_data_provider.dart';
import '../utils/currency_utils.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({
    super.key,
    required this.session,
    required this.currency,
  });

  final AuthSession session;
  final CurrencyOption currency;

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  late final FinanceDataProvider _dataProvider;
  late Future<List<FinanceAccount>> _future;

  @override
  void initState() {
    super.initState();
    _dataProvider = FinanceDataProvider();
    _future = _load();
  }

  Future<List<FinanceAccount>> _load() async {
    return _dataProvider.getAccounts(widget.session.token);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  Future<void> _openAddAccount() async {
    final payload = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const AddAccountScreen()),
    );

    if (!mounted || payload == null) {
      return;
    }

    await _dataProvider.saveAccount(
      widget.session.token,
      name: payload['name'] as String,
      type: payload['type'] as String,
      initialBalance: payload['initialBalance'] as double,
      color: payload['color'] as String,
      icon: payload['icon'] as String,
      notes: payload['notes'] as String? ?? '',
    );
    _showMessage('Account created');
    await _refresh();
  }

  Future<void> _editAccount(FinanceAccount account) async {
    final payload = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => AddAccountScreen(initialAccount: account, isEdit: true),
      ),
    );

    if (!mounted || payload == null) {
      return;
    }

    final client = FinanceMcpClient(token: widget.session.token);
    await client.updateAccount(
      id: account.id,
      name: payload['name'] as String,
      type: payload['type'] as String,
      color: payload['color'] as String,
      icon: payload['icon'] as String,
      notes: payload['notes'] as String? ?? '',
    );
    _showMessage('Account updated');
    await _refresh();
  }

  Future<void> _deleteAccount(FinanceAccount account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: Text(
          'Delete "${account.name}"? This action cannot be undone.',
        ),
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

    if (confirmed != true) {
      return;
    }

    final client = FinanceMcpClient(token: widget.session.token);
    await client.deleteAccount(account.id);
    _showMessage('Account deleted');
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
      appBar: AppBar(title: const Text('Accounts')),
      body: FutureBuilder<List<FinanceAccount>>(
        future: _future,
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

          if (accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('No accounts yet'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _openAddAccount,
                    child: const Text('Add Account'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                return _AccountCard(
                  account: account,
                  currency: widget.currency,
                  onEdit: () => _editAccount(account),
                  onDelete: () => _deleteAccount(account),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddAccount,
        icon: const Icon(Icons.add),
        label: const Text('Add Account'),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });

  final FinanceAccount account;
  final CurrencyOption currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final accountColor = _parseColor(account.color);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
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
                      color: accountColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getAccountIcon(account.icon),
                      color: accountColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              account.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (!account.isActive) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Inactive',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          _getAccountTypeLabel(account.type),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Current Balance'),
                    Text(
                      formatMoney(currency, account.currentBalance),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: account.currentBalance >= 0
                            ? const Color(0xFF15803D)
                            : const Color(0xFFB91C1C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getAccountIcon(String icon) {
    switch (icon) {
      case 'account_balance':
        return Icons.account_balance;
      case 'credit_card':
        return Icons.credit_card;
      case 'trending_up':
        return Icons.trending_up;
      default:
        return Icons.account_balance_wallet;
    }
  }

  String _getAccountTypeLabel(String type) {
    switch (type) {
      case 'cash':
        return 'Cash';
      case 'bank':
        return 'Bank Account';
      case 'credit_card':
        return 'Credit Card';
      case 'investments':
        return 'Investments';
      default:
        return type;
    }
  }

  Color _parseColor(String colorStr) {
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF0E7490);
    }
  }
}

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key, this.initialAccount, this.isEdit = false});

  final FinanceAccount? initialAccount;
  final bool isEdit;

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _initialBalanceController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedType = 'cash';
  String _selectedColor = '#0E7490';
  String _selectedIcon = 'account_balance_wallet';

  static const _accountTypes = [
    {'value': 'cash', 'label': 'Cash', 'icon': Icons.account_balance_wallet},
    {'value': 'bank', 'label': 'Bank Account', 'icon': Icons.account_balance},
    {'value': 'credit_card', 'label': 'Credit Card', 'icon': Icons.credit_card},
    {'value': 'investments', 'label': 'Investments', 'icon': Icons.trending_up},
  ];

  static const _accountColors = [
    '#10B981',
    '#0E7490',
    '#3B82F6',
    '#8B5CF6',
    '#F59E0B',
    '#EF4444',
    '#EC4899',
    '#6B7280',
  ];

  static const _accountIcons = [
    'account_balance_wallet',
    'account_balance',
    'credit_card',
    'trending_up',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialAccount != null) {
      _nameController.text = widget.initialAccount!.name;
      _selectedType = widget.initialAccount!.type;
      _selectedColor = widget.initialAccount!.color;
      _selectedIcon = widget.initialAccount!.icon;
      _notesController.text = widget.initialAccount!.notes;
    }
    _initialBalanceController.text =
        widget.initialAccount?.initialBalance.toString() ?? '0';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialBalanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop({
      'name': _nameController.text.trim(),
      'type': _selectedType,
      'initialBalance': double.tryParse(_initialBalanceController.text) ?? 0,
      'color': _selectedColor,
      'icon': _selectedIcon,
      'notes': _notesController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Account' : 'Add Account'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Account Name'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Enter a name' : null,
            ),
            const SizedBox(height: 16),
            if (!widget.isEdit) ...[
              TextFormField(
                controller: _initialBalanceController,
                decoration: const InputDecoration(
                  labelText: 'Initial Balance',
                  hintText: 'Starting balance for this account',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text('Account Type'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _accountTypes.map((type) {
                final isSelected = _selectedType == type['value'];
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        type['icon'] as IconData,
                        size: 18,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(type['label'] as String),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = type['value'] as String;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Color'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _accountColors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _parseColor(color),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Icon'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _accountIcons.map((icon) {
                final isSelected = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = icon;
                    });
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _parseColor(_selectedColor)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconData(icon),
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: Text(widget.isEdit ? 'Update' : 'Create Account'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String icon) {
    switch (icon) {
      case 'account_balance':
        return Icons.account_balance;
      case 'credit_card':
        return Icons.credit_card;
      case 'trending_up':
        return Icons.trending_up;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color _parseColor(String colorStr) {
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF0E7490);
    }
  }
}
