class LessonModel {
  const LessonModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    required this.multimedia,
    required this.position,
  });

  final int id;
  final int courseId;
  final String title;
  final String content;
  final String multimedia;
  final int position;

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: (json['id'] as int?) ?? 0,
      courseId: (json['course_id'] as int?) ?? 0,
      title: (json['title'] as String?) ?? '',
      content: (json['content'] as String?) ?? '',
      multimedia: (json['multimedia'] as String?) ?? '',
      position: (json['position'] as int?) ?? 0,
    );
  }
}
