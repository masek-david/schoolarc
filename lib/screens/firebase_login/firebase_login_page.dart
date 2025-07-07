import 'package:flutter/material.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';

class FirebaseLoginPage extends StatefulWidget {
  const FirebaseLoginPage({
    super.key,
    required this.actionName,
    this.initialEmail,
    this.askForEmail = true,
    required this.onSubmit,
    this.emailHint,
  });

  final String actionName;
  final String? initialEmail;
  final String? emailHint;
  final bool askForEmail;
  final void Function(String email, String password) onSubmit;

  @override
  State<FirebaseLoginPage> createState() => _FirebaseLoginPageState();
}

class _FirebaseLoginPageState extends State<FirebaseLoginPage> {
  late final emailController =
      TextEditingController(text: widget.initialEmail ?? '');
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.actionName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 8,
          children: [
            if (widget.askForEmail)
              TextField(
                controller: emailController,
                autofillHints: const [
                  AutofillHints.email,
                  AutofillHints.username
                ],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(15),
                  border: const OutlineInputBorder(),
                  labelText: widget.emailHint ?? context.loc.email,
                ),
              ),
            TextField(
              controller: passwordController,
              autofillHints: const [AutofillHints.password],
              obscureText: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(15),
                border: const OutlineInputBorder(),
                labelText: context.loc.password,
              ),
            ),
            FilledButton(
              onPressed: () => widget.onSubmit(
                  emailController.text, passwordController.text),
              child: Text(widget.actionName),
            ),
          ],
        ),
      ),
    );
  }
}
