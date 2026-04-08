import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubits/app/app_cubit.dart';
import 'cubits/app/app_state.dart';
import 'cubits/shell/shell_cubit.dart';
import 'cubits/shell/shell_state.dart';
import 'di/service_locator.dart';
import 'database/finance_database_holder.dart';
import 'models/auth_session.dart';
import 'models/currency_option.dart';
import 'repository/finance_repository.dart';
import 'screens/auth_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'sync/background_sync.dart';
import 'theme/app_theme.dart';
import 'utils/app_responsive.dart';

class ExpenseMobileApp extends StatelessWidget {
  const ExpenseMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppCubit(
        authStorage: sl(),
        preferencesStorage: sl(),
        authApi: sl(),
      )..bootstrap(),
      child: MaterialApp(
        title: 'Finance Mobile',
        debugShowCheckedModeBanner: false,
        theme: ExpenseAppTheme.light(),
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
      ),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (prev, next) => prev.runtimeType != next.runtimeType || prev != next,
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
            onAuthenticated: (session) => context.read<AppCubit>().authenticated(session),
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

class _AppShellState extends State<AppShell> {
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
            final railExtended =
                MediaQuery.sizeOf(context).width >= 900;

            final stack = IndexedStack(
              index: selectedIndex,
              children: screens,
            );

            return Scaffold(
              body: wide
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
                          child: ResponsiveContentWidth(
                            child: stack,
                          ),
                        ),
                      ],
                    )
                  : ResponsiveContentWidth(child: stack),
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
