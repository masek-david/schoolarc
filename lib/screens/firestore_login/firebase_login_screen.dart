import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/screens/current_timetable/loading_icon_button.dart';
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
  final emailController =
      TextEditingController(text: firebaseService.userEmail ?? '');
  final passwordController = TextEditingController();
  final displayNameController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    displayNameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: widget.onHide != null ? () => widget.onHide!() : null,
        ),
        title: Text('Firebase'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 8,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    firebaseService.auth.currentUser?.displayName ?? '',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  // TODO complete this screen
                  LoadingIconButton(
                    onTap: () async {
                      final newName = await showDialog<String?>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Change name'),
                            content: TextField(
                              controller: displayNameController,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Close'),
                              ),
                              FilledButton(
                                onPressed: () async {
                                  Navigator.pop(
                                      context, displayNameController.text);
                                },
                                child: Text('Save'),
                              ),
                            ],
                          );
                        },
                      );
                      if (newName != null) {
                        await firebaseService.updateDisplayName(name: newName);
                      }
                    },
                    icon: Icons.edit,
                  ),
                ],
              ),
            ),
            TextField(
              controller: emailController,
              autofillHints: const [
                AutofillHints.email,
                AutofillHints.username
              ],
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(15),
                border: OutlineInputBorder(),
                labelText: 'E-mail',
              ),
            ),
            TextField(
              controller: passwordController,
              autofillHints: const [AutofillHints.password],
              obscureText: true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(15),
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
            OutlinedButton(
              onPressed: () async {
                try {
                  await firebaseService.createUser(
                    email: emailController.text,
                    password: passwordController.text,
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
              child: Text('Register'),
            ),
            OutlinedButton(
              onPressed: () async {
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
                    email: emailController.text,
                    password: passwordController.text,
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
                  showMessage(context, 'Logged in, everything has been synced');
                }
              },
              child: Text('Log in'),
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
