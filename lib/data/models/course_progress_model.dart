class CourseProgressModel {
  const CourseProgressModel({
    required this.courseId,
    required this.courseTitle,
    required this.progressPercent,
    required this.completedLessons,
    required this.inProgressLessons,
    required this.notStartedLessons,
    required this.totalLessons,
    required this.status,
  });

  final int courseId;
  final String courseTitle;
  final double progressPercent;
  final int completedLessons;
  final int inProgressLessons;
  final int notStartedLessons;
  final int totalLessons;
  final String status;

  factory CourseProgressModel.fromJson(Map<String, dynamic> json) {
    return CourseProgressModel(
      courseId: _toInt(json['course_id']),
      courseTitle: (json['course_title'] as String?) ?? '',
      progressPercent: _toDouble(json['progress_percent']),
      completedLessons: _toInt(json['completed_lessons']),
      inProgressLessons: _toInt(json['in_progress_lessons']),
      notStartedLessons: _toInt(json['not_started_lessons']),
      totalLessons: _toInt(json['total_lessons']),
      status: (json['status'] as String?) ?? '',
    );
  }

  int get roundedProgress => progressPercent.round().clamp(0, 100);

  static int _toInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static double _toDouble(Object? value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }
}
