import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/l10n/my_localization.dart';
import 'package:school_manager/models/bakalari/baka_hw_model.dart';
import 'package:school_manager/models/bakalari/lesson_time_baka.dart';
import 'package:school_manager/models/bakalari/teacher_model.dart';
import 'package:school_manager/models/bakalari/timetable_change.dart';
import 'package:school_manager/models/bakalari/timetable_lesson_model.dart';
import 'package:school_manager/models/exception_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/models/timetable/timetable_model.dart';
import 'package:school_manager/provider/subject_notifier.dart';
import 'package:school_manager/services/secure_storage.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';

final bakaProvider =
    AsyncNotifierProvider<BakaNotifier, bool>(BakaNotifier.new);

class BakaNotifier extends AsyncNotifier<bool> {
  final _secureStorage = SecureStorage();
  String? _accessToken;
  String? _refreshToken;

  DateTime? _tokenExpiration;
  Timer? _tokenExpirationTimer;

  @override
  Future<bool> build() async {
    return refreshLogin();
  }

  bool get isLoggedIn {
    if (_tokenExpiration == null) {
      return false;
    }
    if (_accessToken == null) {
      return false;
    }
    return DateTime.now().isBefore(_tokenExpiration!);
  }

  void _tokenExpirationTime(int seconds) {
    _tokenExpirationTimer?.cancel();
    _tokenExpirationTimer = Timer(
      Duration(seconds: seconds),
      () {
        state = const AsyncData(false);
      },
    );
  }

  Future<String> get username async {
    return _secureStorage.read(SecureStorage.bakaUsernameKey);
  }

  Future<String> get schoolName async {
    return _secureStorage.read(SecureStorage.bakaSchoolNameKey);
  }

  Future<String> get _storageRefreshToken async {
    return _secureStorage.read(SecureStorage.bakaRefreshTokenKey);
  }

  Future<void> saveToSecureStorage(String key, String value) async {
    _secureStorage.write(key, value);
  }

  /// tries to log in from memory using saved refresh token
  /// returns if the login was sucessful
  Future<bool> refreshLogin() async {
    state = const AsyncLoading();
    try {
      String schoolName = '';
      try {
        schoolName = await this.schoolName;
        _refreshToken = await _storageRefreshToken;
      } on Exception {
        throw BakaLoginException();
      }

      if (schoolName == '' || _refreshToken == '') {
        throw BakaLoginException();
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

      await _callLogin(url, head, body);

      loadName();
      return true;
    } catch (e, s) {
      state = AsyncError(e, s);
      return false;
    }
  }

  Future<void> firstLogin({
    required String school,
    required String username,
    required String password,
    required bool keepLoggedIn,
  }) async {
    state = const AsyncLoading();
    try {
      if (school == '' || username == '' || password == '') {
        throw ServiceException(getLocalization().fillOutAllInfo);
      }

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
        saveToSecureStorage(SecureStorage.bakaRefreshTokenKey, _refreshToken!);
        saveToSecureStorage(SecureStorage.bakaSchoolNameKey, school);
        saveToSecureStorage(SecureStorage.bakaUsernameKey, username);
      } else {
        // it has to be overwriten if the user chooses
        logOut();
      }
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  Future<void> logOut() async {
    state = const AsyncData(false);
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiration = null;

    Future.wait([
      saveToSecureStorage(SecureStorage.bakaRefreshTokenKey, ''),
      saveToSecureStorage(SecureStorage.bakaSchoolNameKey, ''),
      saveToSecureStorage(SecureStorage.bakaUsernameKey, ''),
    ]);
  }

  /// logs in, returns errors and sets this._refreshToken, this._accessToken
  /// and the state if it logs in succesfuly
  Future<void> _callLogin(Uri url, var head, var body) async {
    Response response;
    final loc = getLocalization();
    try {
      response = await http.post(
        url,
        headers: head,
        body: body,
      );
    } on SocketException catch (_) {
      throw ServiceException(loc.checkConnection);
    } catch (e) {
      throw ServiceException('${loc.unexpectedError}: $e');
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
    await saveToSecureStorage(SecureStorage.bakaRefreshTokenKey, refreshToken);
    _tokenExpirationTime(expiresInSeconds);
    _tokenExpiration =
        DateTime.now().toUtc().add(Duration(seconds: expiresInSeconds));
    state = const AsyncData(true);
  }

  Future<void> loadName() async {
    if (settings.get(Setting.userName) != null || !isLoggedIn) {
      return;
    }

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

  /// imports permanent timetable and saves it
  Future<void> importTimeTable() async {
    if (!isLoggedIn) {
      try {
        await refreshLogin().then(
          (value) {
            if (!value) {
              throw BakaLoginException();
            }
          },
        );
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
    final loc = getLocalization();
    try {
      response = await http.get(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": " Bearer $_accessToken",
        },
      );
    } on SocketException {
      throw ServiceException(loc.checkConnection);
    } catch (e) {
      throw ServiceException('${loc.unexpectedError}: $e');
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
    timetableDb.createTable(lessons.map(
      (lessonTimes) {
        return lessonTimes.toLessonTimes();
      },
    ).toList());

    var subjectsJson = parsedJson['Subjects'] as List<dynamic>;
    final bakaIdToSubjectIndex =
        await _bakaSubjectIdToSubject(subjectsJson, createIfMissing: true);

    var daysJson = parsedJson['Days'] as List<dynamic>;
    for (int weekday = 0; weekday < daysJson.length; weekday++) {
      final dayJson = daysJson[weekday];
      for (int lessonIndex = 0;
          lessonIndex < dayJson['Atoms'].length;
          lessonIndex++) {
        var subjectJson = dayJson['Atoms'][lessonIndex];

        String subjectIdBaka = subjectJson['SubjectId'];
        String subjectId = bakaIdToSubjectIndex[subjectIdBaka]!.id;
        int hourId = subjectJson['HourId'];

        timetableDb.newLessonAt(
          weekday,
          lessons.indexWhere(
            (lesson) => lesson.id == hourId,
          ),
          subjectId,
        );
      }
    }
  }

  /// gets the current timetable for provided date, saturday and sunday are for next week
  Future<TimeTable> getCurrentTimetable(DateTime date) async {
    if (!isLoggedIn) {
      try {
        await refreshLogin().then(
          (value) {
            if (!value) {
              throw BakaLoginException();
            }
          },
        );
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
    final loc = getLocalization();
    try {
      response = await http.get(url, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Bearer $_accessToken",
      });
    } on SocketException {
      throw ServiceException(loc.checkConnection);
    } catch (e) {
      throw ServiceException('${loc.unexpectedError}: $e');
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
    TimeTable timeTable = TimeTable.withoutTable(
        lessonTimes: lessons.map(
      (lessonTime) {
        return lessonTime.toLessonTimes();
      },
    ).toList());
    timeTable.dates = mondayDate.allDaysInThisWeek();

    var subjectsJson = parsedJson['Subjects'] as List<dynamic>;
    final bakaIdToSubjectIndex = await _bakaSubjectIdToSubject(
      subjectsJson,
      createIfMissing: false,
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
      for (int lessonIndex = 0;
          lessonIndex < dayJson['Atoms'].length;
          lessonIndex++) {
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

  /// to each bakalari subjects ID maps a local subject, based on saved bakaId
  ///
  /// if such subject doesnt exist yet, it is created
  /// and if [createIfMissing] is true, it is also permanently saved
  Future<Map<String, Subject>> _bakaSubjectIdToSubject(
    List<dynamic> subjectsJson, {
    required bool createIfMissing,
  }) async {
    // bakaId to subject
    final db = subjectsDb.getDatabase();
    db.removeWhere((key, value) => value.isDeleted);

    final subjects = db.map(
      (key, value) => MapEntry(value.bakaId, value),
    );
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
        newSubject = await ref
            .read(subjectsProvider.notifier)
            .saveNew(newSubject.convert());
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
        await refreshLogin().then(
          (value) {
            if (!value) {
              throw BakaLoginException();
            }
          },
        );
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
    final loc = getLocalization();
    try {
      response = await http.get(url, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Bearer $_accessToken",
      });
    } on SocketException {
      throw ServiceException(loc.checkConnection);
    } catch (e) {
      throw ServiceException('${loc.unexpectedError}: $e');
    }

    final parsedJson = jsonDecode(response.body);

    var homeworksJson = parsedJson['Homeworks'] as List<dynamic>;

    List<BakaHomework> homeworks = [];
    final subjects = subjectsDb.getDatabase();

    int newHomeworks = 0;

    for (var homework in homeworksJson) {
      Subject? subject = subjects.entries
          .where(
            (entry) {
              return entry.value.bakaId == homework['Subject']['Id'];
            },
          )
          .firstOrNull
          ?.value;

      final String id = homework['ID'];
      final String text = homework['Content'];
      final DateTime deadline = DateTime.parse(homework['DateEnd']).toLocal();
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
          description: null,
          id: id,
          isDeleted: false,
          timestamp: DateTime.now().toUtc(),
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
