import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:schoolarc/app_config.dart';
import 'package:schoolarc/database/hive/hive_init.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/features/plus/plus.dart';
import 'package:schoolarc/firebase_options.dart';
import 'package:schoolarc/models/exception_model.dart';
import 'package:schoolarc/services/analytics_service.dart';
import 'package:schoolarc/services/home_widget_service.dart';
import 'package:schoolarc/utils/globals.dart' as globals;
import 'package:schoolarc/utils/licenses.dart';
import 'package:schoolarc/utils/notifications/notification_sender.dart';
import 'package:schoolarc/utils/vibrate.dart';
import 'package:yaml/yaml.dart';

Future<void> main() async {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);

    String text =
        '${details.exception.toString()}\n\n ${details.stack.toString()}\nlibrary: ${details.library}\n\ncontext: ';

    text += details.context?.value.toString() ?? '';

    globals.logsService.save(text);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    globals.logsService.save(
      'Platform Dispatcher Error: ${error.toString()}\n${stack.toString()}',
    );
    return true;
  };

  await initHive();
  WidgetsFlutterBinding.ensureInitialized();
  globals.settings = SettingsDatabase();

  final futureResult = await Future.wait<dynamic>([
    rootBundle.loadString('pubspec.yaml'),
    NotificationSender.initNotifications(),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    Vibrate.create(),
    initRevenueCat(),
    initializeDateFormatting(),
    AnalyticsService.init(),
    if (HomeWidgetService.isSupportedPlatform)
      HomeWidget.registerInteractivityCallback(backgroundCallback),
  ]);
  final version = (loadYaml(futureResult[0])['version'] as String).split('+');

  globals.appVersion = version[0];
  globals.appBuildNumber = int.parse(version[1]);
  addLicenses();

  runApp(
    ProviderScope(
      child: const AppConfig(),
      retry: (retryCount, error) {
        // Dont retry if offline
        if (error is NetworkException && error.code == .offline) return null;
        // Dont retry if the user isnt even logged in
        if (error is AuthException && error.code == .loggedOut) return null;
        if (retryCount > 3) return null;
        return Duration(seconds: retryCount * 2);
      },
    ),
  );
}
