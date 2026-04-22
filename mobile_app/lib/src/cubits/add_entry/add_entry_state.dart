class AddEntryState {
  const AddEntryState({
    required this.selectedCategoryUuid,
    required this.selectedAccountUuid,
    required this.date,
  });

  final String? selectedCategoryUuid;
  final String? selectedAccountUuid;
  final String date;

  AddEntryState copyWith({
    String? selectedCategoryUuid,
    String? selectedAccountUuid,
    String? date,
  }) {
    return AddEntryState(
      selectedCategoryUuid: selectedCategoryUuid ?? this.selectedCategoryUuid,
      selectedAccountUuid: selectedAccountUuid ?? this.selectedAccountUuid,
      date: date ?? this.date,
    );
  }
}
