import 'package:flutter/material.dart';
import 'package:school_manager/screens/baka_homeworks.dart/baka_hw_tile.dart';
import 'package:school_manager/services/bakalari/baka_service.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/widgets/error_tile.dart';

class BakaHomeworksScreen extends StatefulWidget {
  const BakaHomeworksScreen({super.key});

  @override
  State<BakaHomeworksScreen> createState() => _BakaHomeworksScreenState();
}

class _BakaHomeworksScreenState extends State<BakaHomeworksScreen> {
  late final homeworksFuture = bakaService.getHomeworks();
  var homeworks = <BakaHomework>[];

  void add(BuildContext context, BakaHomework hw) {
    homeworkService.saveNewHW(
      date: hw.deadline,
      priority: hw.priority.index,
      subject: hw.subject,
      text: hw.text,
      description: hw.description,
    );

    bakaHomeworkService.addedHomework(hw.bakaId);

    setState(() {
      homeworks
          .firstWhere(
            (element) => element.bakaId == hw.bakaId,
          )
          .alreadyAdded = true;
    });

    showMessage(context, 'Saved homework');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homeworks from Bakaláři'),
      ),
      body: FutureBuilder(
        future: homeworksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return ErrorTile(error: snapshot.error);
          } else if (!snapshot.hasData) {
            return const Text('No data');
          }

          homeworks = snapshot.data!;

          final newHw = homeworks.where((hw) => !hw.alreadySeen).toList();
          final otherHw = homeworks.where((hw) => hw.alreadySeen).toList();
          otherHw.sort((a, b) => (a.deadline.compareTo(b.deadline)));
          otherHw.sort((a, b) => (a.alreadyAdded == b.alreadyAdded ? 0 : (a.alreadyAdded ? 1 : -1)));

          bool showNew = newHw.isNotEmpty;

          return ListView.builder(
            itemCount: otherHw.length + (showNew ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == 0 && showNew) {
                return Card(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 16),
                        child: Text(
                          'New homeworks',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      ...newHw.map(
                        (hw) {
                          bakaHomeworkService.seenHomework(hw.bakaId);

                          return BakaHwTile(
                            hw: hw,
                            onAdd: () => add(context, hw),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }

              BakaHomework hw = otherHw[index - (showNew ? 1 : 0)];

              return BakaHwTile(
                hw: hw,
                onAdd: () => add(context, hw),
              );
            },
          );
        },
      ),
    );
  }
}
