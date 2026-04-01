import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chat_message.dart';

class ChatApi {
  ChatApi({http.Client? client})
    : _client = client ?? http.Client(),
      baseUrl = const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://demo-mcp-l0rq.onrender.com',
      );

  final http.Client _client;
  final String baseUrl;

  Future<String> sendMessage(List<ChatMessage> messages) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/chat'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'messages': messages.map((message) => message.toJson()).toList(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to chat: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['reply'] as String? ?? '';
  }
}
