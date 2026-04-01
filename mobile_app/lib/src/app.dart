import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class ExpenseMobileApp extends StatelessWidget {
  const ExpenseMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF0E7490);

    return MaterialApp(
      title: 'Expense Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
