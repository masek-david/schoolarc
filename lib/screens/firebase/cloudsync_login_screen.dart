import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/exception_model.dart';
import 'package:schoolarc/models/group_models.dart';
import 'package:schoolarc/provider/firebase/firebase_nickname_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/login_input_screen.dart';
import 'package:schoolarc/screens/onboarding/privacy_policy.dart';
import 'package:schoolarc/screens/settings/settings_scaffold.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/screens/shared/nickname_text.dart';
import 'package:schoolarc/services/firebase/firebase_service.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/dialogs/progress_dialog.dart';
import 'package:schoolarc/widgets/dialogs/show_adaptive_dialog.dart';

// TODO edit the buttons

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

  Future<void> editNickname(BuildContext context, WidgetRef ref) async {
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

  Future<void> changePassword(BuildContext context, WidgetRef ref) async {
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
            await fireService.changePassword(
              oldPassword: fields[0],
              password: fields[1],
            );
          } catch (e) {
            if (context.mounted) {
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

  Future<void> changeEmail(BuildContext context, WidgetRef ref) async {
    pushScreen(
      context,
      LoginInputScreen(
        actionName: 'Change email address',
        fields: [
          LoginField(
            name: 'New email address',
            obscure: false,
            autofillHints: [AutofillHints.email],
          ),
          LoginField(
            name: 'Password',
            obscure: true,
            autofillHints: [AutofillHints.password],
          ),
        ],
        onSubmit: (fields) async {
          try {
            await fireService.changeEmail(
              newEmail: fields[0],
              password: fields[1],
            );
          } catch (e) {
            if (context.mounted) {
              showErrorMessage(
                context,
                e,
                message: 'There was an issue changing the email address.',
              );
            }
            return;
          }

          if (context.mounted) {
            Navigator.pop(context);
            showDialogAdaptive(
              context: context,
              title: const Text('Email address changed'),
              content: Text(
                'Dont forget to click the link in the email sent to ${fields[0]} to be able to login with this address.',
              ),
              actions: [
                adaptiveDialogButton(
                  context: context,
                  child: Text(context.loc.ok),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<void> logOut(BuildContext context, WidgetRef ref) async {
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
              fireService.logOut();
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

  Future<void> getAllData(BuildContext context, WidgetRef ref) async {
    try {
      await fireService.getAllData(context);
    } catch (e) {
      if (context.mounted) {
        showErrorMessage(context, e);
      }
      return;
    }
  }

  Future<void> deleteAllData(BuildContext context, WidgetRef ref) async {
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
                    await fireService.deleteAllData(password: fields[0]);
                  } catch (e) {
                    if (context.mounted) {
                      showErrorMessage(context, e);
                    }
                    return;
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
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

  Future<void> logIn(BuildContext context, WidgetRef ref) async {
    pushScreen(
      context,
      LoginInputScreen(
        actionName: context.loc.logIn,
        fields: [
          LoginField(
            name: context.loc.email,
            autofillHints: [AutofillHints.email],
          ),
          LoginField(
            name: context.loc.password,
            obscure: true,
            autofillHints: [AutofillHints.password],
          ),
        ],
        bottomChild: FilledButton.tonal(
          onPressed: () {
            resetPassword(context, ref);
          },
          child: const Text('Forgot password'),
        ),
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

          try {
            await fireService.logIn(
              email: fields[0],
              password: fields[1],
            );
          } catch (e) {
            if (context.mounted) {
              Navigator.pop(context);
              showErrorMessage(context, e);
            }
            return;
          }

          if (context.mounted) {
            key.currentState?.changeText(
              context.loc.syncing,
            );
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
              context.loc.loggedInSynced,
            );
            if (onDataSyncSuccess != null) {
              onDataSyncSuccess!();
            }
          }
        },
      ),
    );
  }

  Future<void> register(BuildContext context, WidgetRef ref) async {
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

          try {
            await fireService.createUser(
              email: fields[0],
              password: fields[2],
              nickname: fields[1],
            );
          } catch (e) {
            if (context.mounted) {
              Navigator.pop(context);
              showErrorMessage(context, e);
            }
            return;
          }

          if (context.mounted) {
            key.currentState?.changeText(
              context.loc.syncing,
            );
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
            // TODO
            final user = ref.read(firebaseLoginProvider).value;
            if (user?.emailVerified == false) {
              verifyEmail(context, ref, user!);
            }
          }
        },
      ),
    );
  }

  Future<void> verifyEmail(
    BuildContext context,
    WidgetRef ref,
    User user,
  ) async {
    try {
      await fireService.sendVerification();

      if (context.mounted) {
        showMessage(context, 'Sent');
      }
    } catch (error) {
      if (context.mounted) {
        showErrorMessage(context, error);
      }
      return;
    }

    if (!context.mounted) return;

    showDialogAdaptive(
      dismissible: false,
      context: context,
      title: const Text('Verify email address'),
      content: Text(
        'Please open the link in the email sent to ${user.email} and then tap done here. If you didn\'t receive any email, check your spam folder and try again.',
      ),
      actions: [
        adaptiveDialogButton(
          context: context,
          child: const Text('Send again'),
          onPressed: () async {
            try {
              await fireService.sendVerification();

              if (context.mounted) {
                showMessage(context, 'Sent');
              }
            } catch (error) {
              if (context.mounted) {
                showErrorMessage(context, error);
              }
              return;
            }
          },
        ),
        adaptiveDialogButton(
          isDefaultAction: true,
          context: context,
          child: const Text('Done'),
          onPressed: () async {
            try {
              await fireService.reloadUser();
              if (fireService.needsVerification == false) {
                if (context.mounted) {
                  Navigator.pop(context);
                  showMessage(context, 'Address verified');
                }
              } else {
                if (context.mounted) {
                  showMessage(context, 'Try again');
                }
              }
            } catch (e) {
              if (context.mounted) {
                showErrorMessage(context, e);
              }
              return;
            }
          },
        ),
      ],
    );
  }

  Future<void> resetPassword(
    BuildContext context,
    WidgetRef ref,
  ) async {
    pushScreen(
      context,
      LoginInputScreen(
        actionName: 'Send password reset',
        fields: [
          LoginField(
            name: context.loc.email,
            autofillHints: [AutofillHints.email],
          ),
        ],
        onSubmit: (fields) async {
          try {
            await fireService.resetPassword(fields[0]);

            if (context.mounted) {
              showMessage(context, 'Sent');
            }
          } catch (error) {
            if (context.mounted) {
              showErrorMessage(context, error);
            }
            return;
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final login = ref.watch(firebaseLoginProvider);
    final isLoading = login.isLoading;
    final user = login.value;
    final loggedIn = user != null;

    final nickname = ref.watch(firebaseNicknameProvider);

    // TODO ask user to verify email when app launches

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
        NicknameText(
          isLoading: isLoading,
          radius: 32,
          editNickname: () => editNickname(context, ref),
          user: loggedIn
              ? Member(
                  user.uid,
                  nickname.value ?? context.loc.loading,
                  email: user.email,
                )
              : null,
        ),
        const SizedBox(height: 12),
        if (user?.emailVerified == false)
          SettingTile(
            title: 'Email not verified',
            subtitle: 'Tap to verify',
            isFirst: true,
            isLast: true,
            backgroundColor: context.col.errorContainer,
            foregroundColor: context.col.onErrorContainer,
            onTap: (context) async {
              verifyEmail(context, ref, user!);
            },
          ),
        if (loggedIn) ...[
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      context.col.surfaceContainer,
                    ),
                  ),
                  onPressed: () => changeEmail(context, ref),
                  icon: const Icon(Icons.email_rounded),
                  label: const Text('Change email'),
                ),
              ),
              Expanded(
                child: FilledButton.tonalIcon(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      context.col.surfaceContainer,
                    ),
                  ),
                  onPressed: () => changePassword(context, ref),
                  icon: const Icon(Icons.password_rounded),
                  label: Text(context.loc.changePassword),
                ),
              ),
            ],
          ),
          FilledButton.tonalIcon(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                context.col.surfaceContainer,
              ),
            ),
            onPressed: () => logOut(context, ref),
            icon: const Icon(Icons.logout_rounded),
            label: Text(context.loc.logOut),
          ),
          FilledButton.tonalIcon(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                context.col.surfaceContainer,
              ),
            ),
            onPressed: () => getAllData(context, ref),
            icon: const Icon(Icons.download_rounded),
            label: Text(context.loc.getAllData),
          ),
          const Divider(),
          FilledButton.icon(
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
            onPressed: () => deleteAllData(context, ref),
            icon: const Icon(Icons.delete_forever_rounded),
            label: Text(context.loc.deleteAllData),
          ),
        ],

        if (!loggedIn) ...[
          FilledButton.icon(
            onPressed: () => logIn(context, ref),
            icon: const Icon(Icons.login_rounded),
            label: Text(context.loc.logIn),
          ),
          FilledButton.tonalIcon(
            onPressed: () => register(context, ref),
            icon: const Icon(Icons.login),
            label: Text(context.loc.register),
          ),
        ],
      ],
    );
  }
}
