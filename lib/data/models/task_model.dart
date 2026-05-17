class TaskModel {
  const TaskModel({
    required this.id,
    required this.lessonId,
    required this.question,
    required this.answer,
    required this.taskType,
    required this.choices,
  });

  final int id;
  final int lessonId;
  final String question;
  final String answer;
  final int taskType;
  final List<String> choices;

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final choicesRaw = (json['choises'] as List<dynamic>?) ?? const <dynamic>[];

    return TaskModel(
      id: (json['id'] as int?) ?? 0,
      lessonId: (json['lesson_id'] as int?) ?? 0,
      question: (json['question'] as String?) ?? '',
      answer: (json['answer'] as String?) ?? '',
      taskType: (json['task_type'] as int?) ?? 0,
      choices: choicesRaw
          .map((item) => (item as String?) ?? '')
          .where((item) => item.isNotEmpty)
          .toList(),
    );
  }
}
