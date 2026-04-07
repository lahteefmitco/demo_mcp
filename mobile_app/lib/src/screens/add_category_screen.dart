import 'package:flutter/material.dart';

import '../models/finance_models.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key, this.category});

  final FinanceCategory? category;

  bool get isEditing => category != null;

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
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

  late final TextEditingController _nameController;
  late final TextEditingController _iconController;
  late String _kind;
  late String _selectedColor;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _nameController = TextEditingController(text: category?.name ?? '');
    _iconController = TextEditingController(text: category?.icon ?? 'tag');
    _kind = category?.kind ?? 'expense';
    _selectedColor = category?.color ?? '#0E7490';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = <String, dynamic>{
      'name': _nameController.text.trim(),
      'kind': _kind,
      'color': _selectedColor,
      'icon': _iconController.text.trim(),
    };

    if (widget.isEditing) {
      result['uuid'] = widget.category!.uuid;
    }

    Navigator.of(context).pop(result);
  }

  Color _parseColor(String hex) {
    final normalized = hex.replaceFirst('#', '');
    return Color(int.parse('FF$normalized', radix: 16));
  }

  Future<void> _pickColor() async {
    final selected = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => _ColorPickerScreen(
          colorOptions: _colorOptions,
          selectedColor: _selectedColor,
        ),
      ),
    );

    if (!mounted || selected == null) {
      return;
    }

    setState(() {
      _selectedColor = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final previewColor = _parseColor(_selectedColor);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Category' : 'Add Category'),
      ),
      body: Form(
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
              initialValue: _kind,
              decoration: const InputDecoration(labelText: 'Kind'),
              items: const [
                DropdownMenuItem(value: 'expense', child: Text('Expense')),
                DropdownMenuItem(value: 'income', child: Text('Income')),
                DropdownMenuItem(value: 'both', child: Text('Both')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _kind = value;
                  });
                }
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
                      _selectedColor,
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
                backgroundColor: widget.isEditing
                    ? const Color(0xFF16A34A)
                    : null,
              ),
              onPressed: _submit,
              child: Text(
                widget.isEditing ? 'Update Category' : 'Save Category',
              ),
            ),
          ],
        ),
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
