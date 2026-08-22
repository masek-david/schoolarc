import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/utils/globals.dart';

class AnalyticsService {
  static bool _initialized = false;

  static bool get enabled {
    return settings.get(Setting.analyticsEnabled) as bool;
  }

  static Future<void> init() async {
    if (enabled) await _setup();
  }

  static Future<void> optIn() async {
    settings.save(Setting.analyticsEnabled, true);
    if (_initialized) {
      await Posthog().enable();
      Posthog().capture(eventName: 'Analytics enabled');
    } else {
      await _setup();
    }
  }

  static Future<void> optOut() async {
    settings.save(Setting.analyticsEnabled, false);
    await Posthog().disable();
  }

  static Future<void> _setup() async {
    final config = PostHogConfig(
      'phc_x5TkdevmkSHJd2aCegaKgXxtS9Jthm9h3zXegix6YpnY',
    );
    config.host = 'https://eu.i.posthog.com';
    config.errorTrackingConfig.captureFlutterErrors = true;
    config.errorTrackingConfig.captureSilentFlutterErrors = false;

    if (!kIsWeb) {
      config.errorTrackingConfig.capturePlatformDispatcherErrors = true;
      config.errorTrackingConfig.captureIsolateErrors = true;
      config.errorTrackingConfig.captureNativeExceptions = true;
    }

    await Posthog().setup(config);
    _initialized = true;
  }
}
