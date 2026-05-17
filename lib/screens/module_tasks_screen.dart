import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/course_model.dart';
import 'package:flutter_application_1/data/services/learning_api_service.dart';
import 'package:flutter_application_1/data/services/progress_api_service.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_application_1/providers/module_tasks_provider.dart';
import 'package:flutter_application_1/providers/profile_provider.dart';
import 'package:flutter_application_1/screens/module_stats_screen.dart';
import 'package:provider/provider.dart';

class ModuleTasksScreen extends StatelessWidget {
  const ModuleTasksScreen({super.key, required this.course});

  final CourseModel course;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ModuleTasksProvider>(
      create: (context) => ModuleTasksProvider(
        learningApiService: const LearningApiService(),
        progressApiService: const ProgressApiService(),
        authProvider: context.read<AuthProvider>(),
        profileProvider: context.read<ProfileProvider>(),
        courseId: course.id,
      )..load(),
      child: _ModuleTasksView(course: course),
    );
  }
}

class _ModuleTasksView extends StatefulWidget {
  const _ModuleTasksView({required this.course});

  final CourseModel course;

  @override
  State<_ModuleTasksView> createState() => _ModuleTasksViewState();
}

class _ModuleTasksViewState extends State<_ModuleTasksView> {
  final TextEditingController _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _next(ModuleTasksProvider provider) {
    if (provider.isOnLastTask) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ModuleStatsScreen(
            courseTitle: widget.course.title,
            total: provider.answeredInSeries,
            correct: provider.correctInSeries,
            incorrect: provider.incorrectInSeries,
          ),
        ),
      );
      return;
    }

    provider.goNext();
    _answerController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ModuleTasksProvider>(
      builder: (context, provider, _) {
        final task = provider.currentTask;

        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(title: Text(widget.course.title)),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.errorText != null
                  ? Center(
                      child: Text(
                        provider.errorText!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFB64040)),
                      ),
                    )
                  : task == null
                  ? const Center(child: Text('Задания не найдены'))
                  : Stack(
                      children: [
                        Positioned.fill(
                          child: SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.only(bottom: 84),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Задание ${provider.currentTaskNumber}/${provider.seriesLength}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Тема: ${widget.course.title}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF5D5D5D),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Текущий урок: ${provider.currentLesson?.title ?? 'Урок'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF5D5D5D),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  task.question.isNotEmpty
                                      ? task.question
                                      : 'Прослушайте аудио и выберите правильный вариант ответа',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8E8E8),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x22000000),
                                        blurRadius: 3,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 2,
                                  ),
                                  child: TextField(
                                    controller: _answerController,
                                    decoration: const InputDecoration(
                                      hintText: 'Введите ответ',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (task.choices.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF969696),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: task.choices.map((choice) {
                                        return SizedBox(
                                          width:
                                              (MediaQuery.of(
                                                    context,
                                                  ).size.width -
                                                  72) /
                                              2,
                                          child: ElevatedButton(
                                            onPressed: provider.canGoNext
                                                ? null
                                                : () {
                                                    _answerController.text =
                                                        choice;
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: Colors.black,
                                            ),
                                            child: Text(choice),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                if (provider.resultMessage != null)
                                  Text(
                                    provider.resultMessage!,
                                    style: TextStyle(
                                      color: provider.lastIsCorrect == true
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFFB64040),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                if (provider.explanationText != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    provider.explanationText!,
                                    style: const TextStyle(
                                      color: Color(0xFF5D5D5D),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: AnimatedPadding(
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeOut,
                            padding: EdgeInsets.only(
                              top: 8,
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: !provider.canGoNext
                                  ? ElevatedButton(
                                      onPressed: provider.isChecking
                                          ? null
                                          : () => provider.submitAnswer(
                                              _answerController.text,
                                            ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF6FA8FF,
                                        ),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: provider.isChecking
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text('Ответить'),
                                    )
                                  : ElevatedButton(
                                      onPressed: () => _next(provider),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF6FA8FF,
                                        ),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text(
                                        provider.isOnLastTask
                                            ? 'Завершить серию'
                                            : 'Далее',
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
