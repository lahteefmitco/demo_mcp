import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../theme/app_theme.dart';

/// Centralized user messages.
///
/// Requirement: no SnackBars. Use toastification for all UI notifications.
abstract final class AppToast {
  static void success(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
      primaryColor: Colors.white,
      foregroundColor: Colors.white,
      backgroundColor: ExpenseAppTheme.seedColor
    );
  }

  static void error(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      primaryColor: Colors.red,
    );
  }
}

