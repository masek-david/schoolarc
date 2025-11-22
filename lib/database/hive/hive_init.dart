import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:schoolarc/database/hive/hive_registrar.g.dart';

const String subjectBox = 'subjectBox';
const String hwBox = 'hwBox';
const String examBox = 'examBox';
const String tableBox = 'timeTableBox';
const String bakaAddedHw = 'bakaAddedHw';
const String bakaSeenHw = 'bakaSeenHw';
const String settingsBox = 'settings';
const String logBox = 'logBox';

/// inits hive, can be called even if it is already initialised
Future<void> initHive() async {
  await Hive.initFlutter();
  try {
    Hive.registerAdapters();
  } catch (e) {
    // the adapters are already registered
  }
  await Hive.openBox(examBox);

  await Future.wait([
    Hive.openBox(subjectBox),
    Hive.openBox(hwBox),
    Hive.openBox(examBox),
    Hive.openBox(tableBox),
    Hive.openBox(bakaAddedHw),
    Hive.openBox(bakaSeenHw),
    Hive.openBox(settingsBox),
    Hive.openBox(logBox),
  ]);
}
