import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/tasks_app.dart';

class FirestoreLoginScreen extends ConsumerStatefulWidget {
  const FirestoreLoginScreen({super.key});

  @override
  ConsumerState<FirestoreLoginScreen> createState() =>
      _FirestoreLoginScreenState();
}

class _FirestoreLoginScreenState extends ConsumerState<FirestoreLoginScreen> {
  final emailController = TextEditingController(text: 'mol.david498@gmail.com');
  final passwordController = TextEditingController(text: 'poipoi123');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
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
            SizedBox(height: 8),
            TextField(
              controller: passwordController,
              autofillHints: const [AutofillHints.password],
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(15),
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
            OutlinedButton(
              onPressed: () async {
                try {
                  await firestoreService.createUser(
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
                try {
                  await firestoreService.logIn(
                    email: emailController.text,
                    password: passwordController.text,
                  );
                } on Object catch (e) {
                  if (context.mounted) {
                    showMessage(context, e.toString(), isError: true);
                  }
                  return;
                }

                try {
                  await syncAllTasks(ref);
                } on Object catch (e) {
                  if (context.mounted) {
                    showMessage(context, e.toString(), isError: true);
                  }
                  return;
                }

                if (context.mounted) {
                  showMessage(context, 'Logged in, everything has been synced');
                }
              },
              child: Text('Log in'),
            ),
            OutlinedButton(
              onPressed: () async {
                try {
                  await firestoreService.logOut();
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
