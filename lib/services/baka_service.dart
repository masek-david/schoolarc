import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:schoolarc/database/secure_storage.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/mock_data/mock_data.dart';
import 'package:schoolarc/models/bakalari/baka_hw_model.dart';
import 'package:schoolarc/models/bakalari/lesson_time_baka.dart';
import 'package:schoolarc/models/bakalari/teacher_model.dart';
import 'package:schoolarc/models/bakalari/timetable_change.dart';
import 'package:schoolarc/models/bakalari/timetable_lesson_model.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exception_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/models/timetable/timetable_model.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/utils/globals.dart';

class BakaService {
  String? _accessToken;
  String? _refreshToken;

  DateTime? tokenExpiration;

  bool get isLoggedIn {
    if (tokenExpiration == null) {
      return false;
    }
    if (_accessToken == null) {
      return false;
    }
    return DateTime.now().isBefore(tokenExpiration!);
  }

  Future<String> get username async {
    return SecureStorage.read(SecureStorage.bakaUsernameKey);
  }

  Future<String> get schoolName async {
    return SecureStorage.read(SecureStorage.bakaSchoolNameKey);
  }

  Future<String> get _storageRefreshToken async {
    return SecureStorage.read(SecureStorage.bakaRefreshTokenKey);
  }

  /// tries to log in from memory using saved refresh token
  Future<bool> refreshLogin() async {
    String schoolName = '';
    schoolName = await this.schoolName;
    _refreshToken = await _storageRefreshToken;

    if (schoolName == '' || _refreshToken == '') {
      throw AuthException(.loggedOut, exceptionAction: .bakaLogin);
    }

    final url = Uri(
      scheme: 'https',
      host: "$schoolName.bakalari.cz",
      path: "/api/login",
    );
    const head = {"Content-Type": "application/x-www-form-urlencoded"};
    final body =
        'client_id=ANDR&grant_type=refresh_token&refresh_token=$_refreshToken';

    await _callLogin(url, head, body);
    return true;
  }

  Future<void> firstLogin({
    required String school,
    required String username,
    required String password,
    required bool keepLoggedIn,
  }) async {
    if (school == '' || username == '' || password == '') {
      throw ValidationException(.emptyField);
    }

    school = school.trim();

    final url = Uri(
      scheme: 'https',
      host: "$school.bakalari.cz",
      path: "/api/login",
    );
    const head = {"Content-Type": "application/x-www-form-urlencoded"};
    final body =
        'client_id=ANDR&grant_type=password&username=$username&password=$password';

    await _callLogin(url, head, body);

    if (keepLoggedIn) {
      await SecureStorage.write(
        SecureStorage.bakaRefreshTokenKey,
        _refreshToken!,
      );
      await SecureStorage.write(SecureStorage.bakaSchoolNameKey, school);
      await SecureStorage.write(SecureStorage.bakaUsernameKey, username);
    } else {
      // it has to be overwriten if the user chooses
      logOut();
    }
  }

  Future<void> logOut() async {
    _accessToken = null;
    _refreshToken = null;
    tokenExpiration = null;

    await SecureStorage.delete(SecureStorage.bakaRefreshTokenKey);
    await SecureStorage.delete(SecureStorage.bakaSchoolNameKey);
    await SecureStorage.delete(SecureStorage.bakaUsernameKey);
  }

  /// logs in, returns errors and sets this._refreshToken, this._accessToken
  /// and the state if it logs in succesfuly
  Future<void> _callLogin(Uri url, var head, var body) async {
    Response response;
    try {
      response = await http
          .post(url, headers: head, body: body)
          .timeout(timeoutDuration);
    } on SocketException catch (_) {
      throw NetworkException(.offline);
    } on TimeoutException catch (_) {
      throw NetworkException(.timeout);
    } catch (e) {
      throw NetworkException(.serverError, originalError: e);
    }

    // when the url or school is incorrect, it needs to be decoded
    if (!response.body.startsWith('{')) {
      List<int> bytes = latin1.encode(response.body);
      throw ApiException(utf8.decode(bytes));
    }

    final parsedJson = json.decode(response.body);

    final accessToken = parsedJson["access_token"];
    final refreshToken = parsedJson["refresh_token"];
    final expiresInSeconds = parsedJson['expires_in'] as int;

    if (accessToken == null || refreshToken == null) {
      throw ApiException(parsedJson['error_description']);
    }

    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await SecureStorage.write(SecureStorage.bakaRefreshTokenKey, refreshToken);
    tokenExpiration = DateTime.now().toUtc().add(
      Duration(seconds: expiresInSeconds),
    );
  }

  Future<String> getUsername() async {
    Response response;
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

    final json = jsonDecode(response.body);
    String fullName = json['FullName'];

    return fullName.replaceAll(',', '').split(' ')[1];
  }

  /// imports permanent timetable and saves it
  Future<void> importTimeTable(WidgetRef ref) async {
    if (!isLoggedIn) {
      await refreshLogin();
    }

    String schoolName = await this.schoolName;
    final url = Uri(
      scheme: 'https',
      host: "$schoolName.bakalari.cz",
      path: "/api/3/timetable/permanent",
    );

    Response response;
    try {
      response = await http
          .get(
            url,
            headers: {
              "Content-Type": "application/x-www-form-urlencoded",
              "Authorization": " Bearer $_accessToken",
            },
          )
          .timeout(timeoutDuration);
    } on SocketException catch (_) {
      throw NetworkException(.offline);
    } on TimeoutException catch (_) {
      throw NetworkException(.timeout);
    } catch (e) {
      throw NetworkException(.serverError, originalError: e);
    }

    // when the url or school is incorrect, it needs to be decoded
    if (!response.body.startsWith('{')) {
      List<int> bytes = latin1.encode(response.body);
      throw ApiException(utf8.decode(bytes));
    }

    final parsedJson = json.decode(response.body);
    if (parsedJson["Message"] != null) {
      throw ApiException(parsedJson["Message"]);
    }

    var lessonsJson = parsedJson['Hours'] as List<dynamic>;
    final lessons = _getLessons(lessonsJson);
    timetableDb.createTable(
      lessons.map((lessonTimes) {
        return lessonTimes.toLessonTimes();
      }).toList(),
    );

    var subjectsJson = parsedJson['Subjects'] as List<dynamic>;
    final bakaIdToSubjectIndex = await _bakaSubjectIdToSubject(
      subjectsJson,
      createIfMissing: true,
      ref: ref,
    );

    var daysJson = parsedJson['Days'] as List<dynamic>;
    for (int weekday = 0; weekday < daysJson.length; weekday++) {
      final dayJson = daysJson[weekday];
      for (
        int lessonIndex = 0;
        lessonIndex < dayJson['Atoms'].length;
        lessonIndex++
      ) {
        var subjectJson = dayJson['Atoms'][lessonIndex];

        String subjectIdBaka = subjectJson['SubjectId'];
        String subjectId = bakaIdToSubjectIndex[subjectIdBaka]!.id;
        int hourId = subjectJson['HourId'];

        timetableDb.newLessonAt(
          weekday,
          lessons.indexWhere((lesson) => lesson.id == hourId),
          subjectId,
        );
      }
    }
  }

  /// gets the current timetable for provided date, saturday and sunday are for next week
  Future<TimeTable> getCurrentTimetable(Date date) async {
    if (!isLoggedIn) {
      await refreshLogin();
    }

    if(MockData.useMock){
      return MockData.currentTimetable;
    }

    Date mondayDate;
    final weekday = date.weekday;

    if (weekday == 6) {
      mondayDate = date.addDays(2);
    } else if (weekday == 7) {
      mondayDate = date.addDays(1);
    } else {
      mondayDate = date.addDays(1 - weekday);
    }

    final schoolName = await this.schoolName;
    final url = Uri(
      scheme: 'https',
      host: "$schoolName.bakalari.cz",
      path: "/api/3/timetable/actual",
      queryParameters: {
        'date': DateFormat('yyyy-MM-dd').format(mondayDate.toDateTimeLocal()),
      },
    );

    Response response;
    try {
      response = await http
          .get(
            url,
            headers: {
              "Content-Type": "application/x-www-form-urlencoded",
              "Authorization": "Bearer $_accessToken",
            },
          )
          .timeout(timeoutDuration);
    } on SocketException catch (_) {
      throw NetworkException(.offline);
    } on TimeoutException catch (_) {
      throw NetworkException(.timeout);
    } catch (e) {
      throw NetworkException(.serverError, originalError: e);
    }

    // when the url or school is incorrect, it needs to be decoded
    if (!response.body.startsWith('{')) {
      List<int> bytes = latin1.encode(response.body);
      throw ApiException(utf8.decode(bytes));
    }

    final parsedJson = json.decode(response.body);

    if (parsedJson["Message"] != null) {
      throw ApiException(parsedJson["Message"]);
    }

    var lessonsJson = parsedJson['Hours'] as List<dynamic>;
    final lessons = _getLessons(lessonsJson);
    TimeTable timeTable = TimeTable.withoutTable(
      lessonTimes: lessons.map((lessonTime) {
        return lessonTime.toLessonTimes();
      }).toList(),
    );
    timeTable.dates = mondayDate.allDaysInThisWeek(
      settings.get(Setting.weekStartsOnMonday),
    );

    var subjectsJson = parsedJson['Subjects'] as List<dynamic>;
    final bakaIdToSubjectIndex = await _bakaSubjectIdToSubject(
      subjectsJson,
      createIfMissing: false,
      ref: null,
    );

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
      for (
        int lessonIndex = 0;
        lessonIndex < dayJson['Atoms'].length;
        lessonIndex++
      ) {
        var subjectJson = dayJson['Atoms'][lessonIndex];

        String? subjectIdBaka = subjectJson['SubjectId'];
        String? teacherId = subjectJson['TeacherId'];
        String? roomId = subjectJson['RoomId'];
        final subject = bakaIdToSubjectIndex[subjectIdBaka];
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

  /// To each bakalari subject ID maps a local subject, based on the saved bakaId
  ///
  /// If such subject doesnt exist yet, it is created
  /// and if [createIfMissing] is true, it is also  saved
  ///
  /// If [createIfMissing] is true, [ref] can't be null
  Future<Map<String, Subject>> _bakaSubjectIdToSubject(
    List<dynamic> subjectsJson, {
    required bool createIfMissing,
    required WidgetRef? ref,
  }) async {
    assert(
      !(createIfMissing && ref == null),
      'If createIfMissing is true, ref can\'t be null',
    );

    final db = subjectsDb.readDatabase();
    db.removeWhere((key, value) => value.isDeleted);

    final subjects = db.map((key, value) => MapEntry(value.bakaId, value));
    Map<String, Subject> bakaSubjectIdToSubject = {};

    for (var subjectJson in subjectsJson) {
      String bakaId = subjectJson['Id'];
      String shortcut = subjectJson['Abbrev'];
      String name = subjectJson['Name'];

      if (subjects.containsKey(bakaId)) {
        // the subject exists locally
        bakaSubjectIdToSubject.addAll({bakaId: subjects[bakaId]!});
        continue;
      }

      // the subject doesnt exist, create with empty id
      var newSubject = Subject(
        id: '',
        name: name,
        shortcut: shortcut,
        bakaId: bakaId,
        isDeleted: false,
        order: 0,
        timestamp: DateTime.now().toUtc(),
      );
      if (createIfMissing) {
        newSubject = await ref!
            .read(subjectsProvider.notifier)
            .create(newSubject.convert());
      }
      bakaSubjectIdToSubject.addAll({bakaId: newSubject});
    }

    return bakaSubjectIdToSubject;
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

      lessons.add(
        LessonTimesBaka(
          startTime: startTime,
          endTime: endTime,
          name: name,
          id: id,
        ),
      );
    }

    return lessons;
  }

  Future<List<BakaHomework>> getHomeworks() async {
    if (!isLoggedIn) {
      await refreshLogin();
    }

    String schoolName = await this.schoolName;
    final url = Uri.https("$schoolName.bakalari.cz", "/api/3/homeworks", {
      'to': DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.now().add(const Duration(days: 365))),
    });

    Response response;
    try {
      response = await http
          .get(
            url,
            headers: {
              "Content-Type": "application/x-www-form-urlencoded",
              "Authorization": "Bearer $_accessToken",
            },
          )
          .timeout(timeoutDuration);
    } on SocketException catch (_) {
      throw NetworkException(.offline);
    } on TimeoutException catch (_) {
      throw NetworkException(.timeout);
    } catch (e) {
      throw NetworkException(.serverError, originalError: e);
    }

    final parsedJson = jsonDecode(response.body);

    var homeworksJson = parsedJson['Homeworks'] as List<dynamic>;

    List<BakaHomework> homeworks = [];
    final subjects = subjectsDb.readDatabase();
    subjects.removeWhere((key, value) => value.isDeleted);

    for (var homework in homeworksJson) {
      final String bakaId = homework['ID'];
      final String subjectBakaId = homework['Subject']['Id'];
      final String text = homework['Content'];
      final DateTime date = DateTime.parse(homework['DateEnd']).toLocal();
      final bool isCompleted = homework['Finished'];

      Subject? subject = subjects.entries
          .where((entry) => entry.value.bakaId == subjectBakaId)
          .firstOrNull
          ?.value;

      subject ??= Subject(
        name: homework['Subject']['Name'],
        shortcut: homework['Subject']['Abbrev'],
        id: '',
        bakaId: subjectBakaId,
        timestamp: DateTime.now(),
        isDeleted: false,
        order: 0,
      );

      bool isSeen = bakaHwDb.isSeen(bakaId);

      homeworks.add(
        BakaHomework(
          bakaId: bakaId,
          alreadyAdded: bakaHwDb.isAdded(bakaId),
          alreadySeen: isSeen,
          subject: subject,
          text: text,
          date: Date.fromDateTime(date.toLocal()),
          isCompleted: isCompleted,
          priority: const TaskPriority(0),
          description: '',
          id: bakaId,
          isDeleted: false,
          timestamp: DateTime.now().toUtc(),
          order: 0,
        ),
      );
    }

    return homeworks;
  }
}
