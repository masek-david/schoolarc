import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/provider/bakalari/baka_login_notifier.dart';
import 'package:schoolarc/provider/firebase/firebase_login_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/strava/strava_login_notifier.dart';
import 'package:schoolarc/screens/bakalari/bakalari_login_screen.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/screens/tutorial/animated_page.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/widgets/login_status_icon.dart';

class OnboardingExtensions extends ConsumerWidget {
  const OnboardingExtensions({
    super.key,
    required this.next,
    required this.isNewUser,
  });

  final void Function() next;
  final bool isNewUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useBaka = ref.watch(useBakaProvider);
    final useMeals = ref.watch(useMealsProvider);
    final useCloudSync = ref.watch(useCloudSyncProvider);

    return SafeArea(
      child: AnimatedPage(
        children: [
          AnimatedItem(
            builder: (isShown) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(8, 64, 8, 16),
                child: Text(
                  context.loc.useExtensions,
                  style: context.txt.headlineMedium,
                ),
              );
            },
          ),
          AnimatedItem(
            builder: (isShown) {
              return SettingTile.withSwitch(
                heroTag: 'cloudsync',
                isFirst: true,
                title: context.loc.cloudSync,
                subtitle: context.loc.cloudSyncSubtitle,
                value: useCloudSync,
                onChanged: (value) {
                  ref.read(useCloudSyncProvider.notifier).set(value);
                },
                leading: useCloudSync
                    ? LoginStatusIcon(
                        provider: firebaseLoginProvider,
                        showProvider: useCloudSyncProvider,
                      )
                    : null,
                newLineAction: useCloudSync
                    ? FilledButton.tonal(
                        onPressed: () {
                          Navigator.restorablePushNamed(
                            context,
                            '/cloudsync',
                          );
                        },
                        child: Text(context.loc.login),
                      )
                    : null,
              );
            },
          ),
          AnimatedItem(
            builder: (isShown) {
              return SettingTile.withSwitch(
                heroTag: 'bakalari',
                value: useBaka,
                title: context.loc.bakalari,
                subtitle: context.loc.bakalariSubtitle,
                onChanged: (value) {
                  ref.read(useBakaProvider.notifier).set(value);
                },
                leading: useBaka
                    ? LoginStatusIcon(
                        provider: bakaLoginProvider,
                        showProvider: useBakaProvider,
                      )
                    : null,
                newLineAction: useBaka
                    ? FilledButton.tonal(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BakaLoginScreen(
                                askToImportTimetableOnLogin: isNewUser,
                              ),
                            ),
                          );
                        },
                        child: Text(context.loc.login),
                      )
                    : null,
              );
            },
          ),
          AnimatedItem(
            builder: (isShown) {
              return SettingTile.withSwitch(
                heroTag: 'strava',
                isLast: true,
                title: context.loc.stravaCz,
                subtitle: context.loc.stravaCzSubtitle,
                value: useMeals,
                onChanged: (value) {
                  ref.read(useMealsProvider.notifier).set(value);
                },
                leading: useMeals
                    ? LoginStatusIcon(
                        provider: stravaLoginProvider,
                        showProvider: useMealsProvider,
                      )
                    : null,
                newLineAction: useMeals
                    ? FilledButton.tonal(
                        onPressed: () {
                          Navigator.restorablePushNamed(context, '/strava');
                        },
                        child: Text(context.loc.login),
                      )
                    : null,
              );
            },
          ),
          AnimatedItem(
            builder: (isShown) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: FilledButton(
                  onPressed: () => next(),
                  child: Text(context.loc.continueAction),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
