import 'package:flutter/material.dart';
// import 'package:school_manager/homeworks/data/hw_service.dart';
import 'package:school_manager/exams/data/exam_service.dart';
import 'package:school_manager/screens/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  // final ServiceHW _serviceHw = ServiceHW();
  final ServiceExam _serviceExam = ServiceExam();

  @override
  Widget build(BuildContext context) {
    _serviceExam.initiate();
    int examNumberOfIncomplete = _serviceExam.getNumberOfIncomplete();
    // int homeworkNumberOfIncomplete = _serviceHw.getNumberOfIncomplete();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Home'),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              label: const Icon(Icons.settings),
            )
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {},
      //   label: const Text('Plan-it'),
      //   icon: const Icon(Icons.schedule),
      // ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            // margin: const EdgeInsets.all(value),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                    const Text(
                      'num',
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      examNumberOfIncomplete.toString(),
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'upcoming homeworks',
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      'upcoming exams',
                      style: TextStyle(fontSize: 15),
                    ),
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
