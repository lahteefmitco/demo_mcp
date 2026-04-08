import 'dart:developer';

import 'package:flutter/material.dart';

import '../models/finance_models.dart';
import '../utils/app_date_utils.dart';

class AddEntryScreen extends StatefulWidget {
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
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  late final TextEditingController _dateController;
  String? _selectedCategoryUuid;
  String? _selectedAccountUuid;

  @override
  void initState() {
    log("AddEntryScreen initState");
    super.initState();
    final initialEntry = widget.initialEntry;
    _selectedCategoryUuid = initialEntry?.categoryUuid.isNotEmpty == true
        ? initialEntry!.categoryUuid
        : (widget.categories.isNotEmpty ? widget.categories.first.uuid : null);
    _selectedAccountUuid = initialEntry?.accountUuid.isNotEmpty == true
        ? initialEntry!.accountUuid
        : (widget.accounts.where((a) => a.isActive).firstOrNull?.uuid);
    _titleController.text = initialEntry?.title ?? '';
    _amountController.text = initialEntry?.amount.toString() ?? '';
    _notesController.text = initialEntry?.notes ?? '';
    _dateController = TextEditingController(
      text: initialEntry?.date ?? formatAppDate(DateTime.now()),
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
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: parseAppDate(_dateController.text) ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (selected != null) {
      _dateController.text = formatAppDate(selected);
      setState(() {});
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop({
      'title': _titleController.text.trim(),
      'amount': double.parse(_amountController.text.trim()),
      'categoryUuid': _selectedCategoryUuid!,
      'accountUuid': _selectedAccountUuid!,
      widget.dateKey: _dateController.text.trim(),
      'notes': _notesController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Form(
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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                final amount = double.tryParse(value ?? '');
                return amount == null || amount < 0
                    ? 'Enter a valid amount'
                    : null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategoryUuid,
              decoration: const InputDecoration(labelText: 'Category'),
              items: widget.categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category.uuid,
                      child: Text(category.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryUuid = value;
                });
              },
              validator: (value) => value == null ? 'Select a category' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedAccountUuid,
              decoration: const InputDecoration(labelText: 'Account'),
              items: widget.accounts
                  .where((a) => a.isActive)
                  .map(
                    (account) => DropdownMenuItem(
                      value: account.uuid,
                      child: Row(
                        children: [
                          Icon(
                            _getAccountIcon(account.icon),
                            size: 20,
                            color: _parseColor(account.color),
                          ),
                          const SizedBox(width: 8),
                          Text(account.name),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAccountUuid = value;
                });
              },
              validator: (value) => value == null ? 'Select an account' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: widget.dateLabel,
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
            FilledButton(onPressed: _submit, child: Text(widget.saveLabel)),
          ],
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

  Color _parseColor(String colorStr) {
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF0E7490);
    }
  }
}
