import 'dart:async';
import 'dart:developer';

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
  }) : _authApi = authApi,
       _onAuthenticated = onAuthenticated,
       super(const AuthState.initial()) {
    if (kIsWeb) {
      _googleAuthSubscription = GoogleSignIn.instance.authenticationEvents.listen(
        _onGoogleAuthenticationEvent,
        onError: (Object e, StackTrace st) {
          log('Google Sign-In stream error.', error: e, stackTrace: st);
          if (!isClosed) {
            emit(state.toastError(e.toString().replaceFirst('Exception: ', '')));
          }
        },
      );
    }
  }

  final AuthApi _authApi;
  final Future<void> Function(AuthSession session) _onAuthenticated;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _googleAuthSubscription;

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

  /// Mobile/desktop: starts the platform authenticate flow.
  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      return;
    }
    if (state.isSubmitting) return;

    emit(
      state.copyWith(isSubmitting: true, infoMessage: null, toastMessage: null),
    );

    try {
      final account = await GoogleSignIn.instance.authenticate();
      await _completeGoogleSignIn(account);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        log('Google Sign-In canceled/interrupted (code: ${e.code}).');
        return;
      }

      log('Google Sign-In failed (code: ${e.code}).', error: e);
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

  Future<void> _onGoogleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    switch (event) {
      case GoogleSignInAuthenticationEventSignIn():
        if (state.isSubmitting) return;
        emit(
          state.copyWith(
            isSubmitting: true,
            infoMessage: null,
            toastMessage: null,
          ),
        );
        try {
          await _completeGoogleSignIn(event.user);
        } on GoogleSignInException catch (e) {
          if (e.code == GoogleSignInExceptionCode.canceled ||
              e.code == GoogleSignInExceptionCode.interrupted) {
            return;
          }
          emit(
            state.toastError(
              'Google Sign-In failed (${e.code}). Please try again.',
            ),
          );
        } catch (e) {
          emit(state.toastError(e.toString().replaceFirst('Exception: ', '')));
        } finally {
          if (!isClosed) {
            emit(state.copyWith(isSubmitting: false));
          }
        }
      case GoogleSignInAuthenticationEventSignOut():
        break;
    }
  }

  Future<void> _completeGoogleSignIn(GoogleSignInAccount account) async {
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw Exception('Failed to get Google ID token');
    }

    final session = await _authApi.loginWithGoogle(idToken);
    await _onAuthenticated(session);
  }

  @override
  Future<void> close() {
    unawaited(_googleAuthSubscription?.cancel());
    return super.close();
  }
}
