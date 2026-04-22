class ForgotPasswordState {
  const ForgotPasswordState({
    required this.isSubmitting,
    required this.message,
    required this.toastMessage,
    required this.toastIsError,
    required this.toastNonce,
  });

  final bool isSubmitting;
  final String? message;

  /// UI event: show toast when [toastNonce] changes.
  final String? toastMessage;
  final bool toastIsError;
  final int toastNonce;

  const ForgotPasswordState.initial()
    : isSubmitting = false,
      message = null,
      toastMessage = null,
      toastIsError = false,
      toastNonce = 0;

  ForgotPasswordState copyWith({
    bool? isSubmitting,
    String? message,
    String? toastMessage,
    bool? toastIsError,
    int? toastNonce,
  }) {
    return ForgotPasswordState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      message: message,
      toastMessage: toastMessage,
      toastIsError: toastIsError ?? this.toastIsError,
      toastNonce: toastNonce ?? this.toastNonce,
    );
  }
}

extension ForgotPasswordToast on ForgotPasswordState {
  ForgotPasswordState toastError(String message) {
    return copyWith(
      toastMessage: message,
      toastIsError: true,
      toastNonce: toastNonce + 1,
    );
  }
}
