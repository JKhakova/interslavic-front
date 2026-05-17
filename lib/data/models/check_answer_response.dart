class CheckAnswerResponse {
  const CheckAnswerResponse({required this.isCorrect, required this.message});

  final bool isCorrect;
  final String message;

  factory CheckAnswerResponse.fromJson(Map<String, dynamic> json) {
    return CheckAnswerResponse(
      isCorrect: (json['is_correct'] as bool?) ?? false,
      message: (json['message'] as String?) ?? '',
    );
  }
}
