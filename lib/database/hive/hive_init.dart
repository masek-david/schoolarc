import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:schoolarc/database/hive/hive_registrar.g.dart';

const String subjectBox = 'subjectBox';
const String hwBox = 'hwBox';
const String examBox = 'examBox';
const String timetableBox = 'timetableBoxV1';
const String bakaAddedHw = 'bakaAddedHw';
const String bakaSeenHw = 'bakaSeenHw';
const String settingsBox = 'settings';
const String logBox = 'logBox';

/// inits hive, can be called even if it is already initialised
Future<void> initHive() async {
  if (!kIsWeb && Platform.isWindows) {
    await Hive.initFlutter('Schoolarc${kDebugMode ? '_debug' : ''}');
  } else {
    await Hive.initFlutter();
  }
  try {
    Hive.registerAdapters();
  } catch (e) {
    // the adapters are already registered
  }

  await Future.wait([
    Hive.openBox(examBox),
    Hive.openBox(subjectBox),
    Hive.openBox(hwBox),
    Hive.openBox(examBox),
    Hive.openBox(timetableBox),
    Hive.openBox(bakaAddedHw),
    Hive.openBox(bakaSeenHw),
    Hive.openBox(settingsBox),
    Hive.openBox(logBox),
  ]);
}
