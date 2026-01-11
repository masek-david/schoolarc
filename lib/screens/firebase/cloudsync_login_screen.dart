import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/exception_model.dart';
import 'package:schoolarc/models/group_models.dart';
import 'package:schoolarc/provider/firebase/firebase_login_notifier.dart';
import 'package:schoolarc/provider/firebase/firebase_nickname_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/login_input_screen.dart';
import 'package:schoolarc/screens/onboarding/privacy_policy.dart';
import 'package:schoolarc/screens/settings/settings_scaffold.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/screens/shared/username_text.dart';
import 'package:schoolarc/services/firebase/firebase_service.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/dialogs/progress_dialog.dart';
import 'package:schoolarc/widgets/dialogs/show_adaptive_dialog.dart';
import 'package:schoolarc/widgets/expressive_loading/expressive_loading_indicator.dart';
import 'package:schoolarc/widgets/login_status_icon.dart';
import 'package:schoolarc/widgets/tiles/error_tile.dart';

class CloudSyncLoginScreen extends ConsumerWidget {
  const CloudSyncLoginScreen({super.key, this.onDataSyncSuccess});

  final void Function()? onDataSyncSuccess;

  Future<void> pushScreen(BuildContext context, Widget screen) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool useCloudSync = ref.watch(useCloudSyncProvider);

    final state = ref.watch(firebaseLoginProvider);
    final nickname = ref.watch(firebaseNicknameProvider);
    final loggedIn = state.value == true;

    return SettingsScaffold(
      heroTag: 'cloudsync',
      title: context.loc.cloudSync,
      actions: [
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PrivacyPolicy(),
            ),
          ),
          icon: const Icon(Icons.info_outline),
        ),
      ],
      children: [
        SettingTile.withSwitch(
          isLast: true,
          isFirst: true,
          highlighted: true,
          value: useCloudSync,
          onChanged: (value) =>
              ref.read(useCloudSyncProvider.notifier).set(value),
          title: context.loc.useCloudSync,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        state.when(
          data: (data) => SettingTile(
            isLast: true,
            isFirst: true,
            title: data ? context.loc.loggedIn : context.loc.loggedOut,
            subtitle: ref.read(firebaseServiceProvider).userEmail,
            leading: data
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const FilledIcon(Icons.logout_rounded, color: Colors.yellow),
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          error: (error, stackTrace) => ErrorTile(
            error: error,
            text: context.loc.errorLoggingIn,
            allowActions: false,
          ),
          loading: () => Center(
            child: MyExpressiveLoadingIndicator.big(
              useHaptics: ref.read(themeExpressiveHapticsProvider),
            ),
          ),
        ),
        if (!loggedIn)
          OutlinedButton(
            onPressed: useCloudSync
                ? () async {
                    pushScreen(
                      context,
                      LoginInputScreen(
                        actionName: context.loc.logIn,
                        fields: [
                          LoginField(
                            name: context.loc.email,
                            initialValue: ref
                                .read(firebaseServiceProvider)
                                .userEmail,
                            autofillHints: [AutofillHints.email],
                          ),
                          LoginField(
                            name: context.loc.password,
                            obscure: true,
                            autofillHints: [AutofillHints.password],
                          ),
                        ],
                        onSubmit: (fields) async {
                          final key = GlobalKey<ProgressDialogState>();

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => ProgressDialog(
                              useHaptics: ref.read(
                                themeExpressiveHapticsProvider,
                              ),
                              key: key,
                              initialText: context.loc.loggingIn,
                              showProgressNumber: false,
                            ),
                          );

                          await ref
                              .read(firebaseLoginProvider.notifier)
                              .logIn(email: fields[0], password: fields[1]);

                          if (ref.read(firebaseLoginProvider).value != true) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showErrorMessage(
                                context,
                                ref.read(firebaseLoginProvider).error ?? Object,
                              );
                              return;
                            }
                          }

                          if (context.mounted) {
                            key.currentState?.changeText(context.loc.syncing);
                          }

                          try {
                            await syncAllTasks(ref);
                          } on Object catch (e) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showErrorMessage(context, e);
                            }
                            return;
                          }

                          if (context.mounted) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            showMessage(context, context.loc.loggedInSynced);
                            if (onDataSyncSuccess != null) {
                              onDataSyncSuccess!();
                            }
                          }
                        },
                      ),
                    );
                  }
                : null,
            child: Text(context.loc.logIn),
          ),
        if (!loggedIn)
          OutlinedButton(
            onPressed: useCloudSync
                ? () async {
                    pushScreen(
                      context,
                      LoginInputScreen(
                        actionName: context.loc.register,
                        fields: [
                          LoginField(
                            name: context.loc.email,
                            autofillHints: [AutofillHints.username],
                          ),
                          LoginField(
                            name: context.loc.nickname,
                            info: context.loc.nicknameInfo,
                          ),
                          LoginField(
                            name: context.loc.password,
                            obscure: true,
                            autofillHints: [AutofillHints.password],
                          ),
                          LoginField(
                            name: context.loc.repeatPassword,
                            obscure: true,
                            autofillHints: [AutofillHints.password],
                          ),
                        ],
                        onSubmit: (fields) async {
                          final key = GlobalKey<ProgressDialogState>();

                          if (fields[2] != fields[3]) {
                            showErrorMessage(
                              context,
                              AuthException(.repeatedPasswordNotSame),
                            );
                            return;
                          }

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => ProgressDialog(
                              useHaptics: ref.read(
                                themeExpressiveHapticsProvider,
                              ),
                              key: key,
                              initialText: context.loc.loggingIn,
                              showProgressNumber: false,
                            ),
                          );

                          await ref
                              .read(firebaseLoginProvider.notifier)
                              .register(
                                email: fields[0],
                                password: fields[2],
                                nickname: fields[1],
                              );

                          if (ref.read(firebaseLoginProvider).value != true) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showErrorMessage(
                                context,
                                ref.read(firebaseLoginProvider).error ?? Object,
                              );
                              return;
                            }
                          }

                          if (context.mounted) {
                            key.currentState?.changeText(context.loc.syncing);
                          }
                          try {
                            await syncAllTasks(ref);
                          } on Object catch (e) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showErrorMessage(context, e);
                            }
                            return;
                          }

                          if (context.mounted) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            showMessage(
                              context,
                              context.loc.registeredSuccessfully,
                            );
                          }
                        },
                      ),
                    );
                  }
                : null,
            child: Text(context.loc.register),
          ),
        if (loggedIn)
          Row(
            children: [
              if (nickname.isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: MyExpressiveLoadingIndicator(size: 24),
                ),
              Expanded(
                child: NicknameText(
                  user: Member(
                    ref.read(firebaseServiceProvider).auth.currentUser?.uid ??
                        '',
                    nickname.value ?? '',
                  ),
                  radius: 18,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.edit_outlined),
                onPressed: useCloudSync
                    ? () async {
                        pushScreen(
                          context,
                          LoginInputScreen(
                            actionName: context.loc.changeNickname,
                            fields: [
                              LoginField(name: context.loc.newNickname),
                            ],
                            onSubmit: (fields) async {
                              try {
                                await ref
                                    .read(firebaseNicknameProvider.notifier)
                                    .saveNickname(fields[0]);
                              } on Object catch (e) {
                                if (context.mounted) {
                                  showErrorMessage(context, e);
                                }
                                return;
                              }

                              if (context.mounted) {
                                showMessage(
                                  context,
                                  context.loc.nicknameChanged,
                                );
                                Navigator.pop(context);
                              }
                            },
                          ),
                        );
                      }
                    : null,
                label: Text(context.loc.changeNickname),
              ),
            ],
          ),
        if (kDebugMode)
          // TODO
          OutlinedButton(
            onPressed: useCloudSync
                ? () async {
                    await ref.read(firebaseServiceProvider).verify();
                  }
                : null,
            child: const Text('Verify email'),
          ),
        if (loggedIn)
          OutlinedButton(
            onPressed: useCloudSync
                ? () async {
                    pushScreen(
                      context,
                      LoginInputScreen(
                        actionName: context.loc.changePassword,
                        fields: [
                          LoginField(
                            name: context.loc.oldPassword,
                            obscure: true,
                            autofillHints: [AutofillHints.password],
                          ),
                          LoginField(
                            name: context.loc.newPassword,
                            obscure: true,
                            autofillHints: [AutofillHints.newPassword],
                          ),
                          LoginField(
                            name: context.loc.repeatNewPassword,
                            obscure: true,
                            autofillHints: [AutofillHints.newPassword],
                          ),
                        ],
                        onSubmit: (fields) async {
                          if (fields[1] != fields[2]) {
                            showErrorMessage(
                              context,
                              AuthException(.repeatedPasswordNotSame),
                            );
                            return;
                          }

                          if (fields[0] == fields[1]) {
                            showErrorMessage(
                              context,
                              AuthException(.newOldPasswordSame),
                            );
                            return;
                          }

                          try {
                            await ref
                                .read(firebaseServiceProvider)
                                .changePassword(
                                  oldPassword: fields[0],
                                  password: fields[1],
                                );
                          } on Object catch (e) {
                            if (context.mounted) {
                              showErrorMessage(context, e);
                              showErrorMessage(
                                context,
                                e,
                                message: context.loc.errorChangingPassword,
                              );
                            }
                            return;
                          }

                          if (context.mounted) {
                            showMessage(
                              context,
                              context.loc.passwordChangedSuccessfully,
                            );
                            Navigator.pop(context);
                          }
                        },
                      ),
                    );
                  }
                : null,
            child: Text(context.loc.changePassword),
          ),
        if (loggedIn)
          OutlinedButton(
            onPressed: useCloudSync
                ? () async {
                    showDialogAdaptive(
                      context: context,
                      title: Text('${context.loc.logOut}?'),
                      actions: [
                        adaptiveDialogButton(
                          context: context,
                          child: Text(context.loc.cancel),
                          onPressed: () => Navigator.pop(context),
                        ),
                        adaptiveDialogButton(
                          context: context,
                          isDestructiveAction: true,
                          child: Text(context.loc.logOut),
                          onPressed: () async {
                            Navigator.pop(context);
                            try {
                              await ref
                                  .read(firebaseLoginProvider.notifier)
                                  .logOut();
                            } on Object catch (e) {
                              if (context.mounted) {
                                showErrorMessage(context, e);
                              }
                              return;
                            }

                            if (context.mounted) {
                              showMessage(context, context.loc.loggedOut);
                            }
                          },
                        ),
                      ],
                    );
                  }
                : null,
            child: Text(context.loc.logOut),
          ),
        if (loggedIn)
          OutlinedButton(
            onPressed: useCloudSync
                ? () async {
                    try {
                      await ref
                          .read(firebaseServiceProvider)
                          .getAllData(context);
                    } on Object catch (e) {
                      if (context.mounted) {
                        showErrorMessage(context, e);
                      }
                      return;
                    }
                  }
                : null,
            child: Text(context.loc.getAllData),
          ),
        if (loggedIn) const Divider(),
        if (loggedIn)
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return context.col.errorContainer.withAlpha(14);
                }
                return context.col.errorContainer;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return context.col.onErrorContainer.withAlpha(80);
                }
                return context.col.onErrorContainer;
              }),
            ),
            onPressed: useCloudSync
                ? () async {
                    pushScreen(
                      context,
                      LoginInputScreen(
                        actionName: context.loc.deleteAllData,
                        fields: [
                          LoginField(
                            name: context.loc.password,
                            obscure: true,
                            autofillHints: [AutofillHints.password],
                          ),
                        ],
                        onSubmit: (fields) async {
                          showDialogAdaptive(
                            context: context,
                            title: Text(context.loc.deleteAllDataTitle),
                            content: Text(context.loc.deleteAllDataText),
                            actions: [
                              adaptiveDialogButton(
                                context: context,
                                child: Text(context.loc.cancel),
                                onPressed: () => Navigator.pop(context),
                              ),
                              adaptiveDialogButton(
                                context: context,
                                isDestructiveAction: true,
                                child: Text(context.loc.delete),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  try {
                                    await ref
                                        .read(firebaseServiceProvider)
                                        .deleteAllData(password: fields[0]);
                                  } on Object catch (e) {
                                    if (context.mounted) {
                                      showErrorMessage(context, e);
                                    }
                                    return;
                                  }

                                  await ref
                                      .read(firebaseLoginProvider.notifier)
                                      .logOut();

                                  if (context.mounted) {
                                    showMessage(
                                      context,
                                      context.loc.deletedAllData,
                                    );
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  }
                : null,
            child: Text(context.loc.deleteAllData),
          ),
      ],
    );
  }
}
