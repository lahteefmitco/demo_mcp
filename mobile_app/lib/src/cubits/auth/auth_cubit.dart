import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../api/auth_api.dart';
import '../../models/auth_session.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthApi authApi,
    required Future<void> Function(AuthSession session) onAuthenticated,
  }) : _authApi = authApi,
       _onAuthenticated = onAuthenticated,
       super(const AuthState.initial());

  final AuthApi _authApi;
  final Future<void> Function(AuthSession session) _onAuthenticated;

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

    emit(
      state.copyWith(isSubmitting: true, infoMessage: null, toastMessage: null),
    );

    try {
      final trimmedEmail = email.trim();
      if (state.isLogin) {
        final session = await _authApi.login(
          email: trimmedEmail,
          password: password,
        );
        await _onAuthenticated(session);
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

  Future<void> signInWithGoogle() async {
    log('signInWithGoogle');
    if (state.isSubmitting) return;

    emit(
      state.copyWith(isSubmitting: true, infoMessage: null, toastMessage: null),
    );

    try {
      log('authenticate');
      final account = await GoogleSignIn.instance.authenticate();
      log('account: $account');
      final auth = account.authentication;
      final idToken = auth.idToken;

      log('idToken: $idToken');

      if (idToken == null) {
        throw Exception('Failed to get Google ID token');
      }

      final session = await _authApi.loginWithGoogle(idToken);
      await _onAuthenticated(session);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        // Treat as non-error: user dismissed, or the activity was interrupted.
        log('Google Sign-In canceled/interrupted (code: ${e.code}).');
        return;
      }

      log(
        'Google Sign-In failed (code: ${e.code}).',
        error: e,
      );
      emit(
        state.toastError(
          'Google Sign-In failed (${e.code}). Please try again.',
        ),
      );
    } catch (e) {
      log('Google Sign-In failed.', error: e);
      emit(state.toastError(e.toString().replaceFirst('Exception: ', '')));
    } finally {
      emit(state.copyWith(isSubmitting: false));
    }
  }
}
