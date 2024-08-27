import 'package:flutter/material.dart';
import 'package:school_manager/screens/homeworks/widgets/priority_view.dart';
import 'package:school_manager/data/homeworks_data/hw_service.dart';
import 'package:school_manager/screens/homeworks/widgets/hw_bottom_sheet.dart';
import 'package:school_manager/data/homeworks_data/hw_dto_model.dart';

class HomeworksScreen extends StatefulWidget {
  const HomeworksScreen({super.key});

  @override
  State<HomeworksScreen> createState() => _HomeworksScreenState();
}

class _HomeworksScreenState extends State<HomeworksScreen> {
  ServiceHW service = ServiceHW();
  Map<int, List<HomeworkDTO>> hwByPriority = {
    0: <HomeworkDTO>[],
    1: <HomeworkDTO>[],
    2: <HomeworkDTO>[],
    3: <HomeworkDTO>[],
  };
  List<HomeworkDTO> completedHw = [];

  // text controllers for creating and editing hw
  var _subjectController = TextEditingController();
  var _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    service.initiate();

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

  void changeCompletion(int dbIndex) {
    service.changeCompletion(dbIndex);
    updateListView();
  }

  Future<void> createNewHw({DateTime? initialDate}) async {
    initialDate ??= DateTime.now();
    // pokud je initial date null, nastavi se na datetime.now

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) {
        return HwBottomSheet(
          subjectController: _subjectController,
          nameController: _nameController,
          initialDate: initialDate!,
          initialPriority: 0,
          initialCompletion: false,
          index: 0, // index neni potreba u zakladani noveho ukolu
          onSave: ({
            required context,
            required date,
            required index,
            required priority,
            required subject,
            required completion,
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
      },
    ).then(
      // po zavreni bottomSheetu se smaze uzivatelem zadany text
      (value) => {
        _nameController.clear(),
        _subjectController.clear(),
      },
    );
  }

  void editHw(int dbIndex) {
    HomeworkDTO currentlyEditedTask = service.getHomework(dbIndex);
    _nameController = TextEditingController(text: currentlyEditedTask.text);
    _subjectController =
        TextEditingController(text: currentlyEditedTask.subject);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) {
        return HwBottomSheet(
          subjectController: _subjectController,
          nameController: _nameController,
          initialDate: currentlyEditedTask.deadline,
          initialPriority: currentlyEditedTask.priority,
          initialCompletion: currentlyEditedTask.completion,
          index: dbIndex,
          onSave: (
              {required context,
              required date,
              required index,
              required priority,
              required subject,
              required completion,
              required text}) {
            service.saveEditedHW(
              date: date,
              priority: priority,
              dbIndex: index,
              subject: subject,
              text: text,
              completion: completion,
            );
            updateListView();
          },
        );
      },
    ).then(
      (value) => {
        _nameController.clear(),
        _subjectController.clear(),
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
        changeCompletion: changeCompletion,
        createNewHw: createNewHw,
        deleteHw: deleteHw,
        editHw: editHw,
        reorderHomework: reorderHomework,
      ),
    );
  }
}
