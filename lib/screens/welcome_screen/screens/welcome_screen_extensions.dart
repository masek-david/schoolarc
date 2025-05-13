import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/screens/bakalari/bakalari_login_screen.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/screens/strava_cz/strava_login_screen.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/tasks_app.dart';

class WelcomeScreenExtensions extends StatefulWidget {
  const WelcomeScreenExtensions({super.key});

  @override
  State<WelcomeScreenExtensions> createState() =>
      _WelcomeScreenExtensionsState();
}

class _WelcomeScreenExtensionsState extends State<WelcomeScreenExtensions> {
  bool useBaka = settings.get(Setting.useBakalari);
  bool useStrava = settings.get(Setting.useMeals);
  bool useFirebase = settings.get(Setting.useFirebase);

  @override
  Widget build(BuildContext context) {
    return SlidableAutoCloseBehavior(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 70),
          child: Column(
            children: [
              Text(
                'You can login to these extensions:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 28),
              _ExtensionButton(
                value: useBaka,
                title: 'Bakaláři',
                subtitle: 'Import subjects and view current timetable',
                onChanged: (value) {
                  setState(() {
                    useBaka = value;
                    settings.save(Setting.useBakalari, value);
                  });
                },
                button: FilledButton(
                  onPressed: () {
                    navigatorKey.currentState?.push(
                      MaterialPageRoute(
                        builder: (context) => BakaLoginScreen(),
                      ),
                    );
                  },
                  child: Text('Login'),
                ),
              ),
              _ExtensionButton(
                title: 'Strava CZ',
                subtitle: 'View meals in your canteen',
                value: useStrava,
                onChanged: (value) {
                  setState(() {
                    useStrava = value;
                    settings.save(Setting.useMeals, value);
                  });
                },
                button: FilledButton(
                  onPressed: () {
                    navigatorKey.currentState?.push(
                      MaterialPageRoute(
                        builder: (context) => StravaLoginScreen(),
                      ),
                    );
                  },
                  child: Text('Login'),
                ),
              ),
              if (settings.get(Setting.showDebugInfo))
                _ExtensionButton(
                  title: 'Firebase',
                  subtitle: 'Backup and sync your data between devices',
                  value: useFirebase,
                  onChanged: (value) {
                    setState(() {
                      useFirebase = value;
                      settings.save(Setting.useFirebase, value);
                    });
                  },
                  button: FilledButton(
                    onPressed: () {
                      navigatorKey.currentState?.push(
                        MaterialPageRoute(
                          builder: (context) => StravaLoginScreen(),
                        ),
                      );
                    },
                    child: Text('Login'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExtensionButton extends StatelessWidget {
  const _ExtensionButton({
    // ignore: unused_element_parameter
    super.key,
    required this.value,
    required this.title,
    required this.subtitle,
    required this.onChanged,
    required this.button,
  });

  final bool value;
  final String title;
  final String subtitle;
  final void Function(bool) onChanged;
  final Widget button;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingTile.withSwitch(
          title: title,
          subtitle: subtitle,
          value: value,
          onChanged: onChanged,
        ),
        AnimatedSize(
          duration: Durations.medium1,
          child: SizedBox(
            height: value ? null : 0,
            child: button,
          ),
        ),
      ],
    );
  }
}
