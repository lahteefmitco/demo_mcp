import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/add_entry/add_entry_cubit.dart';
import '../models/finance_models.dart';
import '../utils/app_date_utils.dart';

class AddEntryScreen extends StatelessWidget {
  const AddEntryScreen({
    super.key,
    required this.title,
    required this.categories,
    required this.accounts,
    required this.dateLabel,
    required this.dateKey,
    this.initialEntry,
    this.saveLabel = 'Save',
  });

  final String title;
  final String dateLabel;
  final String dateKey;
  final List<FinanceCategory> categories;
  final List<FinanceAccount> accounts;
  final FinanceEntry? initialEntry;
  final String saveLabel;

  @override
  Widget build(BuildContext context) {
    final initial = initialEntry;
    final initialCategoryUuid = initial?.categoryUuid.isNotEmpty == true
        ? initial!.categoryUuid
        : (categories.isNotEmpty ? categories.first.uuid : null);
    final initialAccountUuid = initial?.accountUuid.isNotEmpty == true
        ? initial!.accountUuid
        : (accounts.where((a) => a.isActive).firstOrNull?.uuid);
    final initialDate = initial?.date ?? formatAppDate(DateTime.now());

    return BlocProvider(
      create: (_) => AddEntryCubit(
        initialCategoryUuid: initialCategoryUuid,
        initialAccountUuid: initialAccountUuid,
        initialDate: initialDate,
      ),
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const _AddEntryForm(),
      ),
    );
  }

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

class _AddEntryForm extends StatefulWidget {
  const _AddEntryForm();

  @override
  State<_AddEntryForm> createState() => _AddEntryFormState();
}

class _AddEntryFormState extends State<_AddEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  late final TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    final args = context.findAncestorWidgetOfExactType<AddEntryScreen>()!;
    final initial = args.initialEntry;
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final screen = context.findAncestorWidgetOfExactType<AddEntryScreen>()!;
    final state = context.read<AddEntryCubit>().state;

    Navigator.of(context).pop({
      'title': _titleController.text.trim(),
      'amount': double.parse(_amountController.text.trim()),
      'categoryUuid': state.selectedCategoryUuid!,
      'accountUuid': state.selectedAccountUuid!,
      screen.dateKey: _dateController.text.trim(),
      'notes': _notesController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = context.findAncestorWidgetOfExactType<AddEntryScreen>()!;
    final state = context.watch<AddEntryCubit>().state;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Enter a title'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final amount = double.tryParse(value ?? '');
              return amount == null || amount < 0 ? 'Enter a valid amount' : null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: state.selectedCategoryUuid,
            decoration: const InputDecoration(labelText: 'Category'),
            items: screen.categories
                .map(
                  (category) => DropdownMenuItem(
                    value: category.uuid,
                    child: Text(category.name),
                  ),
                )
                .toList(),
            onChanged: (value) => context.read<AddEntryCubit>().selectCategory(value),
            validator: (value) => value == null ? 'Select a category' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: state.selectedAccountUuid,
            decoration: const InputDecoration(labelText: 'Account'),
            items: screen.accounts
                .where((a) => a.isActive)
                .map(
                  (account) => DropdownMenuItem(
                    value: account.uuid,
                    child: Row(
                      children: [
                        Icon(
                          AddEntryScreen.getAccountIcon(account.icon),
                          size: 20,
                          color: AddEntryScreen.parseColor(account.color),
                        ),
                        const SizedBox(width: 8),
                        Text(account.name),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => context.read<AddEntryCubit>().selectAccount(value),
            validator: (value) => value == null ? 'Select an account' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _dateController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: screen.dateLabel,
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
          FilledButton(onPressed: _submit, child: Text(screen.saveLabel)),
        ],
      ),
    );
  }
}
