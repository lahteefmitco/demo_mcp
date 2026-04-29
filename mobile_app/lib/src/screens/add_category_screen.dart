import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/add_category/add_category_cubit.dart';
import '../models/finance_models.dart';
import '../repository/finance_repository.dart';

class AddCategoryScreen extends StatelessWidget {
  const AddCategoryScreen({super.key, this.category, this.repository});

  final FinanceCategory? category;
  final FinanceRepository? repository;

  bool get isEditing => category != null;

  static const _colorOptions = <String>[
    '#EF4444',
    '#F97316',
    '#F59E0B',
    '#EAB308',
    '#84CC16',
    '#22C55E',
    '#10B981',
    '#14B8A6',
    '#06B6D4',
    '#0EA5E9',
    '#3B82F6',
    '#6366F1',
    '#8B5CF6',
    '#A855F7',
    '#D946EF',
    '#EC4899',
    '#F43F5E',
    '#DC2626',
    '#EA580C',
    '#CA8A04',
    '#65A30D',
    '#16A34A',
    '#059669',
    '#0D9488',
    '#0891B2',
    '#0284C7',
    '#2563EB',
    '#4F46E5',
    '#7C3AED',
    '#9333EA',
    '#C026D3',
    '#DB2777',
    '#E11D48',
    '#B91C1C',
    '#C2410C',
    '#A16207',
    '#4D7C0F',
    '#15803D',
    '#047857',
    '#0F766E',
    '#0E7490',
    '#0369A1',
    '#1D4ED8',
    '#4338CA',
    '#6D28D9',
    '#7E22CE',
    '#A21CAF',
    '#BE185D',
    '#475569',
    '#334155',
  ];

  @override
  Widget build(BuildContext context) {
    final initialKind = category?.kind ?? 'expense';
    final initialColor = category?.color ?? '#0E7490';
    final initialParentId = category?.parentId;

    return BlocProvider(
      create: (_) => AddCategoryCubit(
        initialKind: initialKind,
        initialColor: initialColor,
        initialParentId: initialParentId,
      ),
      child: Builder(
        builder: (blocContext) => Scaffold(
          appBar: AppBar(
            title: Text(isEditing ? 'Edit Category' : 'Add Category'),
          ),
          body: _AddCategoryForm(colorOptions: _colorOptions),
        ),
      ),
    );
  }
}

class _AddCategoryForm extends StatefulWidget {
  const _AddCategoryForm({required this.colorOptions});

  final List<String> colorOptions;

  @override
  State<_AddCategoryForm> createState() => _AddCategoryFormState();
}

class _AddCategoryFormState extends State<_AddCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _iconController;
  List<FinanceCategory> _parentCategories = [];
  bool _loadingParents = false;

  @override
  void initState() {
    super.initState();
    final screen = context.findAncestorWidgetOfExactType<AddCategoryScreen>()!;
    final category = screen.category;
    _nameController = TextEditingController(text: category?.name ?? '');
    _iconController = TextEditingController(text: category?.icon ?? 'tag');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadParentCategories();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  Future<void> _loadParentCategories() async {
    setState(() => _loadingParents = true);
    try {
      final repo = context.read<FinanceRepository>();
      final List<FinanceCategory> categories = await repo.listCategoriesLocal();
      final screen = context.findAncestorWidgetOfExactType<AddCategoryScreen>()!;
      final currentCategory = screen.category;
      final state = context.read<AddCategoryCubit>().state;

      setState(() {
        _parentCategories = categories.where((cat) {
          if (currentCategory != null && cat.uuid == currentCategory.uuid) return false;
          // Filter by kind compatibility
          if (state.kind == 'expense') {
            if (cat.kind != 'expense' && cat.kind != 'both') return false;
          } else if (state.kind == 'income') {
            if (cat.kind != 'income' && cat.kind != 'both') return false;
          }
          // 'both' kind can have any parent
          return true;
        }).toList();
        _loadingParents = false;
      });
    } catch (e) {
      log("Error=> $e");
      setState(() => _loadingParents = false);
    }
  }

  Color _parseColor(String hex) {
    final normalized = hex.replaceFirst('#', '');
    return Color(int.parse('FF$normalized', radix: 16));
  }

  Future<void> _pickColor() async {
    final cubit = context.read<AddCategoryCubit>();
    final current = context.read<AddCategoryCubit>().state.selectedColor;
    final selected = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => _ColorPickerScreen(
          colorOptions: widget.colorOptions,
          selectedColor: current,
        ),
      ),
    );

    if (!context.mounted || selected == null) return;
    cubit.setColor(selected);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final screen = context.findAncestorWidgetOfExactType<AddCategoryScreen>()!;
    final state = context.read<AddCategoryCubit>().state;

    final result = <String, dynamic>{
      'name': _nameController.text.trim(),
      'kind': state.kind,
      'color': state.selectedColor,
      'icon': _iconController.text.trim(),
      if (state.parentId != null) 'parentId': state.parentId,
    };
    if (screen.isEditing) {
      result['uuid'] = screen.category!.uuid;
    }

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final screen = context.findAncestorWidgetOfExactType<AddCategoryScreen>()!;
    final state = context.watch<AddCategoryCubit>().state;
    final previewColor = _parseColor(state.selectedColor);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Category name'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Enter a category name'
                : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: state.kind,
            decoration: const InputDecoration(labelText: 'Kind'),
            items: const [
              DropdownMenuItem(value: 'expense', child: Text('Expense')),
              DropdownMenuItem(value: 'income', child: Text('Income')),
              DropdownMenuItem(value: 'both', child: Text('Both')),
            ],
            onChanged: (value) {
              if (value != null) {
                context.read<AddCategoryCubit>().setKind(value);
                // Reload parent categories when kind changes
                _loadParentCategories();
              }
            },
          ),
          const SizedBox(height: 16),
          if (_loadingParents)
            const Center(child: CircularProgressIndicator())
          else
            DropdownButtonFormField<String?>(
              initialValue: state.parentId,
              decoration: const InputDecoration(
                labelText: 'Parent Category (optional)',
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('None (Top-level)'),
                ),
                ..._parentCategories.map((cat) {
                  final indent = '  ' * cat.level;
                  return DropdownMenuItem<String?>(
                    value: cat.uuid,
                    child: Text('$indent${cat.name}'),
                  );
                }),
              ],
              onChanged: (value) {
                context.read<AddCategoryCubit>().setParentId(value);
              },
            ),
          const SizedBox(height: 16),
          Text('Color', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _pickColor,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Select color',
                suffixIcon: Icon(Icons.chevron_right),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: previewColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    state.selectedColor,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _iconController,
            decoration: const InputDecoration(labelText: 'Icon name'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: screen.isEditing
                  ? const Color(0xFF16A34A)
                  : null,
            ),
            onPressed: _submit,
            child: Text(screen.isEditing ? 'Update Category' : 'Save Category'),
          ),
        ],
      ),
    );
  }
}

class _ColorPickerScreen extends StatelessWidget {
  const _ColorPickerScreen({
    required this.colorOptions,
    required this.selectedColor,
  });

  final List<String> colorOptions;
  final String selectedColor;

  Color _parseColor(String hex) {
    final normalized = hex.replaceFirst('#', '');
    return Color(int.parse('FF$normalized', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Color')),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: colorOptions.length,
        itemBuilder: (context, index) {
          final colorHex = colorOptions[index];
          final isSelected = colorHex == selectedColor;
          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => Navigator.of(context).pop(colorHex),
            child: Container(
              decoration: BoxDecoration(
                color: _parseColor(colorHex),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF111827)
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          );
        },
      ),
    );
  }
}
