import 'package:flutter/material.dart';

import '../models/finance_models.dart';
import '../utils/app_date_utils.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({
    super.key,
    required this.title,
    required this.categories,
    required this.dateLabel,
    required this.dateKey,
    this.initialEntry,
    this.saveLabel = 'Save',
  });

  final String title;
  final String dateLabel;
  final String dateKey;
  final List<FinanceCategory> categories;
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
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final initialEntry = widget.initialEntry;
    _selectedCategoryId = initialEntry?.categoryId;
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
      'categoryId': _selectedCategoryId!,
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
            DropdownButtonFormField<int>(
              initialValue: _selectedCategoryId,
              decoration: const InputDecoration(labelText: 'Category'),
              items: widget.categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
              validator: (value) => value == null ? 'Select a category' : null,
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
}
