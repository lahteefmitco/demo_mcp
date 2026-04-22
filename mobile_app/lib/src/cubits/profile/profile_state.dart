import '../../models/auth_session.dart';

class ProfileState {
  const ProfileState({
    required this.session,
    required this.isSavingName,
    required this.isRequestingEmailChange,
    required this.toastMessage,
    required this.toastIsError,
    required this.toastNonce,
  });

  final AuthSession session;
  final bool isSavingName;
  final bool isRequestingEmailChange;

  /// UI event: show toast when [toastNonce] changes.
  final String? toastMessage;
  final bool toastIsError;
  final int toastNonce;

  factory ProfileState.initial(AuthSession session) {
    return ProfileState(
      session: session,
      isSavingName: false,
      isRequestingEmailChange: false,
      toastMessage: null,
      toastIsError: false,
      toastNonce: 0,
    );
  }

  ProfileState copyWith({
    AuthSession? session,
    bool? isSavingName,
    bool? isRequestingEmailChange,
    String? toastMessage,
    bool? toastIsError,
    int? toastNonce,
  }) {
    return ProfileState(
      session: session ?? this.session,
      isSavingName: isSavingName ?? this.isSavingName,
      isRequestingEmailChange:
          isRequestingEmailChange ?? this.isRequestingEmailChange,
      toastMessage: toastMessage,
      toastIsError: toastIsError ?? this.toastIsError,
      toastNonce: toastNonce ?? this.toastNonce,
    );
  }
}

extension ProfileToast on ProfileState {
  ProfileState toastSuccess(String message) {
    return copyWith(
      toastMessage: message,
      toastIsError: false,
      toastNonce: toastNonce + 1,
    );
  }

  ProfileState toastError(String message) {
    return copyWith(
      toastMessage: message,
      toastIsError: true,
      toastNonce: toastNonce + 1,
    );
  }
}
