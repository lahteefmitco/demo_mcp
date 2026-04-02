import 'package:flutter/material.dart';

import 'api/auth_api.dart';
import 'auth/auth_storage.dart';
import 'models/auth_session.dart';
import 'screens/auth_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/home_screen.dart';

class ExpenseMobileApp extends StatefulWidget {
  const ExpenseMobileApp({super.key});

  @override
  State<ExpenseMobileApp> createState() => _ExpenseMobileAppState();
}

class _ExpenseMobileAppState extends State<ExpenseMobileApp> {
  static const _seedColor = Color(0xFF0E7490);
  final AuthStorage _authStorage = AuthStorage();
  final AuthApi _authApi = AuthApi();
  AuthSession? _session;
  bool _isLoadingSession = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final stored = await _authStorage.readSession();
      if (stored == null) {
        if (!mounted) {
          return;
        }

        setState(() {
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
        _isLoadingSession = false;
      });
    } catch (_) {
      await _authStorage.clear();
      if (!mounted) {
        return;
      }

      setState(() {
        _session = null;
        _isLoadingSession = false;
      });
    }
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

  Future<void> _logout() async {
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
          : AppShell(session: _session!, onLogout: _logout),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({required this.session, required this.onLogout, super.key});

  final AuthSession session;
  final Future<void> Function() onLogout;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(session: widget.session, onLogout: widget.onLogout),
      ChatScreen(session: widget.session, onLogout: widget.onLogout),
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
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
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
