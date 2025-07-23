// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/provider/settings_notifiers.dart';
import 'package:school_manager/provider/strava_login_notifier.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/utils/globals.dart';
import 'package:school_manager/utils/show_adaptive_dialog.dart';
import 'package:school_manager/widgets/error_tile.dart';
import 'package:school_manager/widgets/login_status_icon.dart';

class StravaLoginScreen extends ConsumerStatefulWidget {
  const StravaLoginScreen({super.key});

  @override
  ConsumerState<StravaLoginScreen> createState() => _StravaLoginScreenState();
}

class _StravaLoginScreenState extends ConsumerState<StravaLoginScreen> {
  final _canteenController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool allowLogin = settings.get(Setting.allowStravaLogin);
  bool obscure = true;

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
    final useMeals = ref.watch(useMealsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.loginToStrava),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(stravaLoginProvider.notifier).refreshLogin();
            },
            icon: const Icon(Icons.refresh),
          ),
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
            SettingTile.withSwitch(
              value: useMeals,
              onChanged: (value) =>
                  ref.read(useMealsProvider.notifier).set(value),
              title: context.loc.useStravaCz,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            ),
            const Divider(),
            ref.watch(stravaLoginProvider).when(
                  data: (data) => SettingTile(
                    title: data ? context.loc.loggedIn : context.loc.loggedOut,
                    leading: data
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const LoggedOutIcon(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  error: (error, stackTrace) => ErrorTile(
                    error: error,
                    text: context.loc.errorLoggingIn,
                    allowActions: false,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    enabled: useMeals,
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
                enabled: useMeals,
                contentPadding: const EdgeInsets.all(0),
                title: loc.allowStravaLogin,
                onChanged: (value) {
                  setState(() {
                    settings.save(Setting.allowStravaLogin, value);
                    allowLogin = value;
                  });
                },
                value: allowLogin,
              ),
            if (allowLogin)
              TextField(
                enabled: useMeals,
                controller: _usernameController,
                autofillHints: const [AutofillHints.username],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(15),
                  border: const OutlineInputBorder(),
                  labelText: loc.username,
                ),
              ),
            if (allowLogin) const SizedBox(height: 12),
            if (allowLogin)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      enabled: useMeals,
                      controller: _passwordController,
                      obscureText: obscure,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(15),
                        border: const OutlineInputBorder(),
                        labelText: loc.password,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      obscure = !obscure;
                    }),
                    icon: Icon(
                      obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: useMeals
                  ? () {
                      ref.read(stravaLoginProvider.notifier).register(
                            canteenCode: _canteenController.text,
                            username:
                                allowLogin ? _usernameController.text : '',
                            password:
                                allowLogin ? _passwordController.text : '',
                          );
                    }
                  : null,
              child: Text(loc.logIn),
            ),
          ],
        ),
      ),
    );
  }
}
