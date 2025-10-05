import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/strava/strava_login_notifier.dart';
import 'package:schoolarc/screens/settings/settings_scaffold.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/dialogs/show_adaptive_dialog.dart';
import 'package:schoolarc/widgets/login_status_icon.dart';
import 'package:schoolarc/widgets/tiles/error_tile.dart';

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
  String? loggedInSubtitle;

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

    if (_usernameController.text != '') {
      setState(() {
        loggedInSubtitle = _usernameController.text;
      });
    } else if (_canteenController.text != '') {
      setState(() {
        loggedInSubtitle = '${context.loc.canteen} ${_canteenController.text}';
      });
    }
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

    final login = ref.watch(stravaLoginProvider);
    final isLoading = login.isLoading;
    final error = login.error;
    final loggedIn = login.value == true;

    return SettingsScaffold(
      heroTag: 'strava',
      title: loc.stravaCz,
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
      children: [
        SettingTile.withSwitch(
          highlighted: true,
          value: useMeals,
          onChanged: (value) => ref.read(useMealsProvider.notifier).set(value),
          title: context.loc.useStravaCz,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        const Divider(),
        if (error == null && !isLoading)
          SettingTile(
            isLast: true,
            isFirst: true,
            title: loggedIn ? context.loc.loggedIn : context.loc.loggedOut,
            subtitle: loggedIn ? loggedInSubtitle : null,
            leading: loggedIn
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const LoggedOutIcon(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        if (error != null)
          ErrorTile(
            error: error,
            text: context.loc.errorLoggingIn,
            allowActions: false,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        if (isLoading) const Center(child: CircularProgressIndicator()),
        const SizedBox(height: 12),
        if (loggedIn == false)
          Row(
            children: [
              Expanded(
                child: TextField(
                  enabled: useMeals,
                  keyboardType: TextInputType.number,
                  controller: _canteenController,
                  decoration: InputDecoration(labelText: loc.schoolCanteenId),
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
        (!loggedIn && (ref.watch(debugModeProvider) || kDebugMode))
            ? SettingTile.withSwitch(
                isLast: true,
                isFirst: true,
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
              )
            : const SizedBox(height: 8),
        if (allowLogin && loggedIn == false)
          AutofillGroup(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  enabled: useMeals,
                  controller: _usernameController,
                  autofillHints: const [AutofillHints.username],
                  decoration: InputDecoration(labelText: loc.username),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        enabled: useMeals,
                        controller: _passwordController,
                        obscureText: obscure,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(labelText: loc.password),
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
              ],
            ),
          ),
        const SizedBox(height: 8),
        if (loggedIn == false)
          FilledButton(
            onPressed: useMeals
                ? () {
                    ref
                        .read(stravaLoginProvider.notifier)
                        .register(
                          canteenCode: _canteenController.text,
                          username: allowLogin ? _usernameController.text : '',
                          password: allowLogin ? _passwordController.text : '',
                        )
                        .then((value) => getInfoFromStorage());
                  }
                : null,
            child: Text(loc.logIn),
          ),
        if (loggedIn == true)
          OutlinedButton(
            onPressed: useMeals
                ? () {
                    _canteenController.clear();
                    _passwordController.clear();
                    _usernameController.clear();
                    ref.read(stravaLoginProvider.notifier).logOut();
                  }
                : null,
            child: Text(loc.logOut),
          ),
      ],
    );
  }
}
