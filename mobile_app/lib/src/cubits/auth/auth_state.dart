class AuthState {
  const AuthState({
    required this.isLogin,
    required this.isSubmitting,
    required this.infoMessage,
    required this.toastMessage,
    required this.toastIsError,
    required this.toastNonce,
  });

  final bool isLogin;
  final bool isSubmitting;
  final String? infoMessage;

  /// UI event: show toast when [toastNonce] changes.
  final String? toastMessage;
  final bool toastIsError;
  final int toastNonce;

  const AuthState.initial()
    : isLogin = true,
      isSubmitting = false,
      infoMessage = null,
      toastMessage = null,
      toastIsError = false,
      toastNonce = 0;

  AuthState copyWith({
    bool? isLogin,
    bool? isSubmitting,
    String? infoMessage,
    String? toastMessage,
    bool? toastIsError,
    int? toastNonce,
  }) {
    return AuthState(
      isLogin: isLogin ?? this.isLogin,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      infoMessage: infoMessage,
      toastMessage: toastMessage,
      toastIsError: toastIsError ?? this.toastIsError,
      toastNonce: toastNonce ?? this.toastNonce,
    );
  }
}

extension AuthStateToast on AuthState {
  AuthState toastError(String message) {
    return copyWith(
      toastMessage: message,
      toastIsError: true,
      toastNonce: toastNonce + 1,
    );
  }
}
