class CourseModel {
  const CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.theory,
    this.progressPercent,
    this.currentLessonId,
    this.currentLessonTitle,
    this.currentLessonTopic,
  });

  final int id;
  final String title;
  final String description;
  final String theory;
  final int? progressPercent;
  final int? currentLessonId;
  final String? currentLessonTitle;
  final String? currentLessonTopic;

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final currentLesson = json['current_lesson'];

    return CourseModel(
      id: (json['id'] as int?) ?? 0,
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      theory: (json['theory'] as String?) ?? '',
      progressPercent: _parseInt(
        json['progress_percent'] ?? json['progress'] ?? json['progressPercent'],
      ),
      currentLessonId: currentLesson is Map<String, dynamic>
          ? _parseInt(currentLesson['id'])
          : _parseInt(json['current_lesson_id']),
      currentLessonTitle: currentLesson is Map<String, dynamic>
          ? currentLesson['title'] as String?
          : json['current_lesson_title'] as String?,
      currentLessonTopic: currentLesson is Map<String, dynamic>
          ? currentLesson['topic'] as String?
          : json['current_lesson_topic'] as String?,
    );
  }

  static int? _parseInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}
