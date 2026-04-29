class AddCategoryState {
  const AddCategoryState({
    required this.kind,
    required this.selectedColor,
    this.parentId,
  });

  final String kind;
  final String selectedColor;
  final String? parentId;

  AddCategoryState copyWith({String? kind, String? selectedColor, String? parentId}) {
    return AddCategoryState(
      kind: kind ?? this.kind,
      selectedColor: selectedColor ?? this.selectedColor,
      parentId: parentId ?? this.parentId,
    );
  }
}
