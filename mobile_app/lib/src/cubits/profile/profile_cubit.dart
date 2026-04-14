import 'package:flutter_bloc/flutter_bloc.dart';

import '../../api/auth_api.dart';
import '../../models/auth_session.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required AuthApi authApi,
    required AuthSession session,
    required Future<void> Function(AuthSession session) onSessionUpdated,
  })  : _authApi = authApi,
        _onSessionUpdated = onSessionUpdated,
        super(ProfileState.initial(session));

  final AuthApi _authApi;
  final Future<void> Function(AuthSession session) _onSessionUpdated;

  Future<void> saveName(String name) async {
    final trimmed = name.trim();
    if (state.isSavingName || trimmed.length < 2) return;

    emit(state.copyWith(isSavingName: true, toastMessage: null));
    try {
      final user = await _authApi.updateProfile(
        token: state.session.token,
        name: trimmed,
      );
      final updated = state.session.copyWith(user: user);
      await _onSessionUpdated(updated);
      emit(state.copyWith(session: updated));
      emit(state.toastSuccess('Name updated'));
    } catch (e) {
      emit(state.toastError(e.toString().replaceFirst('Exception: ', '')));
    } finally {
      emit(state.copyWith(isSavingName: false));
    }
  }

  Future<void> requestEmailChange(String email) async {
    final trimmed = email.trim();
    if (state.isRequestingEmailChange || !trimmed.contains('@')) return;

    emit(state.copyWith(isRequestingEmailChange: true, toastMessage: null));
    try {
      final message = await _authApi.requestEmailChange(
        token: state.session.token,
        email: trimmed,
      );
      final updated = state.session.copyWith(
        user: state.session.user.copyWith(pendingEmail: trimmed),
      );
      await _onSessionUpdated(updated);
      emit(state.copyWith(session: updated));
      emit(state.toastSuccess(message));
    } catch (e) {
      emit(state.toastError(e.toString().replaceFirst('Exception: ', '')));
    } finally {
      emit(state.copyWith(isRequestingEmailChange: false));
    }
  }
}

