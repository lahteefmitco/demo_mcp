class AddBudgetState {
  const AddBudgetState({
    required this.period,
    required this.categoryUuid,
    required this.startDate,
  });

  final String period;
  final String? categoryUuid;
  final String startDate;

  AddBudgetState copyWith({
    String? period,
    String? categoryUuid,
    String? startDate,
  }) {
    return AddBudgetState(
      period: period ?? this.period,
      categoryUuid: categoryUuid,
      startDate: startDate ?? this.startDate,
    );
  }
}
