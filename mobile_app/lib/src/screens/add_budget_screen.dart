import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/add_budget/add_budget_cubit.dart';
import '../models/finance_models.dart';
import '../utils/app_date_utils.dart';

class AddBudgetScreen extends StatelessWidget {
  const AddBudgetScreen({super.key, required this.categories, this.budget});

  final List<FinanceCategory> categories;
  final BudgetItem? budget;

  bool get isEditing => budget != null;

  @override
  Widget build(BuildContext context) {
    final initial = budget;
    final initialStartDate =
        initial?.startDate ?? formatAppDate(DateTime.now());
    final initialPeriod = initial?.period ?? 'monthly';
    final initialCategoryUuid = initial?.categoryUuid;

    return BlocProvider(
      create: (_) => AddBudgetCubit(
        initialPeriod: initialPeriod,
        initialCategoryUuid: initialCategoryUuid,
        initialStartDate: initialStartDate,
      ),
      child: Scaffold(
        appBar: AppBar(title: Text(isEditing ? 'Edit Budget' : 'Add Budget')),
        body: const _AddBudgetForm(),
      ),
    );
  }
}

class _AddBudgetForm extends StatefulWidget {
  const _AddBudgetForm();

  @override
  State<_AddBudgetForm> createState() => _AddBudgetFormState();
}

class _AddBudgetFormState extends State<_AddBudgetForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  late final TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    final screen = context.findAncestorWidgetOfExactType<AddBudgetScreen>()!;
    final budget = screen.budget;
    _dateController = TextEditingController(
      text: budget?.startDate ?? formatAppDate(DateTime.now()),
    );
    if (budget != null) {
      _nameController.text = budget.name;
      _amountController.text = budget.amount.toString();
      _notesController.text = budget.notes;
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
    final cubit = context.read<AddBudgetCubit>();
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
      cubit.setStartDate(formatted);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final screen = context.findAncestorWidgetOfExactType<AddBudgetScreen>()!;
    final state = context.read<AddBudgetCubit>().state;

    final result = <String, dynamic>{
      'name': _nameController.text.trim(),
      'amount': double.parse(_amountController.text.trim()),
      'period': state.period,
      'startDate': _dateController.text.trim(),
      'categoryUuid': state.categoryUuid,
      'notes': _notesController.text.trim(),
    };
    if (screen.isEditing) {
      result['uuid'] = screen.budget!.uuid;
    }

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final screen = context.findAncestorWidgetOfExactType<AddBudgetScreen>()!;
    final state = context.watch<AddBudgetCubit>().state;

    return Form(
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final amount = double.tryParse(value ?? '');
              return amount == null || amount < 0
                  ? 'Enter a valid amount'
                  : null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: state.period,
            decoration: const InputDecoration(labelText: 'Period'),
            items: const [
              DropdownMenuItem(value: 'daily', child: Text('Daily')),
              DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
              DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
            ],
            onChanged: (value) {
              if (value != null)
                context.read<AddBudgetCubit>().setPeriod(value);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String?>(
            initialValue: state.categoryUuid,
            decoration: const InputDecoration(labelText: 'Category (optional)'),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All categories'),
              ),
              ...screen.categories.map(
                (category) => DropdownMenuItem<String?>(
                  value: category.uuid,
                  child: Text(category.name),
                ),
              ),
            ],
            onChanged: (value) =>
                context.read<AddBudgetCubit>().setCategoryUuid(value),
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
          FilledButton(
            onPressed: _submit,
            child: Text(screen.isEditing ? 'Update Budget' : 'Save Budget'),
          ),
        ],
      ),
    );
  }
}
