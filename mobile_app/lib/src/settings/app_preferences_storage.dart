import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesStorage {
  static const _currencyCodeKey = 'selected_currency_code';
  static const _chatAgentKey = 'selected_chat_agent';

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
}
