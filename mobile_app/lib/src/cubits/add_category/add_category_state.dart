class AddCategoryState {
  const AddCategoryState({required this.kind, required this.selectedColor});

  final String kind;
  final String selectedColor;

  AddCategoryState copyWith({String? kind, String? selectedColor}) {
    return AddCategoryState(
      kind: kind ?? this.kind,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }
}
