import 'package:flutter/material.dart';

class ModuleStatsScreen extends StatelessWidget {
  const ModuleStatsScreen({
    super.key,
    required this.courseTitle,
    required this.total,
    required this.correct,
    required this.incorrect,
  });

  final String courseTitle;
  final int total;
  final int correct;
  final int incorrect;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Статистика')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                courseTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              _StatRow(title: 'Всего в серии', value: '$total'),
              _StatRow(title: 'Верно', value: '$correct'),
              _StatRow(title: 'Неверно', value: '$incorrect'),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Готово'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18)),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
