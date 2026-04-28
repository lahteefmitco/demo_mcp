import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../models/chat_message.dart';

class ChatApi {
  ChatApi({required this.token, http.Client? client})
    : _client = client ?? http.Client(),
      baseUrl = const String.fromEnvironment(
        'API_BASE_URL',
        //defaultValue: 'https://demo-mcp-l0rq.onrender.com',
        defaultValue: 'https://demo-mcp-615058378594.europe-west1.run.app',
      );

  final http.Client _client;
  final String baseUrl;
  final String token;

  String _normalizeProviderForBackend(String provider) {
    final normalized = provider.trim().toLowerCase();
    if (normalized == 'sarvam') return 'openrouter';
    if (normalized == 'gemini' || normalized == 'mistral' || normalized == 'openrouter') {
      return normalized;
    }
    return 'gemini';
  }

  Future<String> sendMessage(
    List<ChatMessage> messages, {
    required String provider,
  }) async {
    final backendProvider = _normalizeProviderForBackend(provider);
    log('LLM Request: provider=$backendProvider, messages=${messages.length}');

    final response = await _client.post(
      Uri.parse('$baseUrl/api/chat'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'provider': backendProvider,
        'messages': messages.map((message) => message.toJson()).toList(),
      }),
    );

    if (response.statusCode != 200) {
      log('Chat API error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to chat: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    log('LLM Response: ${jsonEncode(body)}');
    return body['reply'] as String? ?? '';
  }
}
