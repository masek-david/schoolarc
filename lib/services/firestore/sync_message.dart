import 'dart:io';

import 'package:flutter/material.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/tasks_app.dart';

class SyncMessage {
  Map<String, int> stats = {
    'subAddHive': 0,
    'subAddFire': 0,
    'subEditHive': 0,
    'subEditFire': 0,
    'hwAddHive': 0,
    'hwAddFire': 0,
    'hwEditHive': 0,
    'hwEditFire': 0,
    'examAddHive': 0,
    'examAddFire': 0,
    'examEditHive': 0,
    'examEditFire': 0,
  };

  int subAddHive = 0;
  int subAddFire = 0;
  int subEditHive = 0;
  int subEditFire = 0;
  int hwAddHive = 0;
  int hwAddFire = 0;
  int hwEditHive = 0;
  int hwEditFire = 0;
  int examAddHive = 0;
  int examAddFire = 0;
  int examEditHive = 0;
  int examEditFire = 0;

  void reset() {
    subAddHive = 0;
    subAddFire = 0;
    subEditHive = 0;
    subEditFire = 0;
    hwAddHive = 0;
    hwAddFire = 0;
    hwEditHive = 0;
    hwEditFire = 0;
    examAddHive = 0;
    examAddFire = 0;
    examEditHive = 0;
    examEditFire = 0;
  }

  void showSyncMessage(BuildContext context) {
    if (settings.get(Setting.showDebugInfo)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black,
          content: toWidget(),
          duration: Duration(days: 100),
        ),
      );
    }
  }

  Widget toWidget() {
    return DefaultTextStyle(
      style: TextStyle(fontFamily: Platform.isIOS ? 'Courier' : 'monospace'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subAddHive != 0)
            Text('Subjects  added  from Hive    : $subAddHive'),
          if (subAddFire != 0)
            Text('Subjects  added  from FireBase: $subAddFire'),
          if (subEditHive != 0)
            Text('Subjects  edited from Hive    : $subEditHive'),
          if (subEditFire != 0)
            Text('Subjects  edited from Firebase: $subEditFire'),
          SizedBox(height: 8),
          if (hwAddHive != 0)
            Text('Homeworks added  from Hive    : $hwAddHive'),
          if (hwAddFire != 0)
            Text('Homeworks added  from FireBase: $hwAddFire'),
          if (hwEditHive != 0)
            Text('Homeworks edited from Hive    : $hwEditHive'),
          if (hwEditFire != 0)
            Text('Homeworks edited from Firebase: $hwEditFire'),
          SizedBox(height: 8),
          if (examAddHive != 0)
            Text('Exams     added  from Hive    : $examAddHive'),
          if (examAddFire != 0)
            Text('Exams     added  from FireBase: $examAddFire'),
          if (examEditHive != 0)
            Text('Exams     edited from Hive    : $examEditHive'),
          if (examEditFire != 0)
            Text('Exams     edited from Firebase: $examEditFire'),
        ],
      ),
    );
  }
}
