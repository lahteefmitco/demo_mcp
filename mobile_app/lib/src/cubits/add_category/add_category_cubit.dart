import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_category_state.dart';

class AddCategoryCubit extends Cubit<AddCategoryState> {
  AddCategoryCubit({required String initialKind, required String initialColor})
    : super(AddCategoryState(kind: initialKind, selectedColor: initialColor));

  void setKind(String value) => emit(state.copyWith(kind: value));

  void setColor(String value) => emit(state.copyWith(selectedColor: value));
}
