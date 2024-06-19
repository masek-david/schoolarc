import 'package:flutter/material.dart';
import 'package:school_manager/exams/data/exam_service.dart';
import 'package:school_manager/exams/data/exam_dto_model.dart';
import 'package:school_manager/exams/util/exam_bottom_sheet.dart';
import 'package:school_manager/exams/calendar_view.dart';
import 'package:school_manager/exams/priority_view.dart';
import 'package:school_manager/util/side_nav.dart';

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
  List<ExamDTO> completedExams = [];
  Map<DateTime, List<ExamDTO>> examsByDate = {};

  bool calendarView = false;
  Widget viewWidget = const Placeholder();

  @override
  void initState() {
    super.initState();
    service.initiate();

    examsByPriority = service.sortByPriority();
    examsByDate = service.sortByDate();
    completedExams =  service.getCompletedExams();
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
        updateList();
      },
    );
  }

  Future<void> createNewExam({DateTime? initialDate}) async {
    initialDate ??= DateTime.now();       // pokud je initial date null, nastavi se na datetime.now
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) {
        return ExamBottomSheet(
          subjectController: _subjectController,
          nameController: _nameController,
          initialDate: initialDate!,
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
                  subject: subject,
                  text: text,
                );
                updateList();
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
              updateList();
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
      examsByDate = service.sortByDate();
    } else {
      examsByPriority = service.sortByPriority();
      completedExams = service.getCompletedExams();
    }
  }

  @override
  Widget build(BuildContext context) {
    Icon viewIcon;

    if (calendarView) {
      viewIcon = const Icon(Icons.calendar_view_day);
      viewWidget = CalendarView(
        examsByDate: examsByDate,
        createNewExam: createNewExam,
        deleteExam: deleteExam,
        editExam: editExam,
      );
    } else {
      viewIcon = const Icon(Icons.calendar_today);
      viewWidget = PriorityView(
        examsByPriority: examsByPriority,
        completedExams: completedExams,
        createNewExam: createNewExam,
        deleteExam: deleteExam,
        editExam: editExam,
      );
    }
    return Scaffold(
      body: viewWidget,
      drawer: const MyDrawer(),
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
    );
  }
}
