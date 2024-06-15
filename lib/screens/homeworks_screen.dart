import 'package:flutter/material.dart';
import 'package:school_manager/homeworks/calendar_view.dart';
import 'package:school_manager/homeworks/priority_view.dart';
import 'package:school_manager/homeworks/data/hw_service.dart';
import 'package:school_manager/homeworks/util/hw_bottom_sheet.dart';
import 'package:school_manager/homeworks/data/hw_dto_model.dart';

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
  Map<DateTime, List<HomeworkDTO>> hwByDate = {};

  bool calendarView = false;
  Widget viewWidget = const Placeholder();

  // text controllers for creating and editing hw
  var _subjectController = TextEditingController();
  var _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    service.initiate();

    hwByPriority = service.sortByPriority();
    hwByDate = service.sortByDate();
    completedHw = service.getCompletedHw();
  }

  // deletes hw and shows snackbar to undo it
  void deleteHw(int index) {
    setState(() {
      HomeworkDTO deletedHw = service.getHomework(index);
      service.deleteHw(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Homework deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                service.saveNewHW(
                    date: deletedHw.deadline,
                    priority: deletedHw.priority,
                    subject: deletedHw.subject,
                    text: deletedHw.text);
                hwByPriority = service.sortByPriority();
              });
            },
          ),
        ),
      );
      updateList();
    });
  }

  void changeCompletion(int dbIndex) {
    setState(() {
      service.changeCompletion(dbIndex);
      updateList();
    });
  }

  Future<void> createNewHw({DateTime? initialDate}) async {
    initialDate ??= DateTime.now();

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
          index: 0, // index neni potreba u zakladani noveho listu
          onSave: ({
            required context,
            required date,
            required index,
            required priority,
            required subject,
            required completion,
            required text,
          }) {
            setState(() {
              service.saveNewHW(
                date: date,
                priority: priority,
                subject: subject,
                text: text,
              );
              updateList();
              Navigator.of(context).pop();
            });
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

  void editHw(int index) {
    HomeworkDTO currentlyEditedTask = service.getHomework(index);
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
          index: index,
          onSave: (
              {required context,
              required date,
              required index,
              required priority,
              required subject,
              required completion,
              required text}) {
            setState(() {
              service.saveEditedHW(
                date: date,
                priority: priority,
                index: index,
                subject: subject,
                text: text,
                completion: completion,
              );
              updateList();
              Navigator.of(context).pop();
            });
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

  void switchView() {
    setState(() {
      calendarView = !calendarView;
      updateList();
    });
  }

  void updateList() {
    if (calendarView) {
      hwByDate = service.sortByDate();
    } else {
      hwByPriority = service.sortByPriority();
      completedHw = service.getCompletedHw();
    }
  }

  @override
  Widget build(BuildContext context) {
    Icon viewIcon;

    if (calendarView) {
      viewIcon = const Icon(Icons.calendar_view_day);
      viewWidget = CalendarView(
        hwByDate: hwByDate,
        createNewHw: createNewHw,
        changeCompletion: changeCompletion,
        deleteHw: deleteHw,
        editHw: editHw,
      );
    } else {
      viewIcon = const Icon(Icons.calendar_today);
      viewWidget = PriorityView(
        hwByPriority: hwByPriority,
        completedHws: completedHw,
        changeCompletion: changeCompletion,
        createNewHw: createNewHw,
        deleteHw: deleteHw,
        editHw: editHw,
      );
    }

    return Scaffold(
      body: viewWidget,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Homeworks'),
            TextButton(
              onPressed: switchView,
              child: viewIcon,
            )
          ],
        ),
      ),
    );
  }
}
