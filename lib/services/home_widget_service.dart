import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'package:schoolarc/database/hive/hive_init.dart';
import 'package:schoolarc/database/hive/hive_registrar.g.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/models/meal_model.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/services/firebase/firebase_options.dart';
import 'package:schoolarc/utils/extensions/datetime_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:workmanager/workmanager.dart';

void updateHwWidget(List<Homework> hws) {
  if (kIsWeb || !Platform.isAndroid) return;

  List<dynamic> json = [];

  for (var element in hws) {
    json.add(element.toWidgetJson());
  }

  HomeWidget.saveWidgetData('hw', jsonEncode(json));
  HomeWidget.updateWidget(
    androidName: 'HwWidgetReceiver',
    qualifiedAndroidName: 'cz.masci.schoolarc.HwWidgetReceiver',
  );
}

void updateStravaWidget(Map<DateTime, List<Meal>> meals) {
  if (kIsWeb || !Platform.isAndroid) return;
  Map<String, dynamic> json = {};
  final now = DateTime.now();

  meals.forEach(
    (key, value) {
      // if it is after meal time, dont include meal for today
      if (!key.isSameDay(now) ||
          TimeOfDay.fromDateTime(now)
              .isBefore(settings.get(Setting.mealsShowTodayUntil))) {
        json[key.dayOfWeekText()] = value
            .map(
              (e) => e.toJson(),
            )
            .toList();
      }
    },
  );
  HomeWidget.saveWidgetData<String>('meals', jsonEncode(json));
  HomeWidget.updateWidget(
    androidName: 'StravaWidgetReceiver',
    qualifiedAndroidName: 'cz.masci.schoolarc.StravaWidgetReceiver',
  );
}

/// called from widget, when completing homework
@pragma("vm:entry-point")
FutureOr<void> backgroundCallback(Uri? data) async {
  if (data == null) return;

  Workmanager().registerOneOffTask(
    'widget',
    'widget',
    inputData: {'data': data.toString()},
  );
}

Future<void> completeHwBackground(
  Uri data,
) async {
  // TODO fix completing homeworks, at least disable it
  return;
  if (data.host == 'complete') {
    String? id = data.queryParameters['db'];
    bool? isCompleted = bool.tryParse(data.queryParameters['complete'] ?? '');

    if (id != null && isCompleted != null) {
      final container = ProviderContainer();

      await Hive.initFlutter();
      Hive.registerAdapters();
      await Future.wait([
        Hive.openBox(subjectBox),
        Hive.openBox(hwBox),
        Hive.openBox(examBox),
      ]);

      // WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      await container.read(hwProvider.notifier).completeById(id, isCompleted);

      updateHwWidget(container.read(hwWidgetProvider));

      await Hive.box(hwBox).flush();
      await Hive.box(hwBox).close();
      return;
    }
  }
}
