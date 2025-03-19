import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/models/meal_model.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/provider/hw_notifier.dart';
import 'package:school_manager/services/firestore/firebase_options.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';
import 'package:workmanager/workmanager.dart';

void updateHwWidget(List<HomeworkDTO> hws) {
  // final hws = ref.read(hwUncompletedProvider);
  List<dynamic> json = [];

  for (var element in hws) {
    json.add(element.toWidgetJson());
  }

  HomeWidget.saveWidgetData('hw', jsonEncode(json));
  HomeWidget.updateWidget(name: 'HwWidgetReceiver');
}

void updateStravaWidget(Map<DateTime, List<Meal>> meals) {
  Map<String, dynamic> json = {};
  final now = DateTime.now();

  meals.forEach(
    (key, value) {
      // if it is after meal time, dont include meal for today
      if (!key.isSameDay(now) ||
          TimeOfDay.fromDateTime(now)
              .isBefore(settings.getTimeOfDay(Setting.mealsShowTodayUntil))) {
        json[key.dayText()] = value
            .map(
              (e) => e.toJson(),
            )
            .toList();
      }
    },
  );
  HomeWidget.saveWidgetData<String>('meals', jsonEncode(json));
  HomeWidget.updateWidget(name: 'StravaWidgetReceiver');
}

@pragma("vm:entry-point")
FutureOr<void> backgroundCallback(Uri? data) async {
  if (data == null) return;

  Workmanager().registerOneOffTask(
    'widget',
    'widget',
    inputData: {'data': data.toString()},
  );
}

@pragma('vm:entry-point')
void myCallbackDispatcher() {
  Workmanager().executeTask(
    (taskName, inputData) async {
      if (taskName == 'widget') {
        await _complete(Uri.parse(inputData?['data']));
      }
      return Future.value(true);
    },
  );
}

Future<void> _complete(
  Uri data,
) async {
  if (data.host == 'complete') {
    int? dbIndex = int.tryParse(data.queryParameters['db'] ?? '');
    bool? isCompleted = bool.tryParse(data.queryParameters['complete'] ?? '');

    if (dbIndex != null && isCompleted != null) {
      final container = ProviderContainer();

      await Hive.initFlutter();
      Hive.registerAdapter(HomeworkAdapter());
      Hive.registerAdapter(ExamAdapter());
      Hive.registerAdapter(SubjectAdapter());
      await Future.wait([
        Hive.openBox('subjectBox'),
        Hive.openBox('hwBox'),
        Hive.openBox('examBox'),
      ]);

      // WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      await container
          .read(hwProvider.notifier)
          .completeIndex(dbIndex, isCompleted);

      updateHwWidget(container.read(hwWidgetProvider));

      await Hive.box('hwBox').flush();
      await Hive.box('hwBox').close();
      print('background work done');
      return;
    }
  }
}
