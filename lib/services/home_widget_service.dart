import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/features/tasks/task_functions.dart';
import 'package:schoolarc/l10n/my_localization.dart';
import 'package:schoolarc/main_app.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/models/meal_model.dart';
import 'package:schoolarc/models/task_model.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/home_page_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/date_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/button_dialog.dart';

@pragma("vm:entry-point")
FutureOr<void> backgroundCallback(Uri? data) async {
  if (data == null) return;
  log('Widget callback: $data');
  if (data.host == 'complete') {
    // Completing homework - load current data from widget storage - because we dont have Hive in this isolate
    final json = await HomeWidget.getWidgetData('tasks');
    final id = data.queryParameters['id'];
    final completed = bool.parse(data.queryParameters['complete']!);
    // The dynamic should be a list of tasks
    final Map<String, dynamic> test = jsonDecode(json);
    log(test.runtimeType.toString());
    test.forEach(
      (key, list) {
        final index = list.indexWhere((element) => element['id'] == id);
        if (index != -1) {
          // Update the completion and save the data to widget
          list[index]['isCompleted'] = completed;
        }
      },
    );
    HomeWidgetService._saveAndUpdateMain(jsonEncode(test));
    // Save the data to isolatedHive, so we can read it from any isolate
    await IsolatedHive.initFlutter();
    final box = await IsolatedHive.openBox('widgetCompletedTasks');
    await box.put(id, completed);
    await box.close();
  }
}

class HomeWidgetService {
  static final isSupportedPlatform = !kIsWeb && Platform.isAndroid;

  static void addClickPickAction(BuildContext context) {
    showButtonDialog(
      context,
      title: context.loc.pickAction,
      icon: Icons.add_rounded,
      buttons: [
        ButtonDialogButton(
          onTap: () {
            Navigator.pop(context);
            addNewHw(context);
          },
          isFirst: true,
          text: context.loc.addNewHomework,
        ),
        ButtonDialogButton(
          onTap: () {
            Navigator.pop(context);
            addNewExam(context);
          },
          isLast: true,
          text: context.loc.addNewExam,
        ),
      ],
    );
  }

  /// Checks all past completed homework, updates them
  ///
  /// Then saves widget data and updates the widget
  static Future<void> updateMainWidget(WidgetRef ref) async {
    if (!isSupportedPlatform) return;

    await checkForCompletedHomework(ref);

    Map<String, dynamic> json = {};
    Map<Date, List<Task>> tasks = {};
    final hws = ref.read(hwDatesProvider);
    final exams = ref.read(examsDatesProvider);

    final now = Date.today();
    for (int i = 0; i < 14; i++) {
      final date = now.addDays(i);
      tasks.addAll({
        date: [...hws[date] ?? [], ...exams[date] ?? []],
      });
    }

    tasks.forEach(
      (key, value) {
        value.sort(
          (a, b) {
            if (a.runtimeType == b.runtimeType) {
              return b.priority.index.compareTo(a.priority.index);
            } else {
              return a is Homework ? 1 : -1;
            }
          },
        );
      },
    );

    json = tasks.map(
      (key, value) => MapEntry(
        key.toPrimitiveInt().toString(),
        value
            .map(
              (e) => e.toWidgetJson(),
            )
            .toList(),
      ),
    );

    _saveAndUpdateMain(jsonEncode(json));
  }

  static Future<void> _saveAndUpdateMain(String data) async {
    final result = await HomeWidget.saveWidgetData('tasks', data);
    log('Saving data to widget: ${result == true ? 'Success' : 'Error'}');
    await HomeWidget.updateWidget(
      androidName: 'MainWidgetReceiver',
      qualifiedAndroidName: 'cz.masci.schoolarc.MainWidgetReceiver',
    );
  }

  static Future<void> widgetSaveLocalizationStrings(
    BuildContext context,
  ) async {
    if (!isSupportedPlatform) return;
    final loc = getLocalizationWithoutContext();

    await HomeWidget.saveWidgetData(
      'loc',
      jsonEncode({
        'locale': context.locale.languageCode,
        'format': getFormatPattern(context, false),
        'shortFormat': getFormatPattern(context, true),
        'today': loc.today,
        'tomorrow': loc.tomorrow,
        'noHomework': loc.noHomework,
        'noExams': loc.noExams,
        'noMealsFound': loc.noMealsFound,
        'nothingPlanned': loc.nothingPlanned,
      }),
    );
  }

  static void updateMealsWidget(Map<Date, List<Meal>> meals) {
    if (!isSupportedPlatform) return;
    Map<String, dynamic> json = {};
    final today = Date.today();

    meals.forEach(
      (key, value) {
        // if it is after meal time, dont include meal for today
        if (!key.isSameDay(today) ||
            TimeOfDay.fromDateTime(
              DateTime.now(),
            ).isBefore(settings.get(Setting.mealsShowTodayUntil))) {
          json[key.toPrimitiveInt().toString()] = value
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

  // checks hws that were completed from the widget, and notifies the notifier
  static Future<void> checkForCompletedHomework(WidgetRef ref) async {
    final hws = ref.read(hwDataProvider);
    await IsolatedHive.initFlutter();
    final box = await IsolatedHive.openBox('widgetCompletedTasks');

    final data = await box.toMap();
    data.forEach(
      (id, completed) async {
        if (hws[id]?.isCompleted != completed) {
          await ref.read(hwDataProvider.notifier).completeById(id, completed);
        }
      },
    );
    await box.deleteFromDisk();
    await box.close();
  }

  static void handleWidgetClick(Uri uri, BuildContext context, WidgetRef ref) {
    Navigator.popUntil(context, (route) => route.isFirst);
    closeDrawer();
    if (uri.host == 'create') {
      addClickPickAction(context);
    } else if (uri.host == 'view') {
      final id = uri.queryParameters['id'];
      if (bool.parse(uri.queryParameters['isHomework']!)) {
        final hw = ref.read(hwProvider)[id];
        if (hw != null) {
          editHw(context, hw);
        }
      } else {
        final exam = ref.read(examProvider)[id];
        if (exam != null) {
          editExam(context, exam);
        }
      }
    } else if (uri.host == 'calendar') {
      // final dateString = uri.queryParameters['date'] as String;
      // final date = Date.fromPrimitiveInt(int.parse(dateString));
      ref.read(homePageProvider.notifier).switchPage(1);
    } else if (uri.host == 'meals') {
      Navigator.restorablePushNamed(context, '/meals');
    }
  }
}
