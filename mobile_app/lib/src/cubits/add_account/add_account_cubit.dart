import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_account_state.dart';

class AddAccountCubit extends Cubit<AddAccountState> {
  AddAccountCubit({
    required String initialType,
    required String initialColor,
    required String initialIcon,
  }) : super(
          AddAccountState(
            selectedType: initialType,
            selectedColor: initialColor,
            selectedIcon: initialIcon,
          ),
        );

  void setType(String value) => emit(state.copyWith(selectedType: value));

  void setColor(String value) => emit(state.copyWith(selectedColor: value));

  void setIcon(String value) => emit(state.copyWith(selectedIcon: value));
}

