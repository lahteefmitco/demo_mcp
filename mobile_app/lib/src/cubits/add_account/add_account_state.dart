class AddAccountState {
  const AddAccountState({
    required this.selectedType,
    required this.selectedColor,
    required this.selectedIcon,
  });

  final String selectedType;
  final String selectedColor;
  final String selectedIcon;

  AddAccountState copyWith({
    String? selectedType,
    String? selectedColor,
    String? selectedIcon,
  }) {
    return AddAccountState(
      selectedType: selectedType ?? this.selectedType,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedIcon: selectedIcon ?? this.selectedIcon,
    );
  }
}
