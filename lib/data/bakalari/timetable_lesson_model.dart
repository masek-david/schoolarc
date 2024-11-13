import 'package:flutter/material.dart';
import 'package:school_manager/data/bakalari/teacher_model.dart';
import 'package:school_manager/data/bakalari/timetable_change.dart';
import 'package:school_manager/data/subjects_data/subject_dto_model.dart';

class TimeTableLesson {
  TimeTableLesson({
    this.subject,
    this.change,
    this.teacher,
    this.room,
  });

  TimeTableLesson.empty();

  SubjectDTO? subject;
  BakaChange? change;
  String? room;
  Teacher? teacher;

  bool get isEmpty {
    return subject == null && change == null;
  }

  void showLessonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(subject?.name ?? 'Empty lesson'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(change != null) Text('Change: ${change?.description}'),
            if(teacher != null) Text('Teacher: ${teacher?.name}'),
            if(room != null) Text('Room: $room'),
          ],
        ),
      ),
    );
  }
}
