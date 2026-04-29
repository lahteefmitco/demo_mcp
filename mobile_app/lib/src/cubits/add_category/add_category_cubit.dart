import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_category_state.dart';

class AddCategoryCubit extends Cubit<AddCategoryState> {
  AddCategoryCubit({
    required String initialKind,
    required String initialColor,
    String? initialParentId,
  }) : super(AddCategoryState(
      kind: initialKind,
      selectedColor: initialColor,
      parentId: initialParentId,
    ));

  void setKind(String value) => emit(state.copyWith(kind: value));

  void setColor(String value) => emit(state.copyWith(selectedColor: value));

  void setParentId(String? value) => emit(state.copyWith(parentId: value));
}
