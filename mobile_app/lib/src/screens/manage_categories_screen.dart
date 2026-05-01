import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/settings/settings_cubit.dart';
import '../cubits/settings/settings_state.dart';
import '../models/finance_models.dart';
import '../repository/finance_repository.dart';
import '../utils/finance_repository_scope.dart';
import 'add_category_screen.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final Set<String> _expandedCategoryIds = <String>{};

  Future<void> _createCategory(BuildContext context) async {
    final cubit = context.read<SettingsCubit>();
    final payload = await pushRouteWithFinanceRepository<Map<String, dynamic>>(
      context,
      AddCategoryScreen(repository: context.read<FinanceRepository>()),
    );

    if (!context.mounted || payload == null) {
      return;
    }

    await cubit.createCategory(
      name: payload['name'] as String,
      kind: payload['kind'] as String,
      color: payload['color'] as String,
      icon: payload['icon'] as String,
      parentId: payload['parentId'] as String?,
    );
  }

  Future<void> _editCategory(
    BuildContext context,
    FinanceCategory category,
  ) async {
    final cubit = context.read<SettingsCubit>();
    final payload = await pushRouteWithFinanceRepository<Map<String, dynamic>>(
      context,
      AddCategoryScreen(
        category: category,
        repository: context.read<FinanceRepository>(),
      ),
    );

    if (!context.mounted || payload == null) {
      return;
    }

    await cubit.updateCategory(
      uuid: payload['uuid'] as String,
      name: payload['name'] as String,
      kind: payload['kind'] as String,
      color: payload['color'] as String,
      icon: payload['icon'] as String,
      parentId: payload['parentId'] as String?,
    );
  }

  Future<void> _deleteCategory(
    BuildContext context,
    FinanceCategory category,
  ) async {
    final cubit = context.read<SettingsCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!context.mounted || confirmed != true) {
      return;
    }

    await cubit.deleteCategoryByUuid(category.uuid);
  }

  void _toggleExpanded(String categoryId) {
    setState(() {
      if (_expandedCategoryIds.contains(categoryId)) {
        _expandedCategoryIds.remove(categoryId);
      } else {
        _expandedCategoryIds.add(categoryId);
      }
    });
  }

  String? _normalizeParentId(
    FinanceCategory category,
    Map<String, FinanceCategory> categoriesByUuid,
    Map<String, FinanceCategory> categoriesById,
  ) {
    final parentId = category.parentId;
    if (parentId == null || parentId.isEmpty) {
      return null;
    }
    if (categoriesByUuid.containsKey(parentId)) {
      return parentId;
    }
    return categoriesById[parentId]?.uuid;
  }

  Map<String?, List<FinanceCategory>> _buildChildrenMap(
    List<FinanceCategory> categories,
  ) {
    final categoriesByUuid = {
      for (final category in categories) category.uuid: category,
    };
    final categoriesById = {
      for (final category in categories)
        if (category.id > 0) category.id.toString(): category,
    };
    final childrenByParent = <String?, List<FinanceCategory>>{};

    for (final category in categories) {
      final parentKey = _normalizeParentId(
        category,
        categoriesByUuid,
        categoriesById,
      );
      childrenByParent.putIfAbsent(parentKey, () => <FinanceCategory>[]).add(
        category,
      );
    }

    for (final entry in childrenByParent.entries) {
      entry.value.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    return childrenByParent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Categories')),
      body: FutureBuilder<SettingsData>(
        future: context.watch<SettingsCubit>().state.future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.category_outlined, size: 52),
                    const SizedBox(height: 12),
                    Text(
                      'Could not load categories',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final categories = snapshot.data?.dashboard.categories ?? const <FinanceCategory>[];
          final childrenByParent = _buildChildrenMap(categories);
          final topLevelCategories = childrenByParent[null] ?? const <FinanceCategory>[];

          if (topLevelCategories.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<SettingsCubit>().refresh(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  _EmptyCategoryCard(
                    message:
                        'No categories found. Use the add button to create your first category.',
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<SettingsCubit>().refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: topLevelCategories.length,
              itemBuilder: (context, index) {
                final category = topLevelCategories[index];
                return _CategoryTreeTile(
                  category: category,
                  depth: 0,
                  childrenByParent: childrenByParent,
                  expandedCategoryIds: _expandedCategoryIds,
                  onToggleExpanded: _toggleExpanded,
                  onEditCategory: (selectedCategory) =>
                      _editCategory(context, selectedCategory),
                  onDeleteCategory: (selectedCategory) =>
                      _deleteCategory(context, selectedCategory),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createCategory(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }
}

class _CategoryTreeTile extends StatelessWidget {
  const _CategoryTreeTile({
    required this.category,
    required this.depth,
    required this.childrenByParent,
    required this.expandedCategoryIds,
    required this.onToggleExpanded,
    required this.onEditCategory,
    required this.onDeleteCategory,
  });

  final FinanceCategory category;
  final int depth;
  final Map<String?, List<FinanceCategory>> childrenByParent;
  final Set<String> expandedCategoryIds;
  final ValueChanged<String> onToggleExpanded;
  final ValueChanged<FinanceCategory> onEditCategory;
  final ValueChanged<FinanceCategory> onDeleteCategory;

  Color _parseColor(String hex) {
    final normalized = hex.replaceFirst('#', '');
    return Color(int.parse('FF$normalized', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final children = childrenByParent[category.uuid] ?? const <FinanceCategory>[];
    final hasChildren = children.isNotEmpty;
    final isExpanded = expandedCategoryIds.contains(category.uuid);
    final color = _parseColor(category.color);
    final childCountLabel = children.length == 1
        ? '1 child category'
        : '${children.length} child categories';
    final subtitleParts = <String>[
      category.kind,
      if (hasChildren) childCountLabel,
    ];

    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0, bottom: 12),
      child: Card(
        child: Column(
          children: [
            ListTile(
              onTap: hasChildren ? () => onToggleExpanded(category.uuid) : null,
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.18),
                child: Icon(Icons.tag, color: color),
              ),
              title: Text(category.name),
              subtitle: Text(subtitleParts.join(' • ')),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasChildren)
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: isExpanded ? 0.5 : 0,
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEditCategory(category);
                      } else if (value == 'delete') {
                        onDeleteCategory(category);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                child: isExpanded
                    ? Column(
                        children: [
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                            child: Column(
                              children: children
                                  .map(
                                    (child) => _CategoryTreeTile(
                                      category: child,
                                      depth: depth + 1,
                                      childrenByParent: childrenByParent,
                                      expandedCategoryIds: expandedCategoryIds,
                                      onToggleExpanded: onToggleExpanded,
                                      onEditCategory: onEditCategory,
                                      onDeleteCategory: onDeleteCategory,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCategoryCard extends StatelessWidget {
  const _EmptyCategoryCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(message),
      ),
    );
  }
}
