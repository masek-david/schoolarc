import 'package:flutter/material.dart';
import 'package:school_manager/homeworks/data/hw_service.dart';
import 'package:school_manager/exams/data/exam_service.dart';
import 'package:school_manager/screens/settings_screen.dart';
import 'package:school_manager/util/side_nav.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final ServiceHW _serviceHw = ServiceHW();
  final ServiceExam _serviceExam = ServiceExam();

  @override
  Widget build(BuildContext context) {
    _serviceHw.initiate();
    _serviceExam.initiate();
    int hwNumberOfIncomplete = _serviceHw.getNumberOfIncomplete();
    int examNumberOfIncomplete = _serviceExam.getNumberOfIncomplete();

    return Scaffold(
      drawer: const MyDrawer(),
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
              color: Theme.of(context).colorScheme.primary.withAlpha(25),
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
