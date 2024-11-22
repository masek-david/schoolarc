// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:school_manager/data/settings_database.dart';
import 'package:school_manager/tasks_app.dart';

class StravaSettingsScreen extends StatefulWidget {
  const StravaSettingsScreen({super.key});

  @override
  State<StravaSettingsScreen> createState() => _StravaSettingsScreenState();
}

class _StravaSettingsScreenState extends State<StravaSettingsScreen> {
  final _canteenController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool canLogIn = settings.get(Setting.showDebugInfo);

  @override
  void dispose() {
    _canteenController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> getInfoFromStorage() async {
    _canteenController.text = await stravaService.getCanteenCode;
    _usernameController.text = await stravaService.getUsername;
  }

  @override
  void initState() {
    super.initState();

    getInfoFromStorage();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ListView(
          children: [
            const SizedBox(height: 4),
            TextField(
              keyboardType: TextInputType.number,
              controller: _canteenController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(15),
                border: OutlineInputBorder(),
                labelText: 'School canteen id',
              ),
            ),
            if (settings.get(Setting.showDebugInfo))
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Allow logging in (experimental)'),
                  Switch(
                    value: canLogIn,
                    onChanged: (value) {
                      setState(() {
                        canLogIn = value;
                      });
                    },
                  ),
                ],
              ),
            if (canLogIn) const SizedBox(height: 12),
            if (canLogIn)
              TextField(
                controller: _usernameController,
                autofillHints: const [AutofillHints.username],
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(15),
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                ),
              ),
            if (canLogIn) const SizedBox(height: 12),
            if (canLogIn)
              TextField(
                controller: _passwordController,
                autofillHints: const [AutofillHints.password],
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(15),
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                try {
                  stravaService.registerUser(
                    canteenCode: _canteenController.text,
                    username: _usernameController.text,
                    password: _passwordController.text,
                  );
                } on Exception catch (error) {
                  showMessage(context, error.toString(), isError: true);
                  return;
                }

                try {
                  if (canLogIn) {
                    await stravaService.login();
                  } else {
                    await stravaService.getMealsNoLogin();
                  }
                } on Exception catch (error) {
                  showMessage(context, error.toString(), isError: true);
                  return;
                }

                showMessage(context, 'Logged in');
              },
              child: const Text('Log in'),
            ),
          ],
        ),
      ),
    );
  }
}
