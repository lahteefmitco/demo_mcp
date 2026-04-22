import 'package:flutter_bloc/flutter_bloc.dart';

import '../../api/auth_api.dart';
import '../../auth/auth_storage.dart';
import '../../database/finance_database_holder.dart';
import '../../models/auth_session.dart';
import '../../models/currency_option.dart';
import '../../repository/finance_repository.dart';
import '../../settings/app_preferences_storage.dart';
import '../../sync/background_sync.dart';
import '../../utils/app_logger.dart';
import '../../utils/currency_utils.dart';
import 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit({
    required AuthStorage authStorage,
    required AppPreferencesStorage preferencesStorage,
    required AuthApi authApi,
  }) : _authStorage = authStorage,
       _preferencesStorage = preferencesStorage,
       _authApi = authApi,
       super(const AppBootstrapping());

  final AuthStorage _authStorage;
  final AppPreferencesStorage _preferencesStorage;
  final AuthApi _authApi;

  static const _minSplash = Duration(milliseconds: 1500);

  /// Bootstraps the app from local state.
  ///
  /// Business rules:
  /// - Always restore currency.
  /// - Restore session if possible (token -> /me).
  /// - If onboarding isn't completed, show onboarding once per device.
  Future<void> bootstrap() async {
    final stopwatch = Stopwatch()..start();
    emit(const AppBootstrapping());

    final onboardingDone = await _preferencesStorage.readOnboardingCompleted();

    try {
      // Currency
      var code = await _preferencesStorage.readCurrencyCode();
      if (code == null || code.isEmpty) {
        await _preferencesStorage.writeCurrencyCode(defaultCurrency.code);
        code = defaultCurrency.code;
      }
      final storedCurrency = currencyFromCode(code);

      // Session
      AuthSession? session;
      final stored = await _authStorage.readSession();
      if (stored != null) {
        try {
          final currentUser = await _authApi.fetchCurrentUser(stored.token);
          session = AuthSession(token: stored.token, user: currentUser);
        } catch (e, st) {
          AppLogger.i(
            'Session restore failed, clearing token',
            error: e,
            stackTrace: st,
          );
          await _authStorage.clear();
        }
      }

      final elapsed = stopwatch.elapsed;
      if (elapsed < _minSplash) {
        await Future<void>.delayed(_minSplash - elapsed);
      }

      if (!onboardingDone) {
        emit(const AppNeedsOnboarding());
        return;
      }

      if (session == null) {
        emit(AppUnauthenticated(currency: storedCurrency));
        return;
      }

      await _importFinanceFromServer(session.token);
      BackgroundSync.registerPeriodicSync();
      emit(AppAuthenticated(session: session, currency: storedCurrency));
    } catch (e, st) {
      AppLogger.e('Bootstrap failed', error: e, stackTrace: st);

      final elapsed = stopwatch.elapsed;
      if (elapsed < _minSplash) {
        await Future<void>.delayed(_minSplash - elapsed);
      }

      final storedCurrency = defaultCurrency;
      if (!onboardingDone) {
        emit(const AppNeedsOnboarding());
      } else {
        emit(AppUnauthenticated(currency: storedCurrency));
      }
    }
  }

  Future<void> completeOnboarding() async {
    await _preferencesStorage.writeOnboardingCompleted(true);
    await bootstrap();
  }

  Future<void> setCurrency(CurrencyOption currency) async {
    await _preferencesStorage.writeCurrencyCode(currency.code);
    final state = this.state;
    if (state is AppAuthenticated) {
      emit(AppAuthenticated(session: state.session, currency: currency));
    } else if (state is AppUnauthenticated) {
      emit(AppUnauthenticated(currency: currency));
    }
  }

  Future<void> authenticated(AuthSession session) async {
    await _authStorage.writeSession(session);
    final state = this.state;
    final currency = state is AppAuthenticated
        ? state.currency
        : state is AppUnauthenticated
        ? state.currency
        : defaultCurrency;
    await _importFinanceFromServer(session.token);
    BackgroundSync.registerPeriodicSync();
    emit(AppAuthenticated(session: session, currency: currency));
  }

  Future<void> _importFinanceFromServer(String token) async {
    try {
      final repo = FinanceRepository(
        database: FinanceDatabaseHolder.instance,
        token: token,
      );
      await repo.importAllFromServer();
    } catch (e, st) {
      AppLogger.e('Finance import after auth failed', error: e, stackTrace: st);
    }
  }

  Future<void> sessionUpdated(AuthSession session) async {
    await _authStorage.writeSession(session);
    final state = this.state;
    if (state is AppAuthenticated) {
      emit(AppAuthenticated(session: session, currency: state.currency));
    }
  }

  Future<void> logout() async {
    await BackgroundSync.cancelPeriodicSync();
    await _authStorage.clear();
    final state = this.state;
    final currency = state is AppAuthenticated
        ? state.currency
        : defaultCurrency;
    emit(AppUnauthenticated(currency: currency));
  }
}
