import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cubits/add_entry/add_entry_cubit.dart';
import '../models/finance_models.dart';
import '../repository/finance_repository.dart';
import '../utils/app_date_utils.dart';
import 'accounts_screen.dart';

const _kLastAccountUuidKey = 'finance_last_selected_account_uuid';

/// Saved account UUID when it still exists among [accounts] (active only).
Future<String?> readLastSelectedAccountUuidIfValid(
  List<FinanceAccount> accounts,
) async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_kLastAccountUuidKey);
  if (saved == null || saved.isEmpty) {
    return null;
  }
  final active = accounts.where((a) => a.isActive).map((a) => a.uuid).toSet();
  return active.contains(saved) ? saved : null;
}

Future<void> persistLastSelectedAccountUuid(String uuid) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kLastAccountUuidKey, uuid);
}

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({
    super.key,
    required this.title,
    required this.categories,
    required this.accounts,
    required this.dateLabel,
    required this.dateKey,
    this.initialEntry,
    this.initialCategoryUuid,
    this.initialAccountUuid,
    this.saveLabel = 'Save',
  });

  final String title;
  final String dateLabel;
  final String dateKey;
  final List<FinanceCategory> categories;
  final List<FinanceAccount> accounts;
  final FinanceEntry? initialEntry;

  /// Used only for new entries (when [initialEntry] is null). Omit or pass null for no preset.
  final String? initialCategoryUuid;

  /// Used only for new entries (when [initialEntry] is null), e.g. last-used account from prefs.
  final String? initialAccountUuid;

  final String saveLabel;

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();

  static IconData getAccountIcon(String icon) {
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

  static Color parseColor(String colorStr) {
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF0E7490);
    }
  }
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  late List<FinanceAccount> _accounts;
  late final AddEntryCubit _cubit;

  @override
  void initState() {
    super.initState();
    _accounts = List.from(widget.accounts);
    final initial = widget.initialEntry;
    final String? initialCategoryUuid;
    final String? initialAccountUuid;
    if (initial != null) {
      initialCategoryUuid =
          initial.categoryUuid.isNotEmpty ? initial.categoryUuid : null;
      initialAccountUuid =
          initial.accountUuid.isNotEmpty ? initial.accountUuid : null;
    } else {
      initialCategoryUuid = widget.initialCategoryUuid;
      initialAccountUuid = widget.initialAccountUuid;
    }
    final initialDate = initial?.date ?? formatAppDate(DateTime.now());
    _cubit = AddEntryCubit(
      initialCategoryUuid: initialCategoryUuid,
      initialAccountUuid: initialAccountUuid,
      initialDate: initialDate,
    );
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _setAccounts(List<FinanceAccount> next) {
    setState(() => _accounts = List.from(next));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: _AddEntryForm(
          screen: widget,
          accounts: _accounts,
          onAccountsUpdated: _setAccounts,
        ),
      ),
    );
  }
}

class _AddEntryForm extends StatefulWidget {
  const _AddEntryForm({
    required this.screen,
    required this.accounts,
    required this.onAccountsUpdated,
  });

  final AddEntryScreen screen;
  final List<FinanceAccount> accounts;
  final void Function(List<FinanceAccount>) onAccountsUpdated;

  @override
  State<_AddEntryForm> createState() => _AddEntryFormState();
}

class _AddEntryFormState extends State<_AddEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  late final TextEditingController _dateController;
  bool _openingAddAccount = false;

  AddEntryScreen get _screen => widget.screen;

  @override
  void initState() {
    super.initState();
    final initial = _screen.initialEntry;
    _titleController.text = initial?.title ?? '';
    _amountController.text = initial?.amount.toString() ?? '';
    _notesController.text = initial?.notes ?? '';
    _dateController = TextEditingController(
      text: initial?.date ?? formatAppDate(DateTime.now()),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final cubit = context.read<AddEntryCubit>();
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: parseAppDate(_dateController.text) ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (selected != null) {
      final formatted = formatAppDate(selected);
      _dateController.text = formatted;
      cubit.setDate(formatted);
    }
  }

  Future<void> _openAddAccount() async {
    if (_openingAddAccount) {
      return;
    }
    _openingAddAccount = true;
    try {
      final payload = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute<Map<String, dynamic>>(
          builder: (_) => const AddAccountScreen(),
        ),
      );
      if (!mounted || payload == null) {
        return;
      }

      final repo = context.read<FinanceRepository>();
      final uuid = await repo.createAccount(
        name: payload['name'] as String,
        type: payload['type'] as String,
        initialBalance: payload['initialBalance'] as double,
        color: payload['color'] as String,
        icon: payload['icon'] as String,
        notes: payload['notes'] as String? ?? '',
      );
      final next = await repo.listAccountsLocal();
      if (!mounted) {
        return;
      }
      widget.onAccountsUpdated(next);
      context.read<AddEntryCubit>().selectAccount(uuid);
      await persistLastSelectedAccountUuid(uuid);
    } finally {
      _openingAddAccount = false;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final state = context.read<AddEntryCubit>().state;
    final accountUuid = state.selectedAccountUuid;
    if (accountUuid != null && accountUuid.isNotEmpty) {
      await persistLastSelectedAccountUuid(accountUuid);
    }

    if (!mounted) return;

    Navigator.of(context).pop({
      'title': _titleController.text.trim(),
      'amount': double.parse(_amountController.text.trim()),
      'categoryUuid': state.selectedCategoryUuid!,
      'accountUuid': state.selectedAccountUuid!,
      _screen.dateKey: _dateController.text.trim(),
      'notes': _notesController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AddEntryCubit>().state;
    final activeAccounts = widget.accounts.where((a) => a.isActive).toList();

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Enter a title' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final amount = double.tryParse(value ?? '');
              return amount == null || amount < 0
                  ? 'Enter a valid amount'
                  : null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String?>(
            key: ValueKey(
              'entry_cat_${state.selectedCategoryUuid}_${_screen.categories.length}',
            ),
            initialValue: state.selectedCategoryUuid,
            decoration: const InputDecoration(
              labelText: 'Category',
              hintText: 'Select category',
            ),
            items: _screen.categories
                .map(
                  (category) => DropdownMenuItem<String?>(
                    value: category.uuid,
                    child: Text(category.name),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                context.read<AddEntryCubit>().selectCategory(value),
            validator: (value) => value == null ? 'Select a category' : null,
          ),
          const SizedBox(height: 16),
          if (activeAccounts.isEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'No accounts yet. Add one to save this entry.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: _openingAddAccount ? null : _openAddAccount,
                  icon: const Icon(Icons.add),
                  label: const Text('Add account'),
                ),
              ],
            )
          else
            DropdownButtonFormField<String?>(
              key: ValueKey(
                'entry_acc_${state.selectedAccountUuid}_${activeAccounts.length}',
              ),
              initialValue: state.selectedAccountUuid,
              decoration: const InputDecoration(
                labelText: 'Account',
                hintText: 'Select account',
              ),
              items: activeAccounts
                  .map(
                    (account) => DropdownMenuItem<String?>(
                      value: account.uuid,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AddEntryScreen.getAccountIcon(account.icon),
                            size: 20,
                            color: AddEntryScreen.parseColor(account.color),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              account.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                context.read<AddEntryCubit>().selectAccount(value);
                if (value != null && value.isNotEmpty) {
                  persistLastSelectedAccountUuid(value);
                }
              },
              validator: (value) => value == null ? 'Select an account' : null,
            ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _dateController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: _screen.dateLabel,
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            onTap: _pickDate,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Notes'),
            minLines: 3,
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: activeAccounts.isEmpty ? null : _submit,
            child: Text(_screen.saveLabel),
          ),
        ],
      ),
    );
  }
}
