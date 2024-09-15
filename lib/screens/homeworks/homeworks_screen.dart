import 'package:flutter/material.dart';
import 'package:school_manager/data/priority_model.dart';
import 'package:school_manager/screens/homeworks/widgets/priority_view.dart';
import 'package:school_manager/data/homeworks_data/hw_service.dart';
import 'package:school_manager/widgets/add_bottom_sheet/add_bottom_sheet.dart';
import 'package:school_manager/data/homeworks_data/hw_dto_model.dart';

class HomeworksScreen extends StatefulWidget {
  const HomeworksScreen({super.key});

  @override
  State<HomeworksScreen> createState() => _HomeworksScreenState();
}

class _HomeworksScreenState extends State<HomeworksScreen> {
  HomeworkService service = HomeworkService();
  Map<int, List<HomeworkDTO>> hwByPriority = {
    0: <HomeworkDTO>[],
    1: <HomeworkDTO>[],
    2: <HomeworkDTO>[],
    3: <HomeworkDTO>[],
  };
  List<HomeworkDTO> completedHw = [];
  late List<Priority> priorities = List.generate(
    4,
    (index) => Priority(index, context),
  );

  @override
  void initState() {
    super.initState();

    hwByPriority = service.sortByPriority();
    completedHw = service.getCompletedHw();
  }

  /// deletes hw from db and shows snackbar to undo it
  void deleteHw(int dbIndex) {
    service.deleteHw(dbIndex);
    updateListView();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Homework deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            service.revertLastlyDeletedHw();
            updateListView();
          },
        ),
      ),
    );
  }

  void changeCompletion(int dbIndex, bool value) {
    service.changeCompletion(dbIndex, value);
  }

  void createNewHw() {
    showAddBottomSheet(
      context,
      onSave: ({
        required date,
        required priority,
        subject,
        required text,
      }) async {
        await service.saveNewHW(
          date: date,
          priority: priority,
          subject: subject,
          text: text,
        );
        updateListView();
      },
    );
  }

  void editHw(int dbIndex) {
    HomeworkDTO currentlyEditedTask = service.getHomework(dbIndex);

    showAddBottomSheet(
      context,
      initialName: currentlyEditedTask.text,
      initialSubject: currentlyEditedTask.subject,
      initialDate: currentlyEditedTask.deadline,
      initialPriority: currentlyEditedTask.priority,
      onSave: ({
        required date,
        required priority,
        required text,
        subject,
      }) async {
        await service.saveEditedHW(
          date: date,
          priority: priority,
          dbIndex: dbIndex,
          subject: subject,
          text: text,
          completion: currentlyEditedTask.completion,
        );
        updateListView();
      },
    );
  }

  void reorderHomework(
      int oldItemIndex, int oldPriority, int newItemIndex, int newPriority) {
    service.changeSequence(
        oldItemIndex, oldPriority, newItemIndex, newPriority);
    updateListView();
  }

  void updateListView() {
    if (mounted) {
      setState(() {
        hwByPriority = service.sortByPriority();
        completedHw = service.getCompletedHw();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PriorityView(
        hwByPriority: hwByPriority,
        completedHws: completedHw,
        priorities: priorities,
        changeCompletion: changeCompletion,
        createNewHw: createNewHw,
        deleteHw: deleteHw,
        editHw: editHw,
        reorderHomework: reorderHomework,
        updateView: updateListView,
      ),
    );
  }
}
