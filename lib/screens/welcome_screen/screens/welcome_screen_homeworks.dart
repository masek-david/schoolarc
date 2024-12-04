import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/widgets/animated_completion.dart';

class WelcomeScreenHomeworks extends StatefulWidget {
  const WelcomeScreenHomeworks({super.key});

  @override
  State<WelcomeScreenHomeworks> createState() => _WelcomeScreenHomeworksState();
}

class _WelcomeScreenHomeworksState extends State<WelcomeScreenHomeworks>
    with TickerProviderStateMixin {
  late SlidableController _controller;
  late final homeworks = List.generate(4, (index) {
    String text = '';

    switch (index) {
      case 0:
        text = 'Slide and tap to delete';
      case 1:
        text = 'Tap to edit';
      case 2:
        text = 'Hold to reorder';
      case 3:
        text = 'Check to complete  ->';
    }

    return HomeworkDTO(
      subject: SubjectDTO(name: 'Subject', shortcut: 'Hw', dbIndex: 0),
      text: text,
      description: null,
      deadline: DateTime.now().toUtc().add(const Duration(days: 1)).toLocal(),
      completion: false,
      priority: TaskPriority(index),
      dbIndex: index,
    );
  });

  @override
  void initState() {
    super.initState();

    _controller = SlidableController(this);

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _controller.openTo(-0.3);
      }
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.close();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlidableAutoCloseBehavior(
      child: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'Learn how to interact with the homeworks:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 50),
            Expanded(
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  showMessage(context, 'This way you reorder');
                  setState(() {
                    final removedHw = homeworks.removeAt(oldIndex);
                    homeworks.insert(
                        newIndex >= oldIndex ? newIndex - 1 : newIndex,
                        removedHw);
                  });
                },
                children: [
                  ...homeworks.map(
                    (e) {
                      return Padding(
                        key: Key('welcome_hw_${e.dbIndex}'),
                        padding: const EdgeInsets.all(8.0),
                        child: AnimatedCompletionTile(
                          hw: e,
                          slidableController:
                              e.dbIndex == 0 ? _controller : null,
                          onAnimationEnd: () {},
                          onChangedCompletion: (p0) {
                            if (p0) {
                              showMessage(context,
                                  'And this way you check the homework!');
                            }
                          },
                          onDelete: () {
                            showMessage(context, 'Homework would be deleted');
                          },
                          onEdit: () {
                            showMessage(context, 'Now you could edit');
                          },
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
