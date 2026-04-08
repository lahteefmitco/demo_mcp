import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/add_account/add_account_cubit.dart';
import '../models/auth_session.dart';
import '../repository/finance_repository.dart';
import '../cubits/accounts/accounts_cubit.dart';
import '../cubits/accounts/accounts_state.dart';
import '../models/currency_option.dart';
import '../models/finance_models.dart';
import '../utils/currency_utils.dart';
import '../utils/toast.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({
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
      create: (_) => AccountsCubit(repository: repo),
      child: BlocListener<AccountsCubit, AccountsState>(
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
              appBar: AppBar(title: const Text('Accounts')),
              body: FutureBuilder<List<FinanceAccount>>(
                future: blocContext.watch<AccountsCubit>().state.accountsFuture,
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
                    onPressed: () => context.read<AccountsCubit>().refresh(),
                    child: const Text('Retry'),
                  ),
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
                    onPressed: () => _openAddAccount(context),
                    child: const Text('Add Account'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<AccountsCubit>().refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                return _AccountCard(
                  account: account,
                  currency: currency,
                  onEdit: () => _editAccount(context, account),
                  onDelete: () => _deleteAccount(context, account),
                );
              },
            ),
          );
                },
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () => _openAddAccount(blocContext),
                icon: const Icon(Icons.add),
                label: const Text('Add Account'),
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<void> _openAddAccount(BuildContext context) async {
  final payload = await Navigator.of(context).push<Map<String, dynamic>>(
    MaterialPageRoute(builder: (_) => const AddAccountScreen()),
  );
  if (!context.mounted || payload == null) {
    return;
  }

  await context.read<AccountsCubit>().createAccount(
        name: payload['name'] as String,
        type: payload['type'] as String,
        initialBalance: payload['initialBalance'] as double,
        color: payload['color'] as String,
        icon: payload['icon'] as String,
        notes: payload['notes'] as String? ?? '',
      );
}

Future<void> _editAccount(BuildContext context, FinanceAccount account) async {
  final payload = await Navigator.of(context).push<Map<String, dynamic>>(
    MaterialPageRoute(
      builder: (_) => AddAccountScreen(initialAccount: account, isEdit: true),
    ),
  );
  if (!context.mounted || payload == null) {
    return;
  }

  await context.read<AccountsCubit>().updateAccount(
        uuid: account.uuid,
        name: payload['name'] as String,
        type: payload['type'] as String,
        color: payload['color'] as String,
        icon: payload['icon'] as String,
        notes: payload['notes'] as String? ?? '',
      );
}

Future<void> _deleteAccount(BuildContext context, FinanceAccount account) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete account?'),
      content: Text('Delete "${account.name}"? This action cannot be undone.'),
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
  await context.read<AccountsCubit>().deleteAccount(account.uuid);
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

class AddAccountScreen extends StatelessWidget {
  const AddAccountScreen({super.key, this.initialAccount, this.isEdit = false});

  final FinanceAccount? initialAccount;
  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    final initial = initialAccount;
    final initialType = initial?.type ?? 'cash';
    final initialColor = initial?.color ?? '#0E7490';
    final initialIcon = initial?.icon ?? 'account_balance_wallet';

    return BlocProvider(
      create: (_) => AddAccountCubit(
        initialType: initialType,
        initialColor: initialColor,
        initialIcon: initialIcon,
      ),
      child: Scaffold(
        appBar: AppBar(title: Text(isEdit ? 'Edit Account' : 'Add Account')),
        body: const _AddAccountForm(),
      ),
    );
  }

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
}

class _AddAccountForm extends StatefulWidget {
  const _AddAccountForm();

  @override
  State<_AddAccountForm> createState() => _AddAccountFormState();
}

class _AddAccountFormState extends State<_AddAccountForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _initialBalanceController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final screen = context.findAncestorWidgetOfExactType<AddAccountScreen>()!;
    final initial = screen.initialAccount;
    if (initial != null) {
      _nameController.text = initial.name;
      _notesController.text = initial.notes;
    }
    _initialBalanceController.text = initial?.initialBalance.toString() ?? '0';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialBalanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final state = context.read<AddAccountCubit>().state;

    Navigator.of(context).pop({
      'name': _nameController.text.trim(),
      'type': state.selectedType,
      'initialBalance': double.tryParse(_initialBalanceController.text) ?? 0,
      'color': state.selectedColor,
      'icon': state.selectedIcon,
      'notes': _notesController.text.trim(),
    });
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

  @override
  Widget build(BuildContext context) {
    final screen = context.findAncestorWidgetOfExactType<AddAccountScreen>()!;
    final state = context.watch<AddAccountCubit>().state;

    return Form(
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
          if (!screen.isEdit) ...[
            TextFormField(
              controller: _initialBalanceController,
              decoration: const InputDecoration(
                labelText: 'Initial Balance',
                hintText: 'Starting balance for this account',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
          ],
          const Text('Account Type'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: AddAccountScreen._accountTypes.map((type) {
              final isSelected = state.selectedType == type['value'];
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
                onSelected: (_) => context
                    .read<AddAccountCubit>()
                    .setType(type['value'] as String),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Color'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: AddAccountScreen._accountColors.map((color) {
              final isSelected = state.selectedColor == color;
              return GestureDetector(
                onTap: () => context.read<AddAccountCubit>().setColor(color),
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
            children: AddAccountScreen._accountIcons.map((icon) {
              final isSelected = state.selectedIcon == icon;
              return GestureDetector(
                onTap: () => context.read<AddAccountCubit>().setIcon(icon),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected ? _parseColor(state.selectedColor) : Colors.grey.shade200,
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
            child: Text(screen.isEdit ? 'Update' : 'Create Account'),
          ),
        ],
      ),
    );
  }
}
