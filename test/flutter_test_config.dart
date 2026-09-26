import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/models/task_data_model.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/vibrate.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUpAll(() {
    registerFallbackValue(TaskData.empty().toHw());
    registerFallbackValue(TaskData.empty().toExam());
    settings = SettingsDatabase(testingMode: true);
    Vibrate.createEmptyForTest();
  });

  await testMain();
}
