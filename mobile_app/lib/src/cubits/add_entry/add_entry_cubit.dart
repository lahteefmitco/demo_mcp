import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_entry_state.dart';

class AddEntryCubit extends Cubit<AddEntryState> {
  AddEntryCubit({
    required String? initialCategoryUuid,
    required String? initialAccountUuid,
    required String initialDate,
  }) : super(
          AddEntryState(
            selectedCategoryUuid: initialCategoryUuid,
            selectedAccountUuid: initialAccountUuid,
            date: initialDate,
          ),
        );

  void selectCategory(String? uuid) {
    emit(state.copyWith(selectedCategoryUuid: uuid));
  }

  void selectAccount(String? uuid) {
    emit(state.copyWith(selectedAccountUuid: uuid));
  }

  void setDate(String value) {
    emit(state.copyWith(date: value));
  }
}

