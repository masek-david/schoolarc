import 'package:school_manager/data/subjects_data/subject_dto_model.dart';
import 'package:school_manager/data/table_data/lesson_times_model.dart';

class TimeTableDTO {
  TimeTableDTO({
    required this.lessonTimes,
    required this.table,
  });

  // index and times for lessons
  List<LessonTimes> lessonTimes;
  late List<List<SubjectDTO?>> table;

  DateTime? nextDateForSubject(SubjectDTO subject) {
    if(lessonTimes.isEmpty){
      return null;
    }
    
    var now = DateTime.now();
    // int weekday = now.weekday - 1;

    var date = DateTime.utc(now.year, now.month, now.day);

    for (int i = date.weekday - 1; i < 100; i++) {
      date = date.add(const Duration(days: 1));
      var listOfSubjects = table[date.weekday - 1].where((element) {
        bool contains = element?.dbIndex == subject.dbIndex;
        return contains;
      });
      if (listOfSubjects.isNotEmpty) {
        return date.toLocal();
      }
    }

    return null;
  }
}
