import 'package:flutter_bloc/flutter_bloc.dart';

import 'shell_state.dart';

class ShellCubit extends Cubit<ShellState> {
  ShellCubit() : super(const ShellState(selectedIndex: 0));

  void selectTab(int index) {
    if (index == state.selectedIndex) {
      return;
    }
    emit(state.copyWith(selectedIndex: index));
  }
}
