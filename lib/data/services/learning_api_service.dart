import 'dart:convert';
import 'dart:io';

import 'package:flutter_application_1/data/models/check_answer_response.dart';
import 'package:flutter_application_1/data/models/lesson_model.dart';
import 'package:flutter_application_1/data/models/task_model.dart';
import 'package:flutter_application_1/data/services/api_config.dart';

class LearningApiService {
  const LearningApiService();
  String get apiBaseUrl => ApiConfig.instance.apiBaseUrl;

  Future<List<LessonModel>> getLessonsByCourse(int courseId) async {
    final httpClient = HttpClient();

    try {
      final uri = Uri.parse('$apiBaseUrl/api/courses/$courseId/lessons');
      final request = await httpClient.getUrl(uri);
      request.headers.contentType = ContentType.json;

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        throw LearningException(
          'Не удалось загрузить уроки (${response.statusCode})',
        );
      }

      if (body.isEmpty) {
        return const <LessonModel>[];
      }

      final jsonBody = jsonDecode(body) as List<dynamic>;

      final lessons = jsonBody
          .map((item) => LessonModel.fromJson(item as Map<String, dynamic>))
          .toList();

      lessons.sort((a, b) {
        final byPosition = a.position.compareTo(b.position);
        if (byPosition != 0) {
          return byPosition;
        }
        return a.id.compareTo(b.id);
      });

      return lessons;
    } finally {
      httpClient.close(force: true);
    }
  }

  Future<List<TaskModel>> getTasksByLesson(int lessonId) async {
    final httpClient = HttpClient();

    try {
      final uri = Uri.parse('$apiBaseUrl/api/lessons/$lessonId/tasks');
      final request = await httpClient.getUrl(uri);
      request.headers.contentType = ContentType.json;

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        throw LearningException(
          'Не удалось загрузить задания (${response.statusCode})',
        );
      }

      if (body.isEmpty) {
        return const <TaskModel>[];
      }

      final jsonBody = jsonDecode(body) as List<dynamic>;
      return jsonBody
          .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } finally {
      httpClient.close(force: true);
    }
  }

  Future<CheckAnswerResponse> checkTaskAnswer({
    required int taskId,
    required String answer,
    required String accessToken,
  }) async {
    final httpClient = HttpClient();

    try {
      final uri = Uri.parse('$apiBaseUrl/api/tasks/check');
      final request = await httpClient.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );
      request.add(
        utf8.encode(
          jsonEncode(<String, dynamic>{'task_id': taskId, 'answer': answer}),
        ),
      );

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        String errorText = 'Ошибка проверки ответа (${response.statusCode})';
        if (body.isNotEmpty) {
          final decoded = jsonDecode(body);
          if (decoded is Map<String, dynamic> && decoded.isNotEmpty) {
            final value = decoded.values.first;
            if (value is String && value.trim().isNotEmpty) {
              errorText = value;
            }
          }
        }
        throw LearningException(errorText);
      }

      if (body.isEmpty) {
        return const CheckAnswerResponse(
          isCorrect: false,
          message: 'Нет ответа от сервера',
        );
      }

      return CheckAnswerResponse.fromJson(
        jsonDecode(body) as Map<String, dynamic>,
      );
    } finally {
      httpClient.close(force: true);
    }
  }
}

class LearningException implements Exception {
  LearningException(this.message);

  final String message;
}
