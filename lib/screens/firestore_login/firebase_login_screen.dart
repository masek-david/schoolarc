import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/screens/firestore_login/firebase_login_page.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/tasks_app.dart';
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
        title: Text('Cloud sync'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 8,
          children: [
            SettingTile.withSwitch(
              title: 'Use cloud sync',
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
                    actionName: 'Register',
                    onSubmit: (email, password) async {
                      try {
                        await firebaseService.createUser(
                          email: email,
                          password: password,
                        );
                      } on Object catch (e) {
                        if (context.mounted) {
                          showMessage(context, e.toString(), isError: true);
                        }
                        return;
                      }

                      if (context.mounted) {
                        showMessage(context, 'Registered successfuly');
                      }
                    },
                  ),
                ));
              },
              child: Text('Register'),
            ),
            OutlinedButton(
              onPressed: () async {
                navigatorKey.currentState?.push(MaterialPageRoute(
                  builder: (context) => FirebaseLoginPage(
                    actionName: 'Log in',
                    initialEmail: firebaseService.userEmail,
                    onSubmit: (email, password) async {
                      final key = GlobalKey<ProgressDialogState>();

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => ProgressDialog(
                          key: key,
                          goal: 0,
                          initialText: 'Logging in',
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

                      key.currentState?.changeText('Syncing');
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
                        showMessage(
                            context, 'Logged in, everything has been synced');
                      }
                    },
                  ),
                ));
              },
              child: Text('Log in'),
            ),
            OutlinedButton(
              onPressed: () async {
                navigatorKey.currentState?.push(MaterialPageRoute(
                  builder: (context) => FirebaseLoginPage(
                    actionName: 'Change password',
                    askForEmail: false,
                    onSubmit: (email, password) async {
                      try {
                        await firebaseService.changePassword(password);
                      } on Object catch (e) {
                        if (context.mounted) {
                          showMessage(context, e.toString(), isError: true);
                        }
                        return;
                      }

                      if (context.mounted) {
                        showMessage(context, 'Password changed successfuly');
                      }
                    },
                  ),
                ));
              },
              child: Text('Change password'),
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
                  showMessage(context, 'Signed out');
                }
              },
              child: Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
