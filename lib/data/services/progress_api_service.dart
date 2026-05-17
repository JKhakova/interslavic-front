import 'dart:convert';
import 'dart:io';

import 'package:flutter_application_1/data/models/course_progress_model.dart';
import 'package:flutter_application_1/data/services/api_config.dart';

class ProgressApiService {
  const ProgressApiService();
  String get apiBaseUrl => ApiConfig.instance.apiBaseUrl;

  Future<List<CourseProgressModel>> getCoursesProgress({
    required String accessToken,
  }) async {
    final httpClient = HttpClient();

    try {
      final uri = Uri.parse('$apiBaseUrl/api/progress/courses');
      final request = await httpClient.getUrl(uri);
      request.headers.contentType = ContentType.json;
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        throw ProgressException(
          'Не удалось загрузить прогресс (${response.statusCode})',
        );
      }

      if (body.isEmpty) {
        return const <CourseProgressModel>[];
      }

      final jsonBody = jsonDecode(body) as List<dynamic>;
      return jsonBody
          .map(
            (item) =>
                CourseProgressModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } finally {
      httpClient.close(force: true);
    }
  }

  Future<void> updateLessonProgress({
    required int lessonId,
    required String status,
    int? score,
    required String accessToken,
  }) async {
    final httpClient = HttpClient();

    try {
      final uri = Uri.parse('$apiBaseUrl/api/progress/update');
      final request = await httpClient.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );

      final payload = <String, dynamic>{
        'lesson_id': lessonId,
        'status': status,
      };

      if (score != null) {
        payload['score'] = score.clamp(0, 100);
      }

      request.add(utf8.encode(jsonEncode(payload)));

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        String errorText =
            'Не удалось обновить прогресс (${response.statusCode})';
        if (body.isNotEmpty) {
          final decoded = jsonDecode(body);
          if (decoded is Map<String, dynamic> && decoded.isNotEmpty) {
            final value = decoded.values.first;
            if (value is String && value.trim().isNotEmpty) {
              errorText = value;
            }
          }
        }
        throw ProgressException(errorText);
      }
    } finally {
      httpClient.close(force: true);
    }
  }
}

class ProgressException implements Exception {
  ProgressException(this.message);

  final String message;
}
