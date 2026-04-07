import 'package:flutter/material.dart';

import '../models/finance_models.dart';
import '../utils/app_date_utils.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key, required this.categories, this.budget});

  final List<FinanceCategory> categories;
  final BudgetItem? budget;

  bool get isEditing => budget != null;

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  late final TextEditingController _dateController;
  String _period = 'monthly';
  String? _categoryUuid;

  @override
  void initState() {
    super.initState();
    final budget = widget.budget;
    _dateController = TextEditingController(
      text: budget?.startDate ?? formatAppDate(DateTime.now()),
    );
    if (budget != null) {
      _nameController.text = budget.name;
      _amountController.text = budget.amount.toString();
      _notesController.text = budget.notes;
      _period = budget.period;
      _categoryUuid = budget.categoryUuid;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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

    final result = <String, dynamic>{
      'name': _nameController.text.trim(),
      'amount': double.parse(_amountController.text.trim()),
      'period': _period,
      'startDate': _dateController.text.trim(),
      'categoryUuid': _categoryUuid,
      'notes': _notesController.text.trim(),
    };

    if (widget.isEditing) {
      result['uuid'] = widget.budget!.uuid;
    }

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Budget' : 'Add Budget'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Budget name'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a budget name'
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
              initialValue: _period,
              decoration: const InputDecoration(labelText: 'Period'),
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _period = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              initialValue: _categoryUuid,
              decoration: const InputDecoration(
                labelText: 'Category (optional)',
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All categories'),
                ),
                ...widget.categories.map(
                  (category) => DropdownMenuItem<String?>(
                    value: category.uuid,
                    child: Text(category.name),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _categoryUuid = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Start date',
                suffixIcon: Icon(Icons.calendar_today),
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
            FilledButton(onPressed: _submit, child: const Text('Save Budget')),
          ],
        ),
      ),
    );
  }
}
