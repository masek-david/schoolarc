import 'package:flutter/material.dart';
import 'package:school_manager/homeworks/data/hw_service.dart';
import 'package:school_manager/exams/data/exam_service.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final ServiceHW _serviceHW = ServiceHW();
  final ServiceExam _serviceExam = ServiceExam();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Plan-it'),
        icon: const Icon(Icons.schedule),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            // margin: const EdgeInsets.all(value),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today:',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('number Homeworks'),
                    Text('number Exams'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
