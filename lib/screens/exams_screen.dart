import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_manager/exams/data/exam_service.dart';
import 'package:school_manager/exams/data/exam_dto_model.dart';
import 'package:school_manager/exams/util/exam_bottom_sheet.dart';
import 'package:school_manager/exams/calendar_view.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  ServiceExam service = ServiceExam();
  Map<int, List<ExamDTO>> examsByPriority = {
    0: <ExamDTO>[],
    1: <ExamDTO>[],
    2: <ExamDTO>[],
    3: <ExamDTO>[],
  };
  Map<DateTime, List<ExamDTO>> examsByDate = {};

  bool calendarView = true;
  Widget viewWidget = const Placeholder();

  @override
  void initState() {
    super.initState();
    service.initiate();

    examsByPriority = service.sortByPriority();
    examsByDate = service.sortByDate();
  }

  // text controller
  var _subjectController = TextEditingController();
  var _nameController = TextEditingController();

  // deletes exam and shows snackbar to undo it
  void deleteExam(int index) {
    setState(
      () {
        ExamDTO deletedExam = service.getExam(index);
        service.deleteExam(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Homework deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  service.saveNewExam(
                      date: deletedExam.date,
                      priority: deletedExam.priority,
                      subject: deletedExam.subject,
                      text: deletedExam.text);
                  examsByPriority = service.sortByPriority();
                  examsByDate = service.sortByDate();
                });
              },
            ),
          ),
        );
        examsByPriority = service.sortByPriority();
        examsByDate = service.sortByDate();
      },
    );
  }

  void createNewExam() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) {
        return ExamBottomSheet(
          subjectController: _subjectController,
          nameController: _nameController,
          initialDate: DateTime.now(),
          initialPriority: 0,
          index: 0, // index neni potreba u zakladani noveho listu
          onSave: ({
            required context,
            required date,
            required index,
            required priority,
            required subject,
            required text,
          }) {
            setState(
              () {
                service.saveNewExam(
                  date: date,
                  priority: priority,
                  // index: index,
                  subject: subject,
                  text: text,
                );
                examsByPriority = service.sortByPriority();
                examsByDate = service.sortByDate();
                Navigator.of(context).pop();
              },
            );
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

  void editExam(int index) {
    ExamDTO currentlyEditedTask = service.getExam(index);
    _nameController = TextEditingController(text: currentlyEditedTask.text);
    _subjectController =
        TextEditingController(text: currentlyEditedTask.subject);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) {
        return ExamBottomSheet(
          subjectController: _subjectController,
          nameController: _nameController,
          initialDate: currentlyEditedTask.date,
          initialPriority: currentlyEditedTask.priority,
          index: index,
          onSave: (
              {required context,
              required date,
              required index,
              required priority,
              required subject,
              required text}) {
            setState(() {
              service.saveEditedExam(
                date: date,
                priority: priority,
                index: index,
                subject: subject,
                text: text,
              );
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
    });
  }

  @override
  Widget build(BuildContext context) {
    Icon viewIcon;

    if (calendarView) {
      viewIcon = const Icon(Icons.calendar_view_day);
      viewWidget = CalendarView(
        examsByDate: examsByDate,
        deleteExam: deleteExam,
        editExam: editExam,
      );
    } else {
      viewIcon = const Icon(Icons.calendar_today);
      viewWidget = const Text('list view');
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Exams'),
            TextButton(
              onPressed: switchView,
              child: viewIcon,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createNewExam();
          HapticFeedback.lightImpact();
        },
        enableFeedback: true,
        child: const Icon(Icons.add),
      ),
      body: viewWidget,
    );
  }
}
