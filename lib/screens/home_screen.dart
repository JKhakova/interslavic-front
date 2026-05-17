import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/course_model.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_application_1/providers/profile_provider.dart';
import 'package:flutter_application_1/screens/module_tasks_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accessToken =
          context.read<AuthProvider>().authResponse?.tokens.accessToken ?? '';
      context.read<ProfileProvider>().loadCourses(accessToken: accessToken);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final user = authProvider.authResponse?.user;
    final displayName = user?.fullname.isNotEmpty == true
        ? user!.fullname
        : 'Пользователь';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.arrow_back, color: Color(0xFFBD4B4B)),
                  PopupMenuButton<String>(
                    color: Colors.white,
                    icon: const Icon(Icons.menu, color: Color(0xFFBD4B4B)),
                    onSelected: (value) {
                      if (value == 'logout') {
                        context.read<ProfileProvider>().reset();
                        context.read<AuthProvider>().logout();
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem<String>(
                        value: 'logout',
                        child: Text('Выйти'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _Avatar(initials: _toInitials(displayName)),
              const SizedBox(height: 12),
              Text(
                displayName,
                style: const TextStyle(fontSize: 16, color: Color(0xFF282828)),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Прогресс',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(child: _buildBody(profileProvider)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ProfileProvider profileProvider) {
    if (profileProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (profileProvider.errorText != null) {
      return Center(
        child: Text(
          profileProvider.errorText!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFB64040), fontSize: 13),
        ),
      );
    }

    final courses = profileProvider.courses;

    if (courses.isEmpty) {
      return const Center(
        child: Text('Курсы пока не найдены', style: TextStyle(fontSize: 13)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 10),
      itemBuilder: (context, index) {
        final course = courses[index];
        final progress = profileProvider.progressForCourse(course.id);

        return _CourseProgressCard(course: course, progress: progress);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemCount: courses.length,
    );
  }

  String _toInitials(String value) {
    final words = value
        .trim()
        .split(RegExp(r'\\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    if (words.isEmpty) {
      return 'YK';
    }

    if (words.length == 1) {
      final word = words.first;
      if (word.length == 1) {
        return word.toUpperCase();
      }
      return word.substring(0, 2).toUpperCase();
    }

    return '${words.first[0]}${words[1][0]}'.toUpperCase();
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: const BoxDecoration(
        color: Color(0xFF7A7A7A),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 38,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _CourseProgressCard extends StatelessWidget {
  const _CourseProgressCard({required this.course, required this.progress});

  final CourseModel course;
  final int progress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ModuleTasksScreen(course: course),
          ),
        );
      },
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE4E4E4),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '$progress%',
                  maxLines: 1,
                  softWrap: false,
                  style: const TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                course.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
