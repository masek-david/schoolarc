import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/screens/bakalari/bakalari_login_screen.dart';
import 'package:school_manager/screens/firebase_login/firebase_login_screen.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/screens/strava_cz/strava_login_screen.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';

class TutorialExtensions extends StatefulWidget {
  const TutorialExtensions({super.key});

  @override
  State<TutorialExtensions> createState() =>
      _TutorialExtensionsState();
}

class _TutorialExtensionsState extends State<TutorialExtensions> {
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
                context.loc.useExtensions,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 28),
              _ExtensionButton(
                value: useBaka,
                title: context.loc.bakalari,
                subtitle: context.loc.bakalariSubtitle,
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
                        builder: (context) => const BakaLoginScreen(),
                      ),
                    );
                  },
                  child: Text(context.loc.login),
                ),
              ),
              _ExtensionButton(
                title: context.loc.stravaCz,
                subtitle: context.loc.stravaCzSubtitle,
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
                        builder: (context) => const StravaLoginScreen(),
                      ),
                    );
                  },
                  child: Text(context.loc.login),
                ),
              ),
              _ExtensionButton(
                title: context.loc.cloudSync,
                subtitle: context.loc.cloudSyncSubtitle,
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
                        builder: (context) => const FirebaseLoginScreen(),
                      ),
                    );
                  },
                  child: Text(context.loc.login),
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
