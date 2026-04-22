import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_lock_config.dart';

class AppPreferencesStorage {
  static const _currencyCodeKey = 'selected_currency_code';
  static const _chatAgentKey = 'selected_chat_agent';
  static const _onboardingCompletedKey = 'onboarding_completed';
  static const _appLockPinHashKey = 'app_lock_pin_hash';
  static const _appLockPinSaltKey = 'app_lock_pin_salt';
  static const _appLockBiometricEnabledKey = 'app_lock_biometric_enabled';
  static const _themeModeKey = 'app_theme_mode';

  Future<String?> readThemeMode() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_themeModeKey);
  }

  Future<void> writeThemeMode(String mode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeModeKey, mode);
  }

  Future<String?> readCurrencyCode() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_currencyCodeKey);
  }

  Future<void> writeCurrencyCode(String code) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_currencyCodeKey, code);
  }

  Future<String?> readChatAgent() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_chatAgentKey);
  }

  Future<void> writeChatAgent(String agent) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_chatAgentKey, agent);
  }

  /// Whether the user has finished the first-run intro (persisted per device).
  ///
  /// If the key was never written (app update from a build without onboarding),
  /// we treat the intro as already done when [selected_currency_code] exists so
  /// existing users are not sent through onboarding again.
  Future<bool> readOnboardingCompleted() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey(_onboardingCompletedKey)) {
      return preferences.getBool(_onboardingCompletedKey) ?? false;
    }
    if (preferences.containsKey(_currencyCodeKey)) {
      return true;
    }
    return false;
  }

  Future<void> writeOnboardingCompleted(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_onboardingCompletedKey, value);
  }

  Future<AppLockConfig> readAppLockConfig() async {
    final preferences = await SharedPreferences.getInstance();
    return AppLockConfig(
      pinHash: preferences.getString(_appLockPinHashKey),
      pinSalt: preferences.getString(_appLockPinSaltKey),
      biometricsEnabled:
          preferences.getBool(_appLockBiometricEnabledKey) ?? false,
    );
  }

  Future<void> writeAppLockConfig({
    required String pinHash,
    required String pinSalt,
    required bool biometricsEnabled,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_appLockPinHashKey, pinHash);
    await preferences.setString(_appLockPinSaltKey, pinSalt);
    await preferences.setBool(_appLockBiometricEnabledKey, biometricsEnabled);
  }

  Future<void> clearAppLockConfig() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_appLockPinHashKey);
    await preferences.remove(_appLockPinSaltKey);
    await preferences.remove(_appLockBiometricEnabledKey);
  }
}
