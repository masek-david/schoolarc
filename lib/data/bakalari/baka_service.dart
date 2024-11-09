import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:school_manager/data/bakalari/lesson_time_baka.dart';
import 'package:school_manager/data/safe_box.dart';
import 'package:school_manager/data/subjects_data/subject_model.dart';
import 'package:school_manager/data/subjects_data/subject_service.dart';
import 'package:school_manager/data/table_data/timetable_database.dart';

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
  Uri? _url;

  final _subjectService = SubjectService();
  final _timetableDb = TimeTableDatabase();
  final _secureStorage = SecureStorage();

  Future<String?> get username async {
    return _secureStorage.read(SecureStorage.bakaUsernameKey);
  }

  Future<String?> get schoolName async {
    return _secureStorage.read(SecureStorage.bakaSchoolNameKey);
  }

  Future<bool> connectedToInternet() async {
    try {
      await http.get(Uri(scheme: 'https', host: 'example.com'));
    } on SocketException catch (_) {
      return false;
    }

    return true;
  }

  /// tries to log in from memory using saved refresh token
  Future<BakaResponse> tryLogin() async {
    String schoolName = await _secureStorage.read(
      SecureStorage.bakaSchoolNameKey,
    );
    _refreshToken = await _secureStorage.read(
      SecureStorage.bakaRefreshTokenKey,
    );

    if (schoolName == '' || _refreshToken == '') {
      return BakaResponse(error: 'Please log in');
    }

    _url = Uri(
      scheme: 'https',
      host: "$schoolName.bakalari.cz",
      path: "/api/login",
    );
    const head = {"Content-Type": "application/x-www-form-urlencoded"};
    final body =
        'client_id=ANDR&grant_type=refresh_token&refresh_token=$_refreshToken';

    var bakaResponse = await callLogin(_url!, head, body);

    if (bakaResponse.isSuccess) {
      _secureStorage.write(SecureStorage.bakaRefreshTokenKey, _refreshToken!);
    }

    return bakaResponse;
  }

  Future<BakaResponse> login({
    required String school,
    required String username,
    required String password,
    required bool keepLoggedIn,
  }) async {
    _url =
        Uri(scheme: 'https', host: "$school.bakalari.cz", path: "/api/login");
    const head = {"Content-Type": "application/x-www-form-urlencoded"};
    final body =
        'client_id=ANDR&grant_type=password&username=$username&password=$password';

    var bakaResponse = await callLogin(_url!, head, body);

    if (keepLoggedIn) {
      if (bakaResponse.isSuccess) {
        _secureStorage.write(SecureStorage.bakaRefreshTokenKey, _refreshToken!);
        _secureStorage.write(SecureStorage.bakaSchoolNameKey, school);
        _secureStorage.write(SecureStorage.bakaUsernameKey, username);
      }
    } else {
      _secureStorage.write(SecureStorage.bakaRefreshTokenKey, '');
      _secureStorage.write(SecureStorage.bakaSchoolNameKey, '');
      _secureStorage.write(SecureStorage.bakaUsernameKey, '');
    }

    return bakaResponse;
  }

  /// logs in, returns errors and sets this._refreshToken and this._accessToken
  Future<BakaResponse> callLogin(Uri url, var head, var body) async {
    var connected = await connectedToInternet();
    if (!connected) {
      return BakaResponse(error: 'Not connected to internet');
    }

    Response response;
    try {
      response = await http.post(
        url,
        headers: head,
        body: body,
      );
    } on SocketException catch (_) {
      return BakaResponse(error: 'No valid school address');
    }

    // when the url or school is incorrect, it needs to be decoded
    if (!response.body.startsWith('{')) {
      List<int> bytes = latin1.encode(response.body);
      return BakaResponse(error: utf8.decode(bytes));
    }

    final parsedJson = json.decode(response.body);
    _accessToken = parsedJson["access_token"];
    _refreshToken = parsedJson["refresh_token"];

    if (_accessToken == null || _refreshToken == null) {
      return BakaResponse(error: parsedJson['error_description']);
    }

    return BakaResponse();
  }

  /// returns list of subjects from bakalari
  Future<List<Subject>> _getAllSubjects() async {
    bool connected = await connectedToInternet();
    if (!connected) {
      throw 'no connection';
    }

    if (_url == null) {
      throw 'no url';
    }
    if (_accessToken == null) {
      throw 'no access token';
    }
    var response = await http.get(
      _url!.replace(path: "/api/3/subjects"),
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

      // checks for duplicates, will add the teachers surname to the subject name
      for (var subject in listOfSubjects) {
        if (subject.name == name && subject.shortcut == shortcut) {
          String teacher = subjectJson['TeacherName'];
          name += ' ${teacher.split(' ')[0]}';
        }
      }

      listOfSubjects.add(Subject(name: name, shortcut: shortcut));
    }

    return listOfSubjects;
  }

  Future<void> addAllSubjects() async {
    List<Subject> list = await _getAllSubjects();
    for (var element in list) {
      _subjectService.addNewSubject(element);
    }
    return;
  }

  Future<void> overwriteAllSubjects() async {
    _subjectService.deleteAllSubjects();

    List<Subject> list = await _getAllSubjects();
    for (var element in list) {
      _subjectService.addNewSubject(element);
    }

    return;
  }

  Future<BakaResponse> importTimeTable() async {
    if (_url == null) {
      return BakaResponse(error: 'No url, try to log in first');
    }
    if (_accessToken == null) {
      return BakaResponse(error: 'No token, try to log in first');
    }

    bool connected = await connectedToInternet();
    if (!connected) {
      return BakaResponse(error: 'Not connected to internet');
    }

    Response response;
    try {
      response = await http.get(
        _url!.replace(path: "/api/3/timetable/permanent"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": " Bearer $_accessToken",
        },
      );
    } on SocketException catch (error) {
      return BakaResponse(error: error.message);
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
      (e) {
        return e.toLessonTimes();
      },
    ).toList());

    var subjectsJson = parsedJson['Subjects'] as List<dynamic>;
    final bakaIdToSubjectIndex = _getSubjectsIdToIndex(subjectsJson);

    var daysJson = parsedJson['Days'] as List<dynamic>;
    for (int weekday = 0; weekday < daysJson.length; weekday++) {
      final dayJson = daysJson[weekday];
      for (int lessonIndex = 0;
          lessonIndex < dayJson['Atoms'].length;
          lessonIndex++) {
        var subjectJson = dayJson['Atoms'][lessonIndex];

        String subjectIdBaka = subjectJson['SubjectId'];
        int? subjectIndex = bakaIdToSubjectIndex[subjectIdBaka];
        int hourId = subjectJson['HourId'];

        if (subjectIndex != null) {
          _timetableDb.newLessonAt(
              weekday,
              lessons.indexWhere(
                (lesson) => lesson.id == hourId,
              ),
              subjectIndex);
        }
      }
    }

    return BakaResponse();
  }

  Map<String, int> _getSubjectsIdToIndex(List<dynamic> subjectsJson) {
    final subjects = _subjectService.getSortedList();
    // for each id from baka, you have index of app's subjects
    Map<String, int> bakalariSubjectIdToSubjectIndex = {};

    for (var subjectJson in subjectsJson) {
      String bakaId = subjectJson['Id'];
      String shortcut = subjectJson['Abbrev'];
      String name = subjectJson['Name'];

      for (var subject in subjects) {
        if (subject.containsText(name) && subject.containsText(shortcut)) {
          bakalariSubjectIdToSubjectIndex.addAll({bakaId: subject.dbIndex});
          break;
        }
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
}
