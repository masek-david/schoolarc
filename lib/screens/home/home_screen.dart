import 'package:flutter/material.dart';
import 'package:school_manager/data/homeworks_data/hw_service.dart';
import 'package:school_manager/data/exams_data/exam_service.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeworkService _serviceHw = HomeworkService();
  final ExamService _serviceExam = ExamService();

  @override
  Widget build(BuildContext context) {
    int hwNumberOfIncomplete = _serviceHw.getNumberOfIncomplete();
    int examNumberOfIncomplete = _serviceExam.getNumberOfIncomplete();

    return Scaffold(
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     HapticFeedback.lightImpact();
      //   },
      //   label: const Text('Plan-it'),
      //   icon: const Icon(Icons.schedule),
      // ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context)
                  .colorScheme
                  .secondaryContainer
                  .withAlpha(100),
            ),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overview:',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hwNumberOfIncomplete.toString(),
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      examNumberOfIncomplete.toString(),
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'uncompleted homeworks',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'upcoming exams',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
