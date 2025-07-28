import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:schoolarc/provider/baka_login_notifier.dart';
import 'package:schoolarc/provider/firebase_login_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/strava_login_notifier.dart';
import 'package:schoolarc/provider/use_cloudsync_notifier.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/widgets/login_status_icon.dart';

class TutorialExtensions extends ConsumerWidget {
  const TutorialExtensions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useBaka = ref.watch(useBakaProvider);
    final useMeals = ref.watch(useMealsProvider);
    final useCloudSync = ref.watch(useCloudSyncProvider);

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
                  ref.read(useBakaProvider.notifier).set(value);
                },
                leading: LoginStatusIcon(
                  provider: bakaLoginProvider,
                  showProvider: useBakaProvider,
                ),
                button: FilledButton(
                  onPressed: () {
                    Navigator.restorablePushNamed(context, '/bakalari');
                  },
                  child: Text(context.loc.login),
                ),
              ),
              _ExtensionButton(
                title: context.loc.stravaCz,
                subtitle: context.loc.stravaCzSubtitle,
                value: useMeals,
                onChanged: (value) {
                  ref.read(useMealsProvider.notifier).set(value);
                },
                leading: LoginStatusIcon(
                  provider: stravaLoginProvider,
                  showProvider: useMealsProvider,
                ),
                button: FilledButton(
                  onPressed: () {
                    Navigator.restorablePushNamed(context, '/strava');
                  },
                  child: Text(context.loc.login),
                ),
              ),
              _ExtensionButton(
                title: context.loc.cloudSync,
                subtitle: context.loc.cloudSyncSubtitle,
                value: useCloudSync,
                onChanged: (value) {
                  ref
                      .read(useCloudSyncProvider.notifier)
                      .set(value, context, ref);
                },
                leading: LoginStatusIcon(
                  provider: firebaseLoginProvider,
                  showProvider: useCloudSyncProvider,
                ),
                button: FilledButton(
                  onPressed: () {
                    Navigator.restorablePushNamed(context, '/cloudsync');
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
    this.leading,
  });

  final bool value;
  final String title;
  final String subtitle;
  final void Function(bool) onChanged;
  final Widget button;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingTile.withSwitch(
          title: title,
          leading: leading,
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
