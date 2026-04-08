import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_transfer_state.dart';

class AddTransferCubit extends Cubit<AddTransferState> {
  AddTransferCubit({
    required String? initialFromAccountUuid,
    required String? initialToAccountUuid,
  }) : super(
          AddTransferState(
            fromAccountUuid: initialFromAccountUuid,
            toAccountUuid: initialToAccountUuid,
          ),
        );

  void setFrom(String? uuid) => emit(state.copyWith(fromAccountUuid: uuid));

  void setTo(String? uuid) => emit(state.copyWith(toAccountUuid: uuid));
}

