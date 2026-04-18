import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../api/auth_api.dart';
import '../../models/auth_session.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthApi authApi,
    required Future<void> Function(AuthSession session) onAuthenticated,
  })  : _authApi = authApi,
        _onAuthenticated = onAuthenticated,
        super(const AuthState.initial());

  static const String _googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  final AuthApi _authApi;
  final Future<void> Function(AuthSession session) _onAuthenticated;

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile'],
    clientId: kIsWeb && _googleWebClientId.isNotEmpty ? _googleWebClientId : null,
    serverClientId:
        !kIsWeb && _googleWebClientId.isNotEmpty ? _googleWebClientId : null,
  );

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
    if (state.isSubmitting) {
      return;
    }

    if (kIsWeb && _googleWebClientId.isEmpty) {
      emit(
        state.toastError(
          'Google Sign-In on web requires --dart-define=GOOGLE_WEB_CLIENT_ID=...',
        ),
      );
      return;
    }

    emit(state.copyWith(isSubmitting: true, toastMessage: null));

    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        emit(state.copyWith(isSubmitting: false));
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        emit(state.toastError('Google did not return an ID token. Check OAuth client setup.'));
        return;
      }

      final session = await _authApi.loginWithGoogle(idToken: idToken);
      await _onAuthenticated(session);
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

