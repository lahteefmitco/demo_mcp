import '../../models/auth_session.dart';
import '../../models/currency_option.dart';

/// App-wide state.
///
/// Owns:
/// - first-run onboarding gate
/// - restoring session + currency
/// - authenticated vs unauthenticated shell
sealed class AppState {
  const AppState();
}

class AppBootstrapping extends AppState {
  const AppBootstrapping();
}

class AppNeedsOnboarding extends AppState {
  const AppNeedsOnboarding();
}

class AppUnauthenticated extends AppState {
  const AppUnauthenticated({required this.currency});

  final CurrencyOption currency;
}

class AppAuthenticated extends AppState {
  const AppAuthenticated({required this.session, required this.currency});

  final AuthSession session;
  final CurrencyOption currency;
}
