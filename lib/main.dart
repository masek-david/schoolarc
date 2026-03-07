import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:schoolarc/app_config.dart';
import 'package:schoolarc/database/hive/hive_init.dart';
import 'package:schoolarc/firebase_options.dart';
import 'package:schoolarc/models/exception_model.dart';
import 'package:schoolarc/services/home_widget_service.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/licenses.dart';
import 'package:schoolarc/utils/notifications/notification_sender.dart';
import 'package:schoolarc/utils/vibrate.dart';

Future<void> main() async {
  FlutterError.onError = (details) {
    FlutterError.presentError(details); // Current error

    String text =
        '${details.exception.toString()}\n\n ${details.stack.toString()}\nlibrary: ${details.library}\n\ncontext: ';

    text += details.context?.value.toString() ?? '';

    logsService.save(text);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    logsService.save(
      'platform dispatcher: ${error.toString()}\n${stack.toString()}',
    );
    return true;
  };

  await initHive();
  await initNotifications();
  await initializeDateFormatting();

  // gets rid of android bottom colored bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  packageInfo = await PackageInfo.fromPlatform();
  vibrate = await Vibrate.create();

  if (!kIsWeb && Platform.isAndroid) {
    HomeWidget.registerInteractivityCallback(backgroundCallback);
  }

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
