import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:schoolarc/m3e/error_button_styles.dart';
import 'package:schoolarc/models/exception_model.dart';
import 'package:schoolarc/models/group_models.dart';
import 'package:schoolarc/provider/bakalari/username_notifier.dart';
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
import 'package:schoolarc/widgets/dialogs/show_my_dialog.dart';

Future<void> verifyEmail(
  BuildContext context,
  WidgetRef ref,
  User user,
) async {
  try {
    await fireService.sendVerification();

    if (context.mounted) {
      showMessage(context, context.loc.sent);
    }
  } catch (error) {
    if (context.mounted) {
      showErrorMessage(context, error);
    }
    return;
  }

  if (!context.mounted) return;

  showMyDialog(
    dismissible: false,
    context: context,
    title: context.loc.verifyEmailAddress,
    content: Text(
      context.loc.emailVerificationOpenLinkInEmail(user.email ?? ''),
    ),
    actions: [
      DialogActionButton(
        text: context.loc.sendAgain,
        onPressed: () async {
          try {
            await fireService.sendVerification();

            if (context.mounted) {
              showMessage(context, context.loc.sent);
            }
          } catch (error) {
            if (context.mounted) {
              showErrorMessage(context, error);
            }
            return;
          }
        },
      ),
      DialogActionButton(
        text: context.loc.done,
        isDefaultAction: true,
        onPressed: () async {
          try {
            await fireService.reloadUser();
            if (fireService.needsVerification == false) {
              if (context.mounted) {
                Navigator.pop(context);
                showMessage(context, context.loc.addressVerified);
              }
            } else {
              if (context.mounted) {
                showMessage(context, context.loc.tryAgain);
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
        actionName: context.loc.changeEmailAddress,
        fields: [
          LoginField(
            name: context.loc.newEmailAddress,
            obscure: false,
            autofillHints: [AutofillHints.email],
          ),
          LoginField(
            name: context.loc.password,
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
                message: context.loc.errorChangingEmail,
              );
            }
            return;
          }

          if (context.mounted) {
            Navigator.pop(context);
            showMyDialog(
              context: context,
              title: context.loc.emailAddressChanged,
              content: Text(
                context.loc.changeEmailDontForgetClickLink(fields[0]),
              ),
              actions: [
                DialogActionButton(
                  text: context.loc.ok,
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
    showMyDialog(
      context: context,
      title: '${context.loc.logOut}?',
      actions: [
        DialogActionButton(
          text: context.loc.cancel,
          onPressed: () => Navigator.pop(context),
        ),
        DialogActionButton(
          text: context.loc.logOut,
          isDestructiveAction: true,
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
          showMyDialog(
            context: context,
            title: context.loc.deleteAllDataTitle,
            content: Text(context.loc.deleteAllDataText),
            actions: [
              DialogActionButton(
                text: context.loc.cancel,
                onPressed: () => Navigator.pop(context),
              ),
              DialogActionButton(
                text: context.loc.delete,
                isDestructiveAction: true,
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
        bottomChild: M3EFilledButton.tonal(
          onPressed: () {
            resetPassword(context, ref);
          },
          child: Text(context.loc.forgotPassword),
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
    if (!settings.get(.devMode)) {
      showMyDialog(
        context: context,
        title: context.loc.cantRegister,
        text: context.loc.cloudSyncInBeta,
        actions: [
          DialogActionButton(
            text: context.loc.ok,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
      return;
    }

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
            initialValue: ref.read(usernameProvider),
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
          User? newUser;

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
            newUser = await fireService.createUser(
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
            if (newUser != null) {
              verifyEmail(context, ref, newUser);
            }
          }
        },
      ),
    );
  }

  Future<void> resetPassword(
    BuildContext context,
    WidgetRef ref,
  ) async {
    pushScreen(
      context,
      LoginInputScreen(
        actionName: context.loc.sendPasswordReset,
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
              showMessage(context, context.loc.sent);
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

    return SettingsScaffold(
      heroTag: 'cloudsync',
      title: context.loc.cloudSync,
      actions: [
        M3EIconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PrivacyPolicy(),
            ),
          ),
          icon: const Icon(Icons.info_outline_rounded),
        ),
      ],
      children: [
        NicknameText(
          isLoading: isLoading,
          radius: 36,
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
            title: context.loc.emailNotVerified,
            subtitle: context.loc.tapToVerify,
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
                child: M3EElevatedButton.icon(
                  onPressed: () => changeEmail(context, ref),
                  icon: const Icon(Icons.email_rounded),
                  label: Text(context.loc.changeEmail),
                ),
              ),
              Expanded(
                child: M3EElevatedButton.icon(
                  onPressed: () => changePassword(context, ref),
                  icon: const Icon(Icons.password_rounded),
                  label: Text(context.loc.changePassword),
                ),
              ),
            ],
          ),
          M3EElevatedButton.icon(
            onPressed: () => logOut(context, ref),
            icon: const Icon(Icons.logout_rounded),
            label: Text(context.loc.logOut),
          ),
          M3EElevatedButton.icon(
            onPressed: () => getAllData(context, ref),
            icon: const Icon(Icons.download_rounded),
            label: Text(context.loc.getAllData),
          ),
          const Divider(),
          M3EOutlinedButton.icon(
            decoration: ErrorButtonStyle.outlined(context.col),
            onPressed: () => deleteAllData(context, ref),
            icon: const Icon(Icons.delete_forever_rounded),
            label: Text(context.loc.deleteAllData),
          ),
        ],
        if (!loggedIn)
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: M3EFilledButton.icon(
                  shape: .square,
                  size: .md,
                  onPressed: () => logIn(context, ref),
                  icon: const Icon(Icons.login_rounded),
                  label: Text(context.loc.logIn),
                ),
              ),
              Expanded(
                child: M3EFilledButton.tonalIcon(
                  size: .md,
                  shape: .square,
                  onPressed: () => register(context, ref),
                  icon: const Icon(Icons.login_rounded),
                  label: Text(context.loc.register),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
