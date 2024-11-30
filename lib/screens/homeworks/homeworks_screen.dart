import 'package:flutter/material.dart';
import 'package:school_manager/screens/homeworks/widgets/priority_view.dart';
import 'package:school_manager/tasks_app.dart';

class HomeworksScreen extends StatefulWidget {
  const HomeworksScreen({super.key});

  @override
  State<HomeworksScreen> createState() => _HomeworksScreenState();
}

class _HomeworksScreenState extends State<HomeworksScreen> {
  late var hwByPriority = homeworkService.sortByPriority(null);
  late var completedHw = homeworkService.getCompletedHw(null);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    updateListView();
  }

  void updateListView() {
    if (mounted) {
      setState(() {
        hwByPriority = homeworkService.sortByPriority(context);
        completedHw = homeworkService.getCompletedHw(context);
      });
    }
  }

  void reorderHomework(int oldItemIndex, int oldPriority, int newItemIndex,
      int newPriority) async {
    await homeworkService.changeSequence(
        oldItemIndex, oldPriority, newItemIndex, newPriority);

    updateListView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const DrawerButton(
          onPressed: switchDrawer,
        ),
        title: const Text('Homeworks'),
      ),
      body: PriorityView(
        hwByPriority: hwByPriority,
        completedHws: completedHw,
        reorderHomework: reorderHomework,
        updateView: updateListView,
      ),
    );
  }
}
