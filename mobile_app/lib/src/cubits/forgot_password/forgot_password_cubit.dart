import 'package:flutter_bloc/flutter_bloc.dart';

import '../../api/auth_api.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit({required AuthApi authApi})
    : _authApi = authApi,
      super(const ForgotPasswordState.initial());

  final AuthApi _authApi;

  Future<void> submit(String email) async {
    if (state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true, message: null, toastMessage: null));
    try {
      final message = await _authApi.requestPasswordReset(email.trim());
      emit(state.copyWith(message: message));
    } catch (e) {
      emit(state.toastError(e.toString().replaceFirst('Exception: ', '')));
    } finally {
      emit(state.copyWith(isSubmitting: false));
    }
  }
}
