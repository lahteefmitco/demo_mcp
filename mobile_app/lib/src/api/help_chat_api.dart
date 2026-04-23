import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../models/chat_message.dart';
import '../models/help_chat_models.dart';

class HelpChatApi {
  HelpChatApi({required this.token, http.Client? client})
    : _client = client ?? http.Client(),
      baseUrl = const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://demo-mcp-615058378594.europe-west1.run.app',
      );

  final http.Client _client;
  final String baseUrl;
  final String token;

  Future<HelpChatReply> sendMessage({
    required List<ChatMessage> messages,
    required String appVersion,
    required int maxWords,
    String? screen,
  }) async {
    log('HelpChat request: messages=${messages.length}, screen=$screen');

    final response = await _client.post(
      Uri.parse('$baseUrl/api/help/chat'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'appVersion': appVersion,
        'maxWords': maxWords,
        if (screen != null && screen.trim().isNotEmpty) 'screen': screen.trim(),
        'messages': messages.map((m) => m.toJson()).toList(),
      }),
    );

    if (response.statusCode != 200) {
      log('HelpChat API error: ${response.statusCode} - ${response.body}');
      throw Exception('Help chat failed: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return HelpChatReply.fromJson(body);
  }
}

