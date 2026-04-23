import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubits/app/app_cubit.dart';
import 'cubits/app/app_state.dart';
import 'cubits/shell/shell_cubit.dart';
import 'cubits/shell/shell_state.dart';
import 'cubits/theme/theme_cubit.dart';
import 'di/service_locator.dart';
import 'database/finance_database_holder.dart';
import 'models/app_lock_config.dart';
import 'models/auth_session.dart';
import 'models/currency_option.dart';
import 'repository/finance_repository.dart';
import 'screens/app_lock_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'services/app_lock_service.dart';
import 'sync/background_sync.dart';
import 'theme/app_theme.dart';
import 'utils/app_logger.dart';
import 'utils/app_responsive.dart';

class ExpenseMobileApp extends StatelessWidget {
  const ExpenseMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AppCubit(
            authStorage: sl(),
            preferencesStorage: sl(),
            authApi: sl(),
          )..bootstrap(),
        ),
        BlocProvider(
          create: (_) => ThemeCubit(preferencesStorage: sl())..loadTheme(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Gulfon finance',
            debugShowCheckedModeBanner: false,
            theme: ExpenseAppTheme.light(),
            darkTheme: ExpenseAppTheme.dark(),
            themeMode: themeMode,
            builder: (context, child) {
              final mq = MediaQuery.of(context);
              return MediaQuery(
                data: mq.copyWith(
                  textScaler: mq.textScaler.clamp(
                    minScaleFactor: 0.85,
                    maxScaleFactor: 1.15,
                  ),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const _AppRoot(),
          );
        },
      ),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (prev, next) =>
          prev.runtimeType != next.runtimeType || prev != next,
      builder: (context, state) {
        if (state is AppBootstrapping) {
          return const SplashScreen();
        }
        if (state is AppNeedsOnboarding) {
          return OnboardingScreen(
            onComplete: () => context.read<AppCubit>().completeOnboarding(),
          );
        }
        if (state is AppUnauthenticated) {
          return AuthScreen(
            onAuthenticated: (session) =>
                context.read<AppCubit>().authenticated(session),
          );
        }
        if (state is AppAuthenticated) {
          return AppShell(
            session: state.session,
            selectedCurrency: state.currency,
            onLogout: () => context.read<AppCubit>().logout(),
            onSessionUpdated: (s) => context.read<AppCubit>().sessionUpdated(s),
            onCurrencyChanged: (c) => context.read<AppCubit>().setCurrency(c),
          );
        }
        return const SplashScreen();
      },
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

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  late final FinanceRepository _financeRepository;
  late final AppLockService _appLockService;
  AppLockConfig _appLockConfig = const AppLockConfig.disabled();
  bool _biometricsSupported = false;
  bool _isLoadingAppLock = true;
  bool _isLocked = false;
  bool _isUnlockingWithBiometrics = false;
  bool _shouldRelockOnResume = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _financeRepository = FinanceRepository(
      database: FinanceDatabaseHolder.instance,
      token: widget.session.token,
    );
    _appLockService = sl<AppLockService>();
    BackgroundSync.registerPeriodicSync();
    unawaited(_loadAppLockState());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_appLockConfig.isEnabled) {
      return;
    }

    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      _shouldRelockOnResume = true;
      return;
    }

    if (state == AppLifecycleState.resumed && _shouldRelockOnResume) {
      _shouldRelockOnResume = false;
      _lockApp();
    }
  }

  Future<void> _loadAppLockState({bool attemptBiometricUnlock = true}) async {
    final config = await _appLockService.readConfig();
    final biometricsSupported = await _appLockService.canUseBiometrics();
    if (!mounted) {
      return;
    }

    setState(() {
      _appLockConfig = config;
      _biometricsSupported = biometricsSupported;
      _isLoadingAppLock = false;
      if (!config.isEnabled) {
        _isLocked = false;
      } else if (attemptBiometricUnlock) {
        _isLocked = true;
      }
    });

    if (config.isEnabled && attemptBiometricUnlock) {
      unawaited(_tryBiometricUnlock());
    }
  }

  void _lockApp() {
    if (!_appLockConfig.isEnabled || !mounted) {
      return;
    }

    setState(() {
      _isLocked = true;
    });
    unawaited(_tryBiometricUnlock());
  }

  Future<void> _tryBiometricUnlock() async {
    if (!_isLocked ||
        !_appLockConfig.isEnabled ||
        !_appLockConfig.biometricsEnabled ||
        !_biometricsSupported ||
        _isUnlockingWithBiometrics) {
      return;
    }

    setState(() {
      _isUnlockingWithBiometrics = true;
    });

    final authenticated = await _appLockService.authenticateWithBiometrics();
    if (!mounted) {
      return;
    }

    setState(() {
      _isUnlockingWithBiometrics = false;
      if (authenticated) {
        _isLocked = false;
      }
    });
  }

  Future<bool> _unlockWithPin(String pin) async {
    final valid = await _appLockService.validatePin(pin);
    if (!mounted) {
      return false;
    }

    if (valid) {
      setState(() {
        _isLocked = false;
      });
    }
    return valid;
  }

  Future<bool> _setPin(String pin) async {
    await _appLockService.savePin(pin);
    await _loadAppLockState(attemptBiometricUnlock: false);
    if (!mounted) {
      return false;
    }
    setState(() {
      _isLocked = false;
    });
    return true;
  }

  Future<bool> _changePin(String currentPin, String newPin) async {
    final changed = await _appLockService.changePin(
      currentPin: currentPin,
      newPin: newPin,
    );
    if (!changed) {
      return false;
    }

    await _loadAppLockState(attemptBiometricUnlock: false);
    if (!mounted) {
      return false;
    }
    setState(() {
      _isLocked = false;
    });
    return true;
  }

  Future<bool> _removePin(String currentPin) async {
    final removed = await _appLockService.clearPin(currentPin);
    if (!removed) {
      return false;
    }

    await _loadAppLockState(attemptBiometricUnlock: false);
    return true;
  }

  Future<bool> _setBiometricsEnabled(bool enabled) async {
    final updated = await _appLockService.setBiometricsEnabled(enabled);
    if (!updated && enabled) {
      AppLogger.i('Biometrics could not be enabled on this device.');
    }
    await _loadAppLockState(attemptBiometricUnlock: false);
    return updated;
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<FinanceRepository>.value(
      value: _financeRepository,
      child: BlocProvider(
        create: (_) => ShellCubit(),
        child: BlocBuilder<ShellCubit, ShellState>(
          buildWhen: (p, n) => p.selectedIndex != n.selectedIndex,
          builder: (context, shell) {
            final selectedIndex = shell.selectedIndex;
            final screens = [
              HomeScreen(
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
              DashboardScreen(
                session: widget.session,
                currency: widget.selectedCurrency,
              ),
              ChatScreen(
                session: widget.session,
                currency: widget.selectedCurrency,
                isActiveTab: selectedIndex == 2,
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
                currency: widget.selectedCurrency,
                onCurrencyChanged: widget.onCurrencyChanged,
                onLogout: widget.onLogout,
                appLockConfig: _appLockConfig,
                biometricsSupported: _biometricsSupported,
                onSetPin: _setPin,
                onChangePin: _changePin,
                onRemovePin: _removePin,
                onBiometricsChanged: _setBiometricsEnabled,
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

            final wide = AppResponsive.useWideShellLayout(context);
            final railExtended = MediaQuery.sizeOf(context).width >= 900;

            final stack = IndexedStack(index: selectedIndex, children: screens);

            return Scaffold(
              body: Stack(
                children: [
                  wide
                      ? Row(
                          children: [
                            NavigationRail(
                              selectedIndex: selectedIndex,
                              onDestinationSelected: (index) {
                                context.read<ShellCubit>().selectTab(index);
                              },
                              labelType: NavigationRailLabelType.all,
                              extended: railExtended,
                              destinations: const [
                                NavigationRailDestination(
                                  icon: Icon(Icons.home_outlined),
                                  selectedIcon: Icon(Icons.home),
                                  label: Text('Home'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.dashboard_outlined),
                                  selectedIcon: Icon(Icons.dashboard),
                                  label: Text('Dashboard'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.chat_bubble_outline),
                                  selectedIcon: Icon(Icons.chat_bubble),
                                  label: Text('Chat'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.settings_outlined),
                                  selectedIcon: Icon(Icons.settings),
                                  label: Text('Settings'),
                                ),
                              ],
                            ),
                            const VerticalDivider(width: 1, thickness: 1),
                            Expanded(
                              child: ResponsiveContentWidth(child: stack),
                            ),
                          ],
                        )
                      : ResponsiveContentWidth(child: stack),
                  if (!_isLoadingAppLock && _isLocked)
                    Positioned.fill(
                      child: AppLockScreen(
                        onUnlock: _unlockWithPin,
                        biometricsAvailable:
                            _appLockConfig.biometricsEnabled &&
                            _biometricsSupported,
                        onUseBiometrics: _tryBiometricUnlock,
                        isUnlockingWithBiometrics: _isUnlockingWithBiometrics,
                      ),
                    ),
                ],
              ),
              bottomNavigationBar: wide
                  ? null
                  : NavigationBar(
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (index) {
                        context.read<ShellCubit>().selectTab(index);
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
          },
        ),
      ),
    );
  }
}
