import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/screens/firebase_login/firebase_login_page.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/utils/show_adaptive_dialog.dart';
import 'package:school_manager/widgets/progress_dialog.dart';

class FirebaseLoginScreen extends ConsumerStatefulWidget {
  const FirebaseLoginScreen({
    super.key,
    this.onHide,
  });

  final void Function()? onHide;

  @override
  ConsumerState<FirebaseLoginScreen> createState() =>
      _FirestoreLoginScreenState();
}

class _FirestoreLoginScreenState extends ConsumerState<FirebaseLoginScreen> {
  bool useFirebase = settings.get(Setting.useFirebase);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: widget.onHide != null ? () => widget.onHide!() : null,
        ),
        title: Text(context.loc.cloudSync),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 8,
          children: [
            SettingTile.withSwitch(
              title: context.loc.useCloudSync,
              icon: Icons.cloud_outlined,
              value: useFirebase,
              onChanged: (value) {
                settings.save(Setting.useFirebase, value);
                setState(() {
                  useFirebase = value;
                });
              },
            ),
            OutlinedButton(
              onPressed: () async {
                navigatorKey.currentState?.push(MaterialPageRoute(
                  builder: (context) => FirebaseLoginPage(
                    actionName: context.loc.register,
                    onSubmit: (email, password) async {
                      final key = GlobalKey<ProgressDialogState>();

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => ProgressDialog(
                          key: key,
                          goal: 0,
                          initialText: context.loc.loggingIn,
                          showProgressNumber: false,
                        ),
                      );

                      try {
                        await firebaseService.createUser(
                          email: email,
                          password: password,
                        );
                      } on Object catch (e) {
                        if (context.mounted) {
                          showMessage(context, e.toString(), isError: true);
                        }

                        if (context.mounted) Navigator.pop(context);
                        return;
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
                        showMessage(context, context.loc.registeredSuccessfully);
                      }
                    },
                  ),
                ));
              },
              child: Text(context.loc.register),
            ),
            OutlinedButton(
              onPressed: () async {
                navigatorKey.currentState?.push(MaterialPageRoute(
                  builder: (context) => FirebaseLoginPage(
                    actionName: context.loc.logIn,
                    initialEmail: firebaseService.userEmail,
                    onSubmit: (email, password) async {
                      final key = GlobalKey<ProgressDialogState>();

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => ProgressDialog(
                          key: key,
                          goal: 0,
                          initialText: context.loc.loggingIn,
                          showProgressNumber: false,
                        ),
                      );

                      try {
                        await firebaseService.logIn(
                          email: email,
                          password: password,
                        );
                      } on Object catch (e) {
                        if (context.mounted) {
                          showMessage(context, e.toString(), isError: true);
                        }

                        if (context.mounted) Navigator.pop(context);
                        return;
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
                        showMessage(context, context.loc.loggedInSynced);
                      }
                    },
                  ),
                ));
              },
              child: Text(context.loc.logIn),
            ),
            OutlinedButton(
              onPressed: () async {
                navigatorKey.currentState?.push(MaterialPageRoute(
                  builder: (context) => FirebaseLoginPage(
                    actionName: context.loc.changePassword,
                    emailHint: context.loc.oldPassword,
                    onSubmit: (email, password) async {
                      try {
                        await firebaseService.changePassword(email, password);
                      } on Object catch (e) {
                        if (context.mounted) {
                          showMessage(context, e.toString(), isError: true);
                        }
                        return;
                      }

                      if (context.mounted) {
                        showMessage(
                            context, context.loc.passwordChangedSuccessfully);
                      }
                    },
                  ),
                ));
              },
              child: Text(context.loc.changePassword),
            ),
            OutlinedButton(
              onPressed: () async {
                try {
                  await firebaseService.logOut();
                } on Object catch (e) {
                  if (context.mounted) {
                    showMessage(context, e.toString(), isError: true);
                  }
                  return;
                }

                if (context.mounted) {
                  showMessage(context, context.loc.loggedOut);
                }
              },
              child: Text(context.loc.logOut),
            ),
            OutlinedButton(
              onPressed: () async {
                try {
                  await firebaseService.getAllData();
                } on Object catch (e) {
                  if (context.mounted) {
                    showMessage(context, e.toString(), isError: true);
                  }
                  return;
                }
              },
              child: Text(context.loc.getAllData),
            ),
            const Divider(),
            FilledButton(
              style: ButtonStyle(
                backgroundColor:
                    WidgetStatePropertyAll(context.col.errorContainer),
                foregroundColor:
                    WidgetStatePropertyAll(context.col.onErrorContainer),
              ),
              onPressed: () async {
                navigatorKey.currentState?.push(MaterialPageRoute(
                  builder: (context) => FirebaseLoginPage(
                    actionName: context.loc.deleteAllData,
                    emailHint: context.loc.password,
                    askForEmail: false,
                    onSubmit: (email, password) async {
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
                                await firebaseService.deleteAllData(password);
                              } on Object catch (e) {
                                if (context.mounted) {
                                  showMessage(context, e.toString(),
                                      isError: true);
                                }
                                return;
                              }

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
                ));
              },
              child: Text(context.loc.deleteAllData),
            ),
          ],
        ),
      ),
    );
  }
}
