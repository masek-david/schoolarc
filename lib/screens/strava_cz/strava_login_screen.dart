// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/provider/debug_mode_notifier.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/utils/show_adaptive_dialog.dart';

class StravaLoginScreen extends ConsumerStatefulWidget {
  const StravaLoginScreen({super.key});

  @override
  ConsumerState<StravaLoginScreen> createState() => _StravaLoginScreenState();
}

class _StravaLoginScreenState extends ConsumerState<StravaLoginScreen> {
  final _canteenController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool canLogIn = settings.get(Setting.allowStravaLogin);

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
    final loc = context.loc;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.loginToStrava),
        actions: [
          IconButton(
            onPressed: () => showDialogAdaptive(
              context: context,
              title: Text(context.loc.secureLogin),
              content: Text(context.loc.secureLoginInfo),
              actions: [
                adaptiveDialogButton(
                  context: context,
                  child: Text(context.loc.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ListView(
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: _canteenController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(15),
                      border: const OutlineInputBorder(),
                      labelText: loc.schoolCanteenId,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialogAdaptive(
                      context: context,
                      title: Text(loc.schoolCanteenId),
                      content: Text(loc.schoolCanteenIdDescription),
                      actions: [
                        adaptiveDialogButton(
                          context: context,
                          child: Text(loc.close),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    );
                  },
                  icon: const Icon(Icons.info_outline),
                ),
              ],
            ),
            if (ref.watch(debugModeProvider) || kDebugMode)
              SettingTile.withSwitch(
                title: loc.allowStravaLogin,
                onChanged: (value) {
                  setState(() {
                    settings.save(Setting.allowStravaLogin, value);
                    canLogIn = value;
                  });
                },
                value: canLogIn,
              ),
            if (canLogIn)
              TextField(
                controller: _usernameController,
                autofillHints: const [AutofillHints.username],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(15),
                  border: const OutlineInputBorder(),
                  labelText: loc.username,
                ),
              ),
            if (canLogIn) const SizedBox(height: 12),
            if (canLogIn)
              TextField(
                controller: _passwordController,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(15),
                  border: const OutlineInputBorder(),
                  labelText: loc.password,
                ),
              ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                try {
                  await stravaService.registerUser(
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

                showMessage(context, loc.loggedIn);
              },
              child: Text(loc.logIn),
            ),
          ],
        ),
      ),
    );
  }
}
