import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/screens/bakalari/bakalari_login_screen.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/screens/strava_cz/strava_login_screen.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/tasks_app.dart';

class WelcomeScreenBakalari extends StatefulWidget {
  const WelcomeScreenBakalari({super.key});

  @override
  State<WelcomeScreenBakalari> createState() => _WelcomeScreenBakalariState();
}

class _WelcomeScreenBakalariState extends State<WelcomeScreenBakalari> {
  bool useBaka = true;
  bool useStrava = false;

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
                    settings.save(Setting.homeShowBaka, value);
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
                    settings.save(Setting.homeShowMeals, value);
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
