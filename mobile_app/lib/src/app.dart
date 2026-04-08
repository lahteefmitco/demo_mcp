import 'package:flutter/material.dart';

import 'api/auth_api.dart';
import 'auth/auth_storage.dart';
import 'models/auth_session.dart';
import 'models/currency_option.dart';
import 'screens/auth_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'database/finance_database_holder.dart';
import 'repository/finance_repository.dart';
import 'settings/app_preferences_storage.dart';
import 'sync/background_sync.dart';
import 'theme/app_theme.dart';
import 'utils/currency_utils.dart';

class ExpenseMobileApp extends StatefulWidget {
  const ExpenseMobileApp({super.key});

  @override
  State<ExpenseMobileApp> createState() => _ExpenseMobileAppState();
}

class _ExpenseMobileAppState extends State<ExpenseMobileApp> {
  final AuthStorage _authStorage = AuthStorage();
  final AppPreferencesStorage _preferencesStorage = AppPreferencesStorage();
  final AuthApi _authApi = AuthApi();
  AuthSession? _session;
  bool _isBootstrapping = true;
  bool _needsOnboarding = false;
  CurrencyOption _selectedCurrency = defaultCurrency;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  static const _minSplash = Duration(milliseconds: 1500);

  Future<void> _bootstrap() async {
    final stopwatch = Stopwatch()..start();
    final onboardingDone = await _preferencesStorage.readOnboardingCompleted();

    try {
      var code = await _preferencesStorage.readCurrencyCode();
      if (code == null || code.isEmpty) {
        await _preferencesStorage.writeCurrencyCode(defaultCurrency.code);
        code = defaultCurrency.code;
      }
      final storedCurrency = currencyFromCode(code);

      AuthSession? session;
      final stored = await _authStorage.readSession();
      if (stored != null) {
        try {
          final currentUser = await _authApi.fetchCurrentUser(stored.token);
          session = AuthSession(token: stored.token, user: currentUser);
        } catch (_) {
          await _authStorage.clear();
        }
      }

      final elapsed = stopwatch.elapsed;
      if (elapsed < _minSplash) {
        await Future<void>.delayed(_minSplash - elapsed);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _session = session;
        _selectedCurrency = storedCurrency;
        _needsOnboarding = !onboardingDone;
        _isBootstrapping = false;
      });
    } catch (_) {
      await _authStorage.clear();
      final elapsed = stopwatch.elapsed;
      if (elapsed < _minSplash) {
        await Future<void>.delayed(_minSplash - elapsed);
      }
      if (!mounted) {
        return;
      }

      setState(() {
        _session = null;
        _selectedCurrency = defaultCurrency;
        _needsOnboarding = !onboardingDone;
        _isBootstrapping = false;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    await _preferencesStorage.writeOnboardingCompleted(true);
    if (!mounted) {
      return;
    }
    setState(() {
      _needsOnboarding = false;
    });
  }

  Future<void> _handleCurrencyChanged(CurrencyOption currency) async {
    await _preferencesStorage.writeCurrencyCode(currency.code);
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedCurrency = currency;
    });
  }

  Future<void> _handleAuthenticated(AuthSession session) async {
    await _authStorage.writeSession(session);
    if (!mounted) {
      return;
    }

    setState(() {
      _session = session;
    });
  }

  Future<void> _handleSessionUpdated(AuthSession session) async {
    await _authStorage.writeSession(session);
    if (!mounted) {
      return;
    }

    setState(() {
      _session = session;
    });
  }

  Future<void> _logout() async {
    await BackgroundSync.cancelPeriodicSync();
    await _authStorage.clear();
    if (!mounted) {
      return;
    }

    setState(() {
      _session = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Mobile',
      debugShowCheckedModeBanner: false,
      theme: ExpenseAppTheme.light(),
      home: _isBootstrapping
          ? const SplashScreen()
          : _needsOnboarding
          ? OnboardingScreen(onComplete: _completeOnboarding)
          : _session == null
          ? AuthScreen(onAuthenticated: _handleAuthenticated)
          : AppShell(
              session: _session!,
              onLogout: _logout,
              onSessionUpdated: _handleSessionUpdated,
              selectedCurrency: _selectedCurrency,
              onCurrencyChanged: _handleCurrencyChanged,
            ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({
    required this.session,
    required this.onLogout,
    required this.onSessionUpdated,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
    super.key,
  });

  final AuthSession session;
  final Future<void> Function() onLogout;
  final Future<void> Function(AuthSession session) onSessionUpdated;
  final CurrencyOption selectedCurrency;
  final Future<void> Function(CurrencyOption currency) onCurrencyChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  late final FinanceRepository _financeRepository;

  @override
  void initState() {
    super.initState();
    _financeRepository = FinanceRepository(
      database: FinanceDatabaseHolder.instance,
      token: widget.session.token,
    );
    BackgroundSync.registerPeriodicSync();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        session: widget.session,
        repository: _financeRepository,
        currency: widget.selectedCurrency,
        isActiveTab: _selectedIndex == 0,
        onOpenProfile: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProfileScreen(
                session: widget.session,
                onSessionUpdated: widget.onSessionUpdated,
              ),
            ),
          );
        },
      ),
      DashboardScreen(
        session: widget.session,
        repository: _financeRepository,
        currency: widget.selectedCurrency,
        isActiveTab: _selectedIndex == 1,
      ),
      ChatScreen(
        session: widget.session,
        currency: widget.selectedCurrency,
        isActiveTab: _selectedIndex == 2,
        onOpenProfile: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProfileScreen(
                session: widget.session,
                onSessionUpdated: widget.onSessionUpdated,
              ),
            ),
          );
        },
      ),
      SettingsScreen(
        session: widget.session,
        repository: _financeRepository,
        currency: widget.selectedCurrency,
        isActiveTab: _selectedIndex == 3,
        onCurrencyChanged: widget.onCurrencyChanged,
        onLogout: widget.onLogout,
        onOpenProfile: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProfileScreen(
                session: widget.session,
                onSessionUpdated: widget.onSessionUpdated,
              ),
            ),
          );
        },
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
