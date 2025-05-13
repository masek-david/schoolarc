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
  State<WelcomeScreenExtensions> createState() => _WelcomeScreenExtensionsState();
}

class _WelcomeScreenExtensionsState extends State<WelcomeScreenExtensions> {
  bool useBaka = true;
  bool useStrava = false;
  bool useFirebase = false;

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
            SettingTile(
              title: 'Bakaláři',
              subtitle: 'Import subjects and view timetable',
              trailing: Switch(
                value: useBaka,
                onChanged: (value) {
                  setState(() {
                    useBaka = value;
                    settings.save(Setting.useBakalari, value);
                  });
                },
              ),
              newLineAction: useBaka
                  ? FilledButton(
                      onPressed: () {
                        navigatorKey.currentState?.push(
                          MaterialPageRoute(
                            builder: (context) => BakaLoginScreen(),
                          ),
                        );
                      },
                      child: Text('Login'),
                    )
                  : null,
            ),
            SettingTile(
              title: 'Strava CZ',
              subtitle: 'View meals in your canteen',
              trailing: Switch(
                value: useStrava,
                onChanged: (value) {
                  setState(() {
                    useStrava = value;
                    settings.save(Setting.useMeals, value);
                  });
                },
              ),
              newLineAction: useStrava
                  ? FilledButton(
                      onPressed: () {
                        navigatorKey.currentState?.push(
                          MaterialPageRoute(
                            builder: (context) => StravaLoginScreen(),
                          ),
                        );
                      },
                      child: Text('Login'),
                    )
                  : null,
            ),
          ],
        ),
      )),
    );
  }
}
