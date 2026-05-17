import 'dart:convert';
import 'dart:io';

import 'package:flutter_application_1/data/models/course_model.dart';
import 'package:flutter_application_1/data/services/api_config.dart';

class CoursesApiService {
  const CoursesApiService();
  String get apiBaseUrl => ApiConfig.instance.apiBaseUrl;

  Future<List<CourseModel>> getCourses() async {
    final httpClient = HttpClient();

    try {
      final uri = Uri.parse('$apiBaseUrl/api/courses');
      final request = await httpClient.getUrl(uri);
      request.headers.contentType = ContentType.json;

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        throw CoursesException(
          'Не удалось загрузить курсы (${response.statusCode})',
        );
      }

      if (body.isEmpty) {
        return const <CourseModel>[];
      }

      final jsonBody = jsonDecode(body) as List<dynamic>;

      return jsonBody
          .map((item) => CourseModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } finally {
      httpClient.close(force: true);
    }
  }
}

class CoursesException implements Exception {
  CoursesException(this.message);

  final String message;
}
