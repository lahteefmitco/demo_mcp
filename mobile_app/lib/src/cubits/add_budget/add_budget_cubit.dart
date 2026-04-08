import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_budget_state.dart';

class AddBudgetCubit extends Cubit<AddBudgetState> {
  AddBudgetCubit({
    required String initialPeriod,
    required String? initialCategoryUuid,
    required String initialStartDate,
  }) : super(
          AddBudgetState(
            period: initialPeriod,
            categoryUuid: initialCategoryUuid,
            startDate: initialStartDate,
          ),
        );

  void setPeriod(String value) => emit(state.copyWith(period: value));

  void setCategoryUuid(String? value) =>
      emit(state.copyWith(categoryUuid: value));

  void setStartDate(String value) => emit(state.copyWith(startDate: value));
}

