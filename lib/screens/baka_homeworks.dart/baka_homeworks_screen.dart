import 'package:flutter/material.dart';
import 'package:school_manager/screens/homeworks/widgets/homework_tile.dart';
import 'package:school_manager/services/bakalari/baka_service.dart';
import 'package:school_manager/tasks_app.dart';

class BakaHomeworksScreen extends StatelessWidget {
  BakaHomeworksScreen({super.key});

  late final homeworks = bakaService.getHomeworks();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Homeworks from Bakaláři'),),
      body: FutureBuilder(
        future: homeworks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (!snapshot.hasData) {
            return const Text('No data');
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              BakaHomework hw = snapshot.data![index];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          homeworkService.saveNewHW(
                            date: hw.deadline,
                            priority: hw.priority.index,
                            subject: hw.subject,
                            text: hw.text,
                            description: hw.description,
                          );

                          showMessage(context, 'Saved homework');
                        },
                        icon: const Icon(Icons.add_circle_outline)),
                    Expanded(
                      child: AbsorbPointer(
                        child: HomeworkTile(
                          hw: hw,
                          onChangedCompletion: (p0) {},
                          onDelete: () {},
                          onEdit: () {},
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
