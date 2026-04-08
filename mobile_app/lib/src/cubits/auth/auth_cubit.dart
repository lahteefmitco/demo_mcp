import 'package:flutter_bloc/flutter_bloc.dart';

import '../../api/auth_api.dart';
import '../../models/auth_session.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthApi authApi,
    required void Function(AuthSession session) onAuthenticated,
  })  : _authApi = authApi,
        _onAuthenticated = onAuthenticated,
        super(const AuthState.initial());

  final AuthApi _authApi;
  final void Function(AuthSession session) _onAuthenticated;

  void toggleMode() {
    emit(
      state.copyWith(
        isLogin: !state.isLogin,
        infoMessage: null,
        toastMessage: null,
      ),
    );
  }

  Future<void> submit({
    required String name,
    required String email,
    required String password,
  }) async {
    if (state.isSubmitting) {
      return;
    }

    emit(state.copyWith(isSubmitting: true, infoMessage: null, toastMessage: null));

    try {
      final trimmedEmail = email.trim();
      if (state.isLogin) {
        final session = await _authApi.login(
          email: trimmedEmail,
          password: password,
        );
        _onAuthenticated(session);
      } else {
        final message = await _authApi.register(
          name: name.trim(),
          email: trimmedEmail,
          password: password,
        );
        emit(
          state.copyWith(
            isLogin: true,
            infoMessage: message,
            toastMessage: null,
          ),
        );
      }
    } catch (e) {
      emit(state.toastError(e.toString().replaceFirst('Exception: ', '')));
    } finally {
      emit(state.copyWith(isSubmitting: false));
    }
  }

  Future<void> resendVerification(String email) async {
    if (state.isSubmitting) {
      return;
    }

    final trimmed = email.trim();
    if (!trimmed.contains('@')) {
      emit(state.toastError('Enter your email first'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, toastMessage: null));
    try {
      final message = await _authApi.resendVerificationEmail(trimmed);
      emit(state.copyWith(infoMessage: message));
    } catch (e) {
      emit(state.toastError(e.toString().replaceFirst('Exception: ', '')));
    } finally {
      emit(state.copyWith(isSubmitting: false));
    }
  }
}

