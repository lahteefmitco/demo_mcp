import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../models/auth_session.dart';

class AuthApi {
  AuthApi({http.Client? client})
    : _client = client ?? http.Client(),
      baseUrl = const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://demo-mcp-l0rq.onrender.com',
       // defaultValue: 'http://10.0.2.2:3000',
      );

  final http.Client _client;
  final String baseUrl;

  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    return _parseMessage(response);
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    log("login url: $baseUrl/api/auth/login");
    log("email: $email");
    log("password: $password");
    final response = await _client.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractMessage(response));
    }

    return AuthSession.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<String> resendVerificationEmail(String email) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/auth/resend-verification'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    return _parseMessage(response);
  }

  Future<String> requestPasswordReset(String email) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/auth/forgot-password'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    return _parseMessage(response);
  }

  Future<AuthUser> fetchCurrentUser(String token) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/auth/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception(_extractMessage(response));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthUser.fromJson(body['user'] as Map<String, dynamic>);
  }

  Future<AuthUser> updateProfile({
    required String token,
    required String name,
  }) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl/api/auth/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractMessage(response));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthUser.fromJson(body['user'] as Map<String, dynamic>);
  }

  Future<String> requestEmailChange({
    required String token,
    required String email,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/auth/change-email'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );

    return _parseMessage(response);
  }

  String _parseMessage(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractMessage(response));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['message'] as String? ?? 'Success';
  }

  String _extractMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['error'] is String) {
        return body['error'] as String;
      }

      if (body['errors'] is List) {
        return (body['errors'] as List<dynamic>).join(', ');
      }
    } catch (_) {}

    return 'Request failed (${response.statusCode})';
  }
}
