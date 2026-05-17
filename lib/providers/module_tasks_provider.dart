import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/data/models/lesson_model.dart';
import 'package:flutter_application_1/data/models/task_model.dart';
import 'package:flutter_application_1/data/services/learning_api_service.dart';
import 'package:flutter_application_1/data/services/progress_api_service.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_application_1/providers/profile_provider.dart';

class ModuleTasksProvider extends ChangeNotifier {
  ModuleTasksProvider({
    required LearningApiService learningApiService,
    required ProgressApiService progressApiService,
    required AuthProvider authProvider,
    required ProfileProvider profileProvider,
    required int courseId,
  }) : _learningApiService = learningApiService,
       _progressApiService = progressApiService,
       _authProvider = authProvider,
       _profileProvider = profileProvider,
       _courseId = courseId;

  final LearningApiService _learningApiService;
  final ProgressApiService _progressApiService;
  final AuthProvider _authProvider;
  final ProfileProvider _profileProvider;
  final int _courseId;

  bool _isLoading = false;
  bool _isChecking = false;
  String? _errorText;

  List<TaskModel> _seriesTasks = const <TaskModel>[];
  final Map<int, int> _taskCountByLessonId = <int, int>{};
  final Map<int, int> _answeredCountByLessonId = <int, int>{};
  final Map<int, int> _correctCountByLessonId = <int, int>{};
  final Set<int> _answeredTaskIds = <int>{};
  final Map<int, LessonModel> _lessonById = <int, LessonModel>{};

  int _currentIndex = 0;
  bool? _lastIsCorrect;
  String? _resultMessage;
  String? _explanationText;
  bool _canGoNext = false;

  int _answeredInSeries = 0;
  int _correctInSeries = 0;
  int _incorrectInSeries = 0;

  bool get isLoading => _isLoading;
  bool get isChecking => _isChecking;
  String? get errorText => _errorText;
  TaskModel? get currentTask =>
      _seriesTasks.isEmpty ? null : _seriesTasks[_currentIndex];
  int get currentTaskNumber => _currentIndex + 1;
  int get seriesLength => _seriesTasks.length;
  bool? get lastIsCorrect => _lastIsCorrect;
  String? get resultMessage => _resultMessage;
  String? get explanationText => _explanationText;
  bool get canGoNext => _canGoNext;
  LessonModel? get currentLesson {
    final task = currentTask;
    if (task == null) {
      return null;
    }
    return _lessonById[task.lessonId];
  }

  int get answeredInSeries => _answeredInSeries;
  int get correctInSeries => _correctInSeries;
  int get incorrectInSeries => _incorrectInSeries;
  bool get isOnLastTask => _currentIndex == _seriesTasks.length - 1;

  Future<void> load() async {
    if (_isLoading || _seriesTasks.isNotEmpty) {
      return;
    }

    _setLoading(true);
    _errorText = null;

    try {
      final lessons = await _learningApiService.getLessonsByCourse(_courseId);
      _lessonById
        ..clear()
        ..addEntries(lessons.map((lesson) => MapEntry(lesson.id, lesson)));
      final tasksByLessonId = <int, List<TaskModel>>{};

      for (final lesson in lessons) {
        final lessonTasks = await _learningApiService.getTasksByLesson(
          lesson.id,
        );
        tasksByLessonId[lesson.id] = lessonTasks;
        _taskCountByLessonId[lesson.id] = lessonTasks.length;
        _answeredCountByLessonId.putIfAbsent(lesson.id, () => 0);
      }

      if (lessons.isEmpty) {
        _errorText = 'В модуле пока нет уроков';
        notifyListeners();
        return;
      }

      final hasAnyTask = tasksByLessonId.values.any(
        (tasks) => tasks.isNotEmpty,
      );
      if (!hasAnyTask) {
        _errorText = 'В модуле пока нет заданий';
        notifyListeners();
        return;
      }

      final completedLessons = _profileProvider.completedLessonsForCourse(
        _courseId,
      );
      int lessonIndex = completedLessons.clamp(0, lessons.length);
      while (lessonIndex < lessons.length &&
          (tasksByLessonId[lessons[lessonIndex].id]?.isEmpty ?? true)) {
        lessonIndex += 1;
      }

      if (lessonIndex >= lessons.length) {
        _errorText = 'Модуль уже завершен';
        notifyListeners();
        return;
      }

      final lessonId = lessons[lessonIndex].id;
      _seriesTasks = List<TaskModel>.from(
        tasksByLessonId[lessonId] ?? const [],
      );
      _currentIndex = 0;

      notifyListeners();
    } on LearningException catch (e) {
      _errorText = e.message;
      notifyListeners();
    } catch (_) {
      _errorText = 'Не удалось загрузить задания';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> submitAnswer(String rawAnswer) async {
    if (_isChecking || _seriesTasks.isEmpty) {
      return;
    }

    final answer = rawAnswer.trim();
    if (answer.isEmpty) {
      _resultMessage = 'Введите ответ перед проверкой';
      _lastIsCorrect = false;
      _explanationText = null;
      _canGoNext = false;
      notifyListeners();
      return;
    }

    final accessToken = _authProvider.authResponse?.tokens.accessToken ?? '';
    if (accessToken.isEmpty) {
      _resultMessage = 'Сессия истекла. Войдите заново';
      _lastIsCorrect = false;
      _explanationText = null;
      _canGoNext = false;
      notifyListeners();
      return;
    }

    _isChecking = true;
    _resultMessage = null;
    _explanationText = null;
    _lastIsCorrect = null;
    notifyListeners();

    try {
      final task = _seriesTasks[_currentIndex];
      final result = await _learningApiService.checkTaskAnswer(
        taskId: task.id,
        answer: answer,
        accessToken: accessToken,
      );

      _lastIsCorrect = result.isCorrect;
      _resultMessage = result.isCorrect
          ? 'Верно!'
          : 'Неверно. ${result.message.isNotEmpty ? result.message : ''}'
                .trim();
      _explanationText = result.isCorrect
          ? null
          : 'Правильный ответ: ${task.answer}';
      _canGoNext = true;

      _answeredInSeries += 1;
      if (result.isCorrect) {
        _correctInSeries += 1;
      } else {
        _incorrectInSeries += 1;
      }

      await _registerTaskAsCompleted(
        task: task,
        isCorrect: result.isCorrect,
        accessToken: accessToken,
      );

      notifyListeners();
    } on LearningException catch (e) {
      _lastIsCorrect = false;
      _resultMessage = e.message;
      _explanationText = null;
      _canGoNext = false;
      notifyListeners();
    } catch (_) {
      _lastIsCorrect = false;
      _resultMessage = 'Ошибка проверки ответа';
      _explanationText = null;
      _canGoNext = false;
      notifyListeners();
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  void goNext() {
    if (!_canGoNext) {
      return;
    }

    if (_currentIndex >= _seriesTasks.length - 1) {
      return;
    }

    _currentIndex += 1;
    _lastIsCorrect = null;
    _resultMessage = null;
    _explanationText = null;
    _canGoNext = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _registerTaskAsCompleted({
    required TaskModel task,
    required bool isCorrect,
    required String accessToken,
  }) async {
    if (_answeredTaskIds.contains(task.id)) {
      return;
    }

    _answeredTaskIds.add(task.id);

    final lessonId = task.lessonId;
    final answeredCount = (_answeredCountByLessonId[lessonId] ?? 0) + 1;
    _answeredCountByLessonId[lessonId] = answeredCount;
    if (isCorrect) {
      _correctCountByLessonId[lessonId] =
          (_correctCountByLessonId[lessonId] ?? 0) + 1;
    }

    final totalByLesson = _taskCountByLessonId[lessonId] ?? 0;
    if (totalByLesson > 0 && answeredCount >= totalByLesson) {
      final score =
          ((_correctCountByLessonId[lessonId] ?? 0) / totalByLesson * 100)
              .round()
              .clamp(0, 100);

      try {
        await _progressApiService.updateLessonProgress(
          lessonId: lessonId,
          status: 'completed',
          score: score,
          accessToken: accessToken,
        );
        unawaited(
          _profileProvider.syncProgressFromBackend(accessToken: accessToken),
        );
      } on ProgressException catch (e) {
        _errorText = e.message;
        notifyListeners();
      }
    }
  }
}
