import '../../models/finance_models.dart';

class HomeState {
  const HomeState({
    required this.isLoading,
    required this.dashboard,
    required this.errorMessage,
    required this.toastNonce,
    required this.toastMessage,
    required this.toastIsError,
  });

  final bool isLoading;
  final FinanceDashboard? dashboard;
  final String? errorMessage;

  /// One-shot toast event.
  final int toastNonce;
  final String? toastMessage;
  final bool toastIsError;

  factory HomeState.initial() => const HomeState(
        isLoading: true,
        dashboard: null,
        errorMessage: null,
        toastNonce: 0,
        toastMessage: null,
        toastIsError: false,
      );

  HomeState copyWith({
    bool? isLoading,
    FinanceDashboard? dashboard,
    String? errorMessage,
    int? toastNonce,
    String? toastMessage,
    bool? toastIsError,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      dashboard: dashboard ?? this.dashboard,
      errorMessage: errorMessage,
      toastNonce: toastNonce ?? this.toastNonce,
      toastMessage: toastMessage,
      toastIsError: toastIsError ?? this.toastIsError,
    );
  }
}

