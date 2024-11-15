import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:school_manager/data/bakalari/lesson_time_baka.dart';
import 'package:school_manager/data/bakalari/teacher_model.dart';
import 'package:school_manager/data/bakalari/timetable_change.dart';
import 'package:school_manager/data/bakalari/timetable_lesson_model.dart';
import 'package:school_manager/data/safe_box.dart';
import 'package:school_manager/data/subjects_data/subject_model.dart';
import 'package:school_manager/data/table_data/table_dto_model.dart';
import 'package:school_manager/data/table_data/timetable_database.dart';
import 'package:school_manager/extensions/datetime_extension.dart';
import 'package:school_manager/tasks_app.dart';

class BakaResponse {
  final String? error;

  BakaResponse({this.error});

  bool get isSuccess {
    return error == null;
  }
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

  Future<bool> connectedToInternet() async {
    try {
      await http
          .get(Uri(scheme: 'https', host: 'example.com'))
          .timeout(const Duration(seconds: 10))
          .then(
        (value) {
          return false;
        },
      );
    } on Exception catch (_) {
      return false;
    }

    return true;
  }

  /// tries to log in from memory using saved refresh token
  Future<BakaResponse> refreshLogin() async {
    String schoolName = await this.schoolName;
    _refreshToken = await _secureStorage.read(
      SecureStorage.bakaRefreshTokenKey,
    );

    if (schoolName == '' || _refreshToken == '') {
      return BakaResponse(error: 'Please log in');
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

    var bakaResponse = await _callLogin(url, head, body);

    if (bakaResponse.isSuccess) {
      _secureStorage.write(SecureStorage.bakaRefreshTokenKey, _refreshToken!);
    }

    return bakaResponse;
  }

  Future<BakaResponse> firstLogin({
    required String school,
    required String username,
    required String password,
    required bool keepLoggedIn,
  }) async {
    final url = Uri(
      scheme: 'https',
      host: "$school.bakalari.cz",
      path: "/api/login",
    );
    const head = {"Content-Type": "application/x-www-form-urlencoded"};
    final body =
        'client_id=ANDR&grant_type=password&username=$username&password=$password';

    var bakaResponse = await _callLogin(url, head, body);

    if (keepLoggedIn) {
      if (bakaResponse.isSuccess) {
        _secureStorage.write(SecureStorage.bakaRefreshTokenKey, _refreshToken!);
        _secureStorage.write(SecureStorage.bakaSchoolNameKey, school);
        _secureStorage.write(SecureStorage.bakaUsernameKey, username);
      }
    } else {
      // i dont know if it stays empty, im not risking removing it
      _secureStorage.write(SecureStorage.bakaRefreshTokenKey, '');
      _secureStorage.write(SecureStorage.bakaSchoolNameKey, '');
      _secureStorage.write(SecureStorage.bakaUsernameKey, '');
    }

    return bakaResponse;
  }

  /// logs in, returns errors and sets this._refreshToken and this._accessToken
  Future<BakaResponse> _callLogin(Uri url, var head, var body) async {
    var connected = await connectedToInternet();
    if (!connected) {
      return BakaResponse(error: 'Not connected to internet');
    }

    Response response;
    try {
      response = await http
          .post(
            url,
            headers: head,
            body: body,
          )
          .timeout(const Duration(seconds: 10));
    } on SocketException catch (_) {
      return BakaResponse(error: 'Couldn\'t connect to the address: $url');
    } on TimeoutException catch (_) {
      return BakaResponse(error: 'The request timed out after 10 seconds.');
    } catch (e) {
      return BakaResponse(error: 'An unexpected error occurred: $e');
    }

    // when the url or school is incorrect, it needs to be decoded
    if (!response.body.startsWith('{')) {
      List<int> bytes = latin1.encode(response.body);
      return BakaResponse(error: utf8.decode(bytes));
    }

    final parsedJson = json.decode(response.body);
    final accessToken = parsedJson["access_token"];
    final refreshToken = parsedJson["refresh_token"];
    final expiresInSeconds = parsedJson['expires_in'] as int;

    if (accessToken == null || refreshToken == null) {
      return BakaResponse(error: parsedJson['error_description']);
    }

    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _secureStorage.write(SecureStorage.bakaRefreshTokenKey, refreshToken);
    _tokenExpiration =
        DateTime.now().toUtc().add(Duration(seconds: expiresInSeconds));

    return BakaResponse();
  }

  /// returns list of subjects from bakalari
  Future<(BakaResponse, List<Subject>)> _getAllSubjects() async {
    if (!isLoggedIn) {
      final response = await refreshLogin();
      if (!response.isSuccess) {
        return (response, <Subject>[]);
      }
    }

    bool connected = await connectedToInternet();
    if (!connected) {
      return (BakaResponse(error: 'Not connected to internet'), <Subject>[]);
    }

    String schoolName = await this.schoolName;
    final url = Uri(
      scheme: 'https',
      host: "$schoolName.bakalari.cz",
      path: "/api/3/subjects",
    );

    var response = await http.get(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": " Bearer $_accessToken",
      },
    );

    final parsedJson = json.decode(response.body);

    List<dynamic> listOfSubjectsJson = parsedJson['Subjects'];
    List<Subject> listOfSubjects = [];

    for (var subjectJson in listOfSubjectsJson) {
      String name = subjectJson['SubjectName'];
      String shortcut = subjectJson['SubjectAbbrev'];
      String bakaId = subjectJson['SubjectID'];

      // TODO add teachers?
      // checks for duplicates, will add the teachers surname to the subject name
      for (var subject in listOfSubjects) {
        if (subject.name == name && subject.shortcut == shortcut) {
          String teacher = subjectJson['TeacherName'];
          name += ' ${teacher.split(' ')[0]}';
        }
      }

      listOfSubjects.add(Subject(
        name: name,
        shortcut: shortcut,
        bakaId: bakaId,
      ));
    }

    return (BakaResponse(), listOfSubjects);
  }

  Future<void> addAllSubjects() async {
    final result = await _getAllSubjects();
    List<Subject> list = result.$2;
    for (var element in list) {
      subjectService.addNewSubject(element);
    }
    return;
  }

  Future<void> overwriteAllSubjects() async {
    subjectService.deleteAllSubjects();
    final result = await _getAllSubjects();

    List<Subject> list = result.$2;
    for (var element in list) {
      subjectService.addNewSubject(element);
    }

    return;
  }

  // Future<List<String>> importMeals() async {
  //   List<String> meals = [];

  //   final uri = Uri.parse(
  //       'https://www.strava.cz/foxisapi/foxisapi.dll/istravne.istravne.process?xmljidelnickyA&zarizeni=0613');

  //   final response = await http.get(uri);
  //   // final document = xml.XmlDocument.parse(response.body);
  //   // final jidelnicek = document.findElements('pomjidelnic_xmljidelnic');

  //   // print(jidelnicek);
  //   // print(url);
  //   print(response.reasonPhrase);

  //   return meals;
  // }

  Future<BakaResponse> importTimeTable() async {
    if (!isLoggedIn) {
      final response = await refreshLogin();
      if (!response.isSuccess) {
        return response;
      }
    }

    bool connected = await connectedToInternet();
    if (!connected) {
      return BakaResponse(error: 'Not connected to internet');
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
    } on SocketException catch (error) {
      return BakaResponse(error: error.message);
    } on TimeoutException catch (_) {
      return BakaResponse(error: 'The request timed out after 10 seconds.');
    } catch (e) {
      return BakaResponse(error: 'An unexpected error occurred: $e');
    }

    // when the url or school is incorrect, it needs to be decoded
    if (!response.body.startsWith('{')) {
      List<int> bytes = latin1.encode(response.body);
      return BakaResponse(error: utf8.decode(bytes));
    }

    final parsedJson = json.decode(response.body);

    if (parsedJson["Message"] != null) {
      return BakaResponse(error: parsedJson["Message"]);
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

    return BakaResponse();
  }

  /// gets the current timetable for provided date, saturday and sunday are for next week
  Future<(BakaResponse, TimeTableDTO?)> getCurrentTimetable(
      DateTime date) async {
    if (!isLoggedIn) {
      final response = await refreshLogin();
      if (!response.isSuccess) {
        return (response, null);
      }
    }

    bool connected = await connectedToInternet();
    if (!connected) {
      return (BakaResponse(error: 'Not connected to internet'), null);
    }

    DateTime mondayDate = date.toUtc();
    int weekday = date.toUtc().weekday;

    String schoolName = await this.schoolName;
    final url = Uri(
      scheme: 'https',
      host: "$schoolName.bakalari.cz",
      path: "/api/3/timetable/actual",
      queryParameters: {
        'date': DateFormat('yyyy-MM-dd').format(mondayDate.toLocal())
      },
    );

    if (weekday == 6) {
      mondayDate = mondayDate.add(const Duration(days: 2));
    } else if (weekday == 7) {
      mondayDate = mondayDate.add(const Duration(days: 1));
    } else {
      mondayDate = mondayDate.add(Duration(days: 1 - weekday));
    }

    Response response;
    try {
      response = await http.get(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": "Bearer $_accessToken",
        },
      ).timeout(const Duration(seconds: 10));
    } on SocketException catch (error) {
      return (BakaResponse(error: error.message), null);
    } on TimeoutException catch (_) {
      return (
        BakaResponse(error: 'The request timed out after 10 seconds.'),
        null
      );
    } catch (e) {
      return (BakaResponse(error: 'An unexpected error occurred: $e'), null);
    }

    // when the url or school is incorrect, it needs to be decoded
    if (!response.body.startsWith('{')) {
      List<int> bytes = latin1.encode(response.body);
      return (BakaResponse(error: utf8.decode(bytes)), null);
    }

    final parsedJson = json.decode(response.body);

    if (parsedJson["Message"] != null) {
      return (BakaResponse(error: parsedJson["Message"]), null);
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
    final subjects = subjectService.getMap();

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

    return (BakaResponse(), timeTable);
  }

  /// for each id from baka, you have index of app's subjects, if the subject doesnt exist, it is created
  Future<Map<String, int>> _getSubjectsIdToIndex(
      List<dynamic> subjectsJson) async {
    final subjects = subjectService.getSortedList();
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
        var newSubject = await subjectService.addNewSubject(Subject(
          name: name,
          shortcut: shortcut,
          bakaId: bakaId,
        ));
        bakalariSubjectIdToSubjectIndex.addAll({bakaId: newSubject.dbIndex});
      }
    }

    return bakalariSubjectIdToSubjectIndex;
  }

  // Map<String, int> _getSubjectsIdToIndex(List<dynamic> subjectsJson) {
  //   final subjects = subjectService.getSortedList();
  //   // for each id from baka, you have index of app's subjects
  //   Map<String, int> bakalariSubjectIdToSubjectIndex = {};

  //   for (var subjectJson in subjectsJson) {
  //     String bakaId = subjectJson['Id'];
  //     String shortcut = subjectJson['Abbrev'];
  //     String name = subjectJson['Name'];

  //     for (var subject in subjects) {
  //       if (subject.containsText(name) && subject.containsText(shortcut)) {
  //         bakalariSubjectIdToSubjectIndex.addAll({bakaId: subject.dbIndex});
  //         break;
  //       }
  //     }
  //   }
  //
  //   return bakalariSubjectIdToSubjectIndex;
  // }

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
}
