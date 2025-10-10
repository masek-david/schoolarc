import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_entity_model.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_entity_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/models/task_model.dart';

class Member {
  Member(
    this.id,
    this.name, {
    this.waitingForApproval = false,
    this.isYou = false,
    this.isOwner = false,
  });
  final String name;
  final String id;
  final bool waitingForApproval;
  final bool isYou;
  final bool isOwner;
}

class Group {
  Group({
    required this.groupId,
    required this.groupName,
    required this.members,
    required this.tasks,
  });

  final String groupName;
  final String groupId;
  final List<Member> members;
  final List<GroupTask> tasks;
}

class GroupTask extends Task {
  GroupTask({
    required super.id,
    required super.timestamp,
    required super.isDeleted,
    required super.subject,
    required super.text,
    required super.date,
    required super.isCompleted,
    required super.priority,
    required super.description,
    required super.order,
    required this.member,
  });

  final Member member;
}

class GroupHomeworkData {
  GroupHomeworkData({
    required this.hw,
    required this.id,
    required this.memberId,
  });

  final HomeworkEntity hw;
  final String id;
  final String memberId;

  factory GroupHomeworkData.fromJson(Map<String, dynamic> json) {
    return GroupHomeworkData(
      hw: HomeworkEntity(
        text: json['n'],
        description: json['i'] ?? '',
        subjectId: json['s'],
        // TODO fire
        date: Date.today(),
        // date: DateTime.fromMillisecondsSinceEpoch(json['d']),
        priority: json['p'] ?? 0,
        order: json['o'] ?? 0,
        isCompleted: json['c'] ?? true,
        isDeleted: json['del'] ?? false,
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['t']),
      ),
      id: json['id'],
      memberId: json['memberId'],
    );
  }

  GroupHomework convert(Subject? subject, Member member) {
    return GroupHomework(
      subject: subject,
      text: hw.text,
      // TODO fire
      // date: Date.fromDateTime(hw.date.toLocal()),
      date: Date.today(),
      isCompleted: hw.isCompleted,
      priority: TaskPriority(hw.priority),
      id: id,
      description: hw.description,
      timestamp: hw.timestamp,
      isDeleted: hw.isDeleted,
      order: hw.order,
      member: member,
    );
  }
}

class GroupHomework extends GroupTask {
  GroupHomework({
    required super.subject,
    required super.text,
    required super.date,
    required super.isCompleted,
    required super.priority,
    required super.id,
    required super.description,
    required super.timestamp,
    required super.isDeleted,
    required super.order,
    required super.member,
  });

  Homework toHomework() {
    return Homework(
      subject: subject,
      text: text,
      date: date,
      isCompleted: isCompleted,
      priority: priority,
      id: id,
      description: description,
      timestamp: timestamp,
      isDeleted: isDeleted,
      order: order,
    );
  }
}

class GroupExamData {
  GroupExamData({
    required this.exam,
    required this.id,
    required this.memberId,
  });

  final ExamEntity exam;
  final String id;
  final String memberId;

  factory GroupExamData.fromJson(Map<String, dynamic> json) {
    return GroupExamData(
      exam: ExamEntity(
        text: json['n'],
        description: json['i'] ?? '',
        subjectId: json['s'],
        // TODO fire
        date: Date.today(),
        // date: DateTime.fromMillisecondsSinceEpoch(json['d']),
        priority: json['p'] ?? 0,
        order: json['o'] ?? 0,
        isDeleted: json['del'] ?? false,
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['t']),
      ),
      id: json['id'],
      memberId: json['memberId'],
    );
  }

  GroupExam convert(Subject? subject, Member member) {
    return GroupExam(
      subject: subject,
      text: exam.text,
      date: exam.date,
      isCompleted: exam.date.isBefore(Date.today()),
      priority: TaskPriority(exam.priority),
      id: id,
      description: exam.description,
      timestamp: exam.timestamp,
      isDeleted: exam.isDeleted,
      order: exam.order,
      member: member,
    );
  }
}

class GroupExam extends GroupTask {
  GroupExam({
    required super.subject,
    required super.text,
    required super.date,
    required super.isCompleted,
    required super.priority,
    required super.id,
    required super.description,
    required super.timestamp,
    required super.isDeleted,
    required super.order,
    required super.member,
  });

  Exam toExam() {
    return Exam(
      subject: subject,
      text: text,
      date: date,
      priority: priority,
      id: id,
      isCompleted: isCompleted,
      description: description,
      timestamp: timestamp,
      isDeleted: isDeleted,
      order: order,
    );
  }
}
