import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:school_manager/models/bakalari/lesson_time_baka.dart';
import 'package:school_manager/models/bakalari/teacher_model.dart';
import 'package:school_manager/models/bakalari/timetable_change.dart';
import 'package:school_manager/models/bakalari/timetable_lesson_model.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/provider/subject_notifier.dart';
import 'package:school_manager/services/secure_storage.dart';
import 'package:school_manager/models/exception_model.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/models/timetable/table_dto_model.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/services/timetable_database.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';
import 'package:school_manager/tasks_app.dart';

class BakaHomework extends HomeworkDTO {
  BakaHomework({
    required super.isCompleted,
    required super.dbIndex,
    required super.deadline,
    required super.description,
    required super.priority,
    required super.subject,
    required super.text,
    required this.alreadyAdded,
    required this.alreadySeen,
    required this.bakaId,
    required super.fireId,
    required super.timestamp,
    required super.isDeleted,
    required super.order,
  });

  final String bakaId;
  bool alreadyAdded;
  final bool alreadySeen;
}

class BakaService {
  // sussy baka
  BakaService();
  String? _accessToken;
  String? _refreshToken;

  DateTime? _tokenExpiration;

  final _timetableDb = TimeTableDatabase();
  final _secureStorage = SecureStorage();

  bool get isLoggedIn {
    if (_tokenExpiration == null) {
      return false;
    }
    if (_accessToken == null) {
      return false;
    }
    return DateTime.now().isBefore(_tokenExpiration!);
  }

  Future<String> get username async {
    return _secureStorage.read(SecureStorage.bakaUsernameKey);
  }

  Future<String> get schoolName async {
    return _secureStorage.read(SecureStorage.bakaSchoolNameKey);
  }

  Future<String> get _getRefreshToken async {
    return _secureStorage.read(SecureStorage.bakaRefreshTokenKey);
  }

  Future<void> saveToSecureStorage(String key, String value) async {
    _secureStorage.write(key, value);
  }

  /// tries to log in from memory using saved refresh token
  Future<void> refreshLogin() async {
    String schoolName = await this.schoolName;
    _refreshToken = await _getRefreshToken;

    if (schoolName == '' || _refreshToken == '') {
      throw ServiceException('Please log in first',
          action: ExceptionActions.bakaLogin);
    }

    final url = Uri(
      scheme: 'https',
      host: "$schoolName.bakalari.cz",
      path: "/api/login",
    );
    const head = {
      "Content-Type": "application/x-www-form-urlencoded",
    };
    final body =
        'client_id=ANDR&grant_type=refresh_token&refresh_token=$_refreshToken';

    try {
      await _callLogin(url, head, body);
    } on Object {
      rethrow;
    }

    saveToSecureStorage(SecureStorage.bakaRefreshTokenKey, _refreshToken!);

    loadName();
  }

  Future<void> firstLogin({
    required String school,
    required String username,
    required String password,
    required bool keepLoggedIn,
  }) async {
    if (school == '' || username == '' || password == '') {
      throw ServiceException('Please fill out all information');
    }

    final url = Uri(
      scheme: 'https',
      host: "$school.bakalari.cz",
      path: "/api/login",
    );
    const head = {"Content-Type": "application/x-www-form-urlencoded"};
    final body =
        'client_id=ANDR&grant_type=password&username=$username&password=$password';

    try {
      await _callLogin(url, head, body);
    } on Object {
      rethrow;
    }

    if (keepLoggedIn) {
      saveToSecureStorage(SecureStorage.bakaRefreshTokenKey, _refreshToken!);
      saveToSecureStorage(SecureStorage.bakaSchoolNameKey, school);
      saveToSecureStorage(SecureStorage.bakaUsernameKey, username);
    } else {
      // it has to be overwriten if the user chooses
      saveToSecureStorage(SecureStorage.bakaRefreshTokenKey, '');
      saveToSecureStorage(SecureStorage.bakaSchoolNameKey, '');
      saveToSecureStorage(SecureStorage.bakaUsernameKey, '');
    }
  }

  /// logs in, returns errors and sets this._refreshToken and this._accessToken
  Future<void> _callLogin(Uri url, var head, var body) async {
    Response response;
    try {
      response = await http.post(
        url,
        headers: head,
        body: body,
      );
    } on SocketException catch (_) {
      throw ServiceException(
          'Check your internet connection. \nCouldn\'t connect to the address: $url.');
    } catch (e) {
      throw ServiceException('An unexpected error occurred: $e');
    }

    // when the url or school is incorrect, it needs to be decoded
    if (!response.body.startsWith('{')) {
      List<int> bytes = latin1.encode(response.body);
      throw ServiceException(utf8.decode(bytes));
    }

    final parsedJson = json.decode(response.body);
    final error = parsedJson['error'];
    if (error != null) {
      throw ServiceException(error);
    }

    final accessToken = parsedJson["access_token"];
    final refreshToken = parsedJson["refresh_token"];
    final expiresInSeconds = parsedJson['expires_in'] as int;

    if (accessToken == null || refreshToken == null) {
      throw ServiceException(parsedJson['error_description']);
    }

    _accessToken = accessToken;
    _refreshToken = refreshToken;
    saveToSecureStorage(SecureStorage.bakaRefreshTokenKey, refreshToken);
    _tokenExpiration =
        DateTime.now().toUtc().add(Duration(seconds: expiresInSeconds));
  }

  Future<void> loadName() async {
    Response response;
    try {
      String schoolName = await this.schoolName;
      final url = Uri(
        scheme: 'https',
        host: "$schoolName.bakalari.cz",
        path: "/api/3/user",
      );

      response = await http.get(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": " Bearer $_accessToken",
        },
      );
    } on Object {
      return;
    }

    final json = jsonDecode(response.body);

    String fullName = json['FullName'];

    settings.save(Setting.userName, fullName.replaceAll(',', '').split(' ')[1]);
  }

  /// returns list of subjects from bakalari
  Future<List<Subject>> _getAllSubjects() async {
    if (!isLoggedIn) {
      try {
        await refreshLogin();
      } on Object {
        rethrow;
      }
    }

    String schoolName = await this.schoolName;
    final url = Uri(
      scheme: 'https',
      host: "$schoolName.bakalari.cz",
      path: "/api/3/subjects",
    );

    Response response;
    try {
      response = await http.get(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": " Bearer $_accessToken",
        },
      );
    } on SocketException {
      throw ServiceException(
          'Check your internet connection. \nCouldn\'t connect to the address: $url.');
    } on Object catch (e) {
      throw ServiceException('An unexpected error occured: $e');
    }

    final parsedJson = json.decode(response.body);

    List<dynamic> listOfSubjectsJson = parsedJson['Subjects'];
    List<Subject> listOfSubjects = [];

    for (var subjectJson in listOfSubjectsJson) {
      String name = subjectJson['SubjectName'];
      String shortcut = subjectJson['SubjectAbbrev'];
      String bakaId = subjectJson['SubjectID'];

      // checks for duplicates, will add the teachers surname to the subject name
      for (var subject in listOfSubjects) {
        if (subject.name == name && subject.shortcut == shortcut) {
          String teacher = subjectJson['TeacherName'];
          name += ' ${teacher.split(' ')[0]}';
        }
      }

      listOfSubjects.add(
        Subject(
          name: name,
          shortcut: shortcut,
          bakaId: bakaId,
          fireId: null,
          isDeleted: false,
          timestamp: DateTime.now(),
          order: 0,
        ),
      );
    }

    return listOfSubjects;
  }

  Future<void> addAllSubjects() async {
    final result = await _getAllSubjects();
    List<Subject> list = result;
    for (var element in list) {
      container.read(subjectsProvider.notifier).saveNew(element);
    }
    return;
  }

  Future<void> overwriteAllSubjects() async {
    
    
    container.read(subjectsProvider.notifier).deleteAll();
    final result = await _getAllSubjects();

    List<Subject> list = result;
    for (var element in list) {
      container.read(subjectsProvider.notifier).saveNew(element);
    }

    return;
  }

  /// imports permanent timetable and saves it
  Future<void> importTimeTable() async {
    if (!isLoggedIn) {
      try {
        await refreshLogin();
      } on Object {
        rethrow;
      }
    }

    String schoolName = await this.schoolName;
    final url = Uri(
      scheme: 'https',
      host: "$schoolName.bakalari.cz",
      path: "/api/3/timetable/permanent",
    );

    Response response;
    try {
      response = await http.get(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": " Bearer $_accessToken",
        },
      );
    } on SocketException {
      throw ServiceException(
          'Check your internet connection. \nCouldn\'t connect to the address: $url.');
    } catch (e) {
      throw ServiceException('An unexpected error occurred: $e');
    }

    // when the url or school is incorrect, it needs to be decoded
    if (!response.body.startsWith('{')) {
      List<int> bytes = latin1.encode(response.body);
      throw ServiceException(utf8.decode(bytes));
    }

    final parsedJson = json.decode(response.body);

    if (parsedJson["Message"] != null) {
      throw ServiceException(parsedJson["Message"]);
    }

    var lessonsJson = parsedJson['Hours'] as List<dynamic>;
    final lessons = _getLessons(lessonsJson);
    _timetableDb.createTable(lessons.map(
      (lessonTimes) {
        return lessonTimes.toLessonTimes();
      },
    ).toList());

    var subjectsJson = parsedJson['Subjects'] as List<dynamic>;
    final bakaIdToSubjectIndex = await _getSubjectsIdToIndex(subjectsJson);

    var daysJson = parsedJson['Days'] as List<dynamic>;
    for (int weekday = 0; weekday < daysJson.length; weekday++) {
      final dayJson = daysJson[weekday];
      for (int lessonIndex = 0;
          lessonIndex < dayJson['Atoms'].length;
          lessonIndex++) {
        var subjectJson = dayJson['Atoms'][lessonIndex];

        String subjectIdBaka = subjectJson['SubjectId'];
        int subjectIndex = bakaIdToSubjectIndex[subjectIdBaka]!;
        int hourId = subjectJson['HourId'];

        _timetableDb.newLessonAt(
          weekday,
          lessons.indexWhere(
            (lesson) => lesson.id == hourId,
          ),
          subjectIndex,
        );
      }
    }
  }

  /// gets the current timetable for provided date, saturday and sunday are for next week
  Future<TimeTableDTO> getCurrentTimetable(DateTime date) async {
    if (!isLoggedIn) {
      try {
        await refreshLogin();
      } on Object {
        rethrow;
      }
    }

    DateTime mondayDate = date.toUtc();
    int weekday = date.toUtc().weekday;

    if (weekday == 6) {
      mondayDate = mondayDate.add(const Duration(days: 2));
    } else if (weekday == 7) {
      mondayDate = mondayDate.add(const Duration(days: 1));
    } else {
      mondayDate = mondayDate.add(Duration(days: 1 - weekday));
    }

    String schoolName = await this.schoolName;
    final url = Uri(
      scheme: 'https',
      host: "$schoolName.bakalari.cz",
      path: "/api/3/timetable/actual",
      queryParameters: {
        'date': DateFormat('yyyy-MM-dd').format(mondayDate.toLocal())
      },
    );

    Response response;
    try {
      response = await http.get(url, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Bearer $_accessToken",
      });
    } on SocketException {
      throw ServiceException(
          'Check your internet connection. \nCouldn\'t connect to the address: $url.');
    } catch (e) {
      throw ServiceException('An unexpected error occurred: $e');
    }

    // when the url or school is incorrect, it needs to be decoded
    if (!response.body.startsWith('{')) {
      List<int> bytes = latin1.encode(response.body);
      throw ServiceException(utf8.decode(bytes));
    }

    final parsedJson = json.decode(response.body);

    if (parsedJson["Message"] != null) {
      throw ServiceException(parsedJson["Message"]);
    }

    var lessonsJson = parsedJson['Hours'] as List<dynamic>;
    final lessons = _getLessons(lessonsJson);
    TimeTableDTO timeTable = TimeTableDTO(
        lessonTimes: lessons.map(
      (lessonTime) {
        return lessonTime.toLessonTimes();
      },
    ).toList());
    timeTable.dates = mondayDate.allDaysInThisWeek();

    var subjectsJson = parsedJson['Subjects'] as List<dynamic>;
    final bakaIdToSubjectIndex = await _getSubjectsIdToIndex(subjectsJson);
    final subjects = container.read(subjectsProvider);

    final teachersJson = parsedJson['Teachers'] as List<dynamic>;
    Map<String, Teacher> teachersMap = {};
    for (final teacherJson in teachersJson) {
      final teacher = Teacher(
        name: teacherJson['Name'],
        shortcut: teacherJson['Abbrev'],
      );

      teachersMap.addAll({teacherJson['Id']: teacher});
    }

    final roomsJson = parsedJson['Rooms'] as List<dynamic>;
    Map<String, String> roomsMap = {};
    for (final roomJson in roomsJson) {
      roomsMap.addAll({roomJson['Id']: roomJson['Abbrev']});
    }

    var daysJson = parsedJson['Days'] as List<dynamic>;
    for (int weekday = 0; weekday < daysJson.length; weekday++) {
      final dayJson = daysJson[weekday];
      for (int lessonIndex = 0;
          lessonIndex < dayJson['Atoms'].length;
          lessonIndex++) {
        var subjectJson = dayJson['Atoms'][lessonIndex];

        String? subjectIdBaka = subjectJson['SubjectId'];
        String? teacherId = subjectJson['TeacherId'];
        String? roomId = subjectJson['RoomId'];
        int? subjectIndex = bakaIdToSubjectIndex[subjectIdBaka];
        int hourId = subjectJson['HourId'];
        final changeJson = subjectJson['Change'];

        BakaChange? change;
        if (changeJson != null) {
          change = BakaChange(
            type: getChangeType(changeJson['ChangeType']),
            description: changeJson['Description'],
            name: changeJson['TypeName'],
            shortcut: changeJson['TypeAbbrev'],
          );
        }

        final subject = subjects[subjectIndex];

        final teacher = teachersMap[teacherId];
        final room = roomsMap[roomId];

        timeTable.table[weekday][lessons.indexWhere(
          (lesson) => lesson.id == hourId,
        )] = TimeTableLesson(
          subject: subject,
          change: change,
          teacher: teacher,
          room: room,
        );
      }
    }

    return timeTable;
  }

  /// for each id from baka, you have index of app's subjects, if the subject doesnt exist, it is created
  Future<Map<String, int>> _getSubjectsIdToIndex(
      List<dynamic> subjectsJson) async {
    final subjects = container.read(subjectsSortedProvider);
    Map<String, int> bakalariSubjectIdToSubjectIndex = {};

    for (var subjectJson in subjectsJson) {
      String bakaId = subjectJson['Id'];
      String shortcut = subjectJson['Abbrev'];
      String name = subjectJson['Name'];
      bool subjectExisted = false;

      for (var subject in subjects) {
        if (subject.bakaId == bakaId) {
          bakalariSubjectIdToSubjectIndex.addAll({bakaId: subject.dbIndex});
          subjectExisted = true;
          break;
        }
      }

      if (!subjectExisted) {
        var newSubject = await container.read(subjectsProvider.notifier).saveNew(
          Subject(
            name: name,
            shortcut: shortcut,
            bakaId: bakaId,
            fireId: null,
            isDeleted: false,
            order: 0,
            timestamp: Timestamp.now().toDate(),
          ),
        );
        bakalariSubjectIdToSubjectIndex.addAll({bakaId: newSubject.dbIndex});
      }
    }

    return bakalariSubjectIdToSubjectIndex;
  }

  List<LessonTimesBaka> _getLessons(List<dynamic> lessonsJson) {
    List<LessonTimesBaka> lessons = [];
    for (var lessonJson in lessonsJson) {
      final int id = lessonJson['Id'];
      final String name = lessonJson['Caption'];
      final String startTimeString = lessonJson['BeginTime'];
      final String endTimeString = lessonJson['EndTime'];

      var startTimeSplitted = startTimeString.split(':');
      var endTimeSplitted = endTimeString.split(':');

      final startTime = TimeOfDay(
        hour: int.parse(startTimeSplitted[0]),
        minute: int.parse(startTimeSplitted[1]),
      );

      final endTime = TimeOfDay(
        hour: int.parse(endTimeSplitted[0]),
        minute: int.parse(endTimeSplitted[1]),
      );

      lessons.add(LessonTimesBaka(
        startTime: startTime,
        endTime: endTime,
        name: name,
        id: id,
      ));
    }

    return lessons;
  }

  Future<List<BakaHomework>> getHomeworks(
      {void Function(int count)? onNewFound}) async {
    if (!isLoggedIn) {
      try {
        await refreshLogin();
      } on Object {
        rethrow;
      }
    }

    String schoolName = await this.schoolName;
    final url = Uri.https(
      "$schoolName.bakalari.cz",
      "/api/3/homeworks",
      {
        'to': DateFormat('yyyy-MM-dd')
            .format(DateTime.now().add(const Duration(days: 365)))
      },
    );

    Response response;
    try {
      response = await http.get(url, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Bearer $_accessToken",
      });
    } on SocketException {
      throw ServiceException(
          'Check your internet connection. \nCouldn\'t connect to the address: $url.');
    } catch (e) {
      throw ServiceException('An unexpected error occurred: $e');
    }

    final parsedJson = jsonDecode(response.body);

    var homeworksJson = parsedJson['Homeworks'] as List<dynamic>;

    List<BakaHomework> homeworks = [];
    final subjects = container.read(subjectsProvider);

    int newHomeworks = 0;

    for (var homework in homeworksJson) {
      SubjectDTO subject = subjects.entries.where(
        (entry) {
          return entry.value.bakaId == homework['Subject']['Id'];
        },
      ).first.value;

      final String id = homework['ID'];
      final String text = homework['Content'];
      final DateTime deadline = DateTime.parse(homework['DateEnd']);
      final bool isCompleted = homework['Finished'];

      bool isSeen = bakaHomeworkService.isSeen(id);
      if (!isSeen) {
        newHomeworks++;
      }

      homeworks.add(
        BakaHomework(
          bakaId: id,
          alreadyAdded: bakaHomeworkService.isAdded(id),
          alreadySeen: isSeen,
          subject: subject,
          text: text,
          deadline: deadline,
          isCompleted: isCompleted,
          priority: TaskPriority(0),
          dbIndex: 0,
          description: null,
          fireId: null,
          isDeleted: false,
          timestamp: Timestamp.now(),
          order: 0,
        ),
      );
    }

    if (newHomeworks != 0 && onNewFound != null) {
      onNewFound(newHomeworks);
    }

    return homeworks;
  }
}
