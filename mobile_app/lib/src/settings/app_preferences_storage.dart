import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesStorage {
  static const _currencyCodeKey = 'selected_currency_code';
  static const _chatAgentKey = 'selected_chat_agent';
  static const _onboardingCompletedKey = 'onboarding_completed';

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
}
