import 'dart:convert';
import 'dart:io';

import 'package:flutter_application_1/data/models/auth_response.dart';
import 'package:flutter_application_1/data/models/login_request.dart';
import 'package:flutter_application_1/data/models/register_request.dart';
import 'package:flutter_application_1/data/services/api_config.dart';

class AuthApiService {
  const AuthApiService();
  String get apiBaseUrl => ApiConfig.instance.apiBaseUrl;

  Future<AuthResponse> login(LoginRequest requestBody) async {
    final httpClient = HttpClient();

    try {
      final uri = Uri.parse('$apiBaseUrl/api/auth/login');
      final request = await httpClient.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(jsonEncode(requestBody.toJson())));

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final jsonBody = body.isNotEmpty
          ? jsonDecode(body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(jsonBody);
      }

      throw AuthException(
        _extractErrorMessage(statusCode: response.statusCode, body: jsonBody),
      );
    } finally {
      httpClient.close(force: true);
    }
  }

  Future<void> register(RegisterRequest requestBody) async {
    final httpClient = HttpClient();

    try {
      final uri = Uri.parse('$apiBaseUrl/api/auth/register');
      final request = await httpClient.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(jsonEncode(requestBody.toJson())));

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final jsonBody = body.isNotEmpty
          ? jsonDecode(body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      throw AuthException(
        _extractErrorMessage(statusCode: response.statusCode, body: jsonBody),
      );
    } finally {
      httpClient.close(force: true);
    }
  }

  String _extractErrorMessage({
    required int statusCode,
    required Map<String, dynamic> body,
  }) {
    if (body.isNotEmpty) {
      final firstValue = body.values.first;
      if (firstValue is String && firstValue.trim().isNotEmpty) {
        return firstValue;
      }
    }

    switch (statusCode) {
      case 400:
        return 'Некорректные данные';
      case 401:
        return 'Неверный логин или пароль';
      default:
        return 'Ошибка авторизации ($statusCode)';
    }
  }
}

class AuthException implements Exception {
  AuthException(this.message);

  final String message;
}
