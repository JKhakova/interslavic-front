import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/data/models/course_model.dart';
import 'package:flutter_application_1/data/models/course_progress_model.dart';
import 'package:flutter_application_1/data/services/courses_api_service.dart';
import 'package:flutter_application_1/data/services/progress_api_service.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({
    required CoursesApiService coursesApiService,
    required ProgressApiService progressApiService,
  }) : _coursesApiService = coursesApiService,
       _progressApiService = progressApiService;

  final CoursesApiService _coursesApiService;
  final ProgressApiService _progressApiService;

  List<CourseModel> _courses = const <CourseModel>[];
  final Map<int, int> _progressByCourseId = <int, int>{};
  final Map<int, int> _completedLessonsByCourseId = <int, int>{};

  bool _isLoading = false;
  String? _errorText;
  bool _isLoaded = false;

  List<CourseModel> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get errorText => _errorText;

  Future<void> loadCourses({
    required String accessToken,
    bool force = false,
  }) async {
    if (_isLoading || (_isLoaded && !force)) {
      return;
    }

    _setLoading(true);
    _errorText = null;

    try {
      final data = await _coursesApiService.getCourses();
      _courses = data;

      _progressByCourseId.clear();
      _completedLessonsByCourseId.clear();

      for (final course in data) {
        _progressByCourseId[course.id] = 0;
        _completedLessonsByCourseId[course.id] = 0;
      }

      if (accessToken.isNotEmpty) {
        final progress = await _progressApiService.getCoursesProgress(
          accessToken: accessToken,
        );

        for (final item in progress) {
          _applyCourseProgress(item);
        }
      }

      _isLoaded = true;
      notifyListeners();
    } on CoursesException catch (e) {
      _errorText = e.message;
      notifyListeners();
    } on ProgressException catch (e) {
      _errorText = e.message;
      notifyListeners();
    } catch (_) {
      _errorText = 'Не удалось загрузить прогресс';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  int progressForCourse(int courseId) {
    return _progressByCourseId[courseId] ?? 0;
  }

  int completedLessonsForCourse(int courseId) {
    return _completedLessonsByCourseId[courseId] ?? 0;
  }

  Future<void> syncProgressFromBackend({required String accessToken}) async {
    await loadCourses(force: true, accessToken: accessToken);
  }

  void reset() {
    _courses = const <CourseModel>[];
    _progressByCourseId.clear();
    _completedLessonsByCourseId.clear();
    _isLoading = false;
    _errorText = null;
    _isLoaded = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _applyCourseProgress(CourseProgressModel progress) {
    _progressByCourseId[progress.courseId] = progress.roundedProgress;
    _completedLessonsByCourseId[progress.courseId] =
        progress.completedLessons < 0 ? 0 : progress.completedLessons;
  }
}
