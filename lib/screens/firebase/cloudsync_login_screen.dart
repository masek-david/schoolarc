import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/group_models.dart';
import 'package:schoolarc/provider/firebase/firebase_login_notifier.dart';
import 'package:schoolarc/provider/firebase/firebase_nickname_notifier.dart';
import 'package:schoolarc/provider/use_cloudsync_notifier.dart';
import 'package:schoolarc/screens/login_input_screen.dart';
import 'package:schoolarc/screens/settings/settings_scaffold.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/screens/shared/username_text.dart';
import 'package:schoolarc/services/firebase/firebase_service.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/dialogs/progress_dialog.dart';
import 'package:schoolarc/widgets/dialogs/show_adaptive_dialog.dart';
import 'package:schoolarc/widgets/login_status_icon.dart';
import 'package:schoolarc/widgets/tiles/error_tile.dart';

class CloudSyncLoginScreen extends ConsumerWidget {
  const CloudSyncLoginScreen({super.key});

  Future<void> pushScreen(BuildContext context, Widget screen) {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => screen,
    ));
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
          onPressed: () => showConsentDialog(context, ref),
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
              ref.read(useCloudSyncProvider.notifier).set(value, context, ref),
          title: context.loc.useCloudSync,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        const Divider(),
        state.when(
          data: (data) => SettingTile(
            isLast: true,
            isFirst: true,
            title: data ? context.loc.loggedIn : context.loc.loggedOut,
            subtitle: ref.read(firebaseServiceProvider).userEmail,
            leading: data
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const LoggedOutIcon(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          error: (error, stackTrace) => ErrorTile(
            error: error,
            text: context.loc.errorLoggingIn,
            allowActions: false,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
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
                            initialValue:
                                ref.read(firebaseServiceProvider).userEmail,
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
                              showMessage(
                                context,
                                ref
                                    .read(firebaseLoginProvider)
                                    .error
                                    .toString(),
                                isError: true,
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
                              showMessage(
                                context,
                                e.toString(),
                                isError: true,
                              );
                            }
                            return;
                          }

                          if (context.mounted) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            showMessage(context, context.loc.loggedInSynced);
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
                            showMessage(context, context.loc.notSamePassword,
                                isError: true);
                            return;
                          }

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => ProgressDialog(
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
                                  nickname: fields[1]);

                          if (ref.read(firebaseLoginProvider).value != true) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMessage(
                                context,
                                ref
                                    .read(firebaseLoginProvider)
                                    .error
                                    .toString(),
                                isError: true,
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
                              showMessage(context, e.toString(), isError: true);
                            }
                            return;
                          }

                          if (context.mounted) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            showMessage(
                                context, context.loc.registeredSuccessfully);
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
              if (nickname.isLoading) const CircularProgressIndicator(),
              Expanded(
                child: NicknameText(
                  user: Member(
                      ref.read(firebaseServiceProvider).auth.currentUser?.uid ??
                          '',
                      nickname.value ?? ''),
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
                                  showMessage(context, e.toString(),
                                      isError: true);
                                }
                                return;
                              }

                              if (context.mounted) {
                                showMessage(
                                    context, context.loc.nicknameChanged);
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
                            showMessage(context, context.loc.notSamePassword,
                                isError: true);
                            return;
                          }

                          if (fields[0] == fields[1]) {
                            showMessage(
                              context,
                              context.loc.samePasswords,
                              isError: true,
                            );
                            return;
                          }

                          try {
                            await ref
                                .read(firebaseServiceProvider)
                                .changePassword(fields[0], fields[1]);
                          } on Object catch (e) {
                            if (context.mounted) {
                              showMessage(
                                context,
                                '${context.loc.errorChangingPassword}\n$e',
                                isError: true,
                              );
                            }
                            return;
                          }

                          if (context.mounted) {
                            showMessage(context,
                                context.loc.passwordChangedSuccessfully);
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
                                showMessage(context, e.toString(),
                                    isError: true);
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
                      await ref.read(firebaseServiceProvider).getAllData();
                    } on Object catch (e) {
                      if (context.mounted) {
                        showMessage(context, e.toString(), isError: true);
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
                                        .deleteAllData(fields[0]);
                                  } on Object catch (e) {
                                    if (context.mounted) {
                                      showMessage(context, e.toString(),
                                          isError: true);
                                    }
                                    return;
                                  }

                                  await ref
                                      .read(firebaseLoginProvider.notifier)
                                      .logOut();

                                  if (context.mounted) {
                                    showMessage(
                                        context, context.loc.deletedAllData);
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
