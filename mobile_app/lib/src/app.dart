import 'package:flutter/material.dart';

import 'api/auth_api.dart';
import 'auth/auth_storage.dart';
import 'models/auth_session.dart';
import 'models/currency_option.dart';
import 'screens/auth_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'database/finance_database_holder.dart';
import 'repository/finance_repository.dart';
import 'settings/app_preferences_storage.dart';
import 'sync/background_sync.dart';
import 'utils/currency_utils.dart';

class ExpenseMobileApp extends StatefulWidget {
  const ExpenseMobileApp({super.key});

  @override
  State<ExpenseMobileApp> createState() => _ExpenseMobileAppState();
}

class _ExpenseMobileAppState extends State<ExpenseMobileApp> {
  static const _seedColor = Color(0xFF0E7490);
  final AuthStorage _authStorage = AuthStorage();
  final AppPreferencesStorage _preferencesStorage = AppPreferencesStorage();
  final AuthApi _authApi = AuthApi();
  AuthSession? _session;
  bool _isLoadingSession = true;
  CurrencyOption _selectedCurrency = defaultCurrency;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final storedCurrencyCode = await _preferencesStorage.readCurrencyCode();
      if (storedCurrencyCode == null || storedCurrencyCode.isEmpty) {
        await _preferencesStorage.writeCurrencyCode(defaultCurrency.code);
      }
      final storedCurrency = currencyFromCode(storedCurrencyCode);
      final stored = await _authStorage.readSession();
      if (stored == null) {
        if (!mounted) {
          return;
        }

        setState(() {
          _selectedCurrency = storedCurrency;
          _isLoadingSession = false;
        });
        return;
      }

      final currentUser = await _authApi.fetchCurrentUser(stored.token);
      if (!mounted) {
        return;
      }

      setState(() {
        _session = AuthSession(token: stored.token, user: currentUser);
        _selectedCurrency = storedCurrency;
        _isLoadingSession = false;
      });
    } catch (_) {
      await _authStorage.clear();
      if (!mounted) {
        return;
      }

      setState(() {
        _session = null;
        _selectedCurrency = defaultCurrency;
        _isLoadingSession = false;
      });
    }
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: _isLoadingSession
          ? const _LoadingScreen()
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
      ),
      ChatScreen(
        session: widget.session,
        currency: widget.selectedCurrency,
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

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
