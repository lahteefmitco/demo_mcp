class AddCategoryState {
  const AddCategoryState({
    required this.kind,
    required this.selectedColor,
    this.parentId,
  });

  final String kind;
  final String selectedColor;
  final String? parentId;

  AddCategoryState copyWith({
    String? kind,
    String? selectedColor,
    Object? parentId = _noChange,
  }) {
    return AddCategoryState(
      kind: kind ?? this.kind,
      selectedColor: selectedColor ?? this.selectedColor,
      parentId: identical(parentId, _noChange)
          ? this.parentId
          : parentId as String?,
    );
  }
}

const Object _noChange = Object();
