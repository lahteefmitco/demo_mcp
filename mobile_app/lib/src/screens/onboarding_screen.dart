import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({required this.onComplete, super.key});

  final Future<void> Function() onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _index = 0;

  static const _pages = <_OnboardingPage>[
    _OnboardingPage(
      icon: Icons.receipt_long_rounded,
      title: 'Track money your way',
      body:
          'Log expenses and income, organize with categories, and manage multiple accounts. '
          'Your data is stored on-device first and can sync with your account when you are online.',
    ),
    _OnboardingPage(
      icon: Icons.insights_rounded,
      title: 'See the full picture',
      body:
          'Open the dashboard for daily, weekly, and monthly views of spending. '
          'Understand where your money goes with charts built from your own records.',
    ),
    _OnboardingPage(
      icon: Icons.chat_bubble_rounded,
      title: 'Chat with your finances',
      body:
          'Ask questions in natural language, explore spending with AI-powered help, '
          'and use automation tools for budgets and categories from Settings.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await widget.onComplete();
  }

  void _next() {
    if (_index < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: ExpenseAppTheme.splashBackgroundGradient(context),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxW = math.min(640.0, constraints.maxWidth - 8.w);
                    return Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxW),
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _pages.length,
                          onPageChanged: (i) => setState(() => _index = i),
                          itemBuilder: (context, i) {
                            final page = _pages[i];
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(6.w),
                                    decoration: BoxDecoration(
                                      color: scheme.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      page.icon,
                                      size: (14.w).clamp(48.0, 72.0),
                                      color: scheme.primary,
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    page.title,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.4,
                                          fontSize: 20.sp,
                                        ),
                                  ),
                                  SizedBox(height: 1.5.h),
                                  Text(
                                    page.body,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: scheme.onSurface.withValues(
                                            alpha: 0.75,
                                          ),
                                          height: 1.45,
                                          fontSize: 15.sp,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? scheme.primary
                          : scheme.primary.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
              SizedBox(height: 2.h),
              Padding(
                padding: EdgeInsets.fromLTRB(6.w, 0, 6.w, 3.h),
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                    minimumSize: Size.fromHeight((6.h).clamp(48.0, 56.0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _index == _pages.length - 1 ? 'Get started' : 'Next',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
