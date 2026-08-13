import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/m3e/expressive_loading/expressive_loading_indicator.dart';
import 'package:schoolarc/provider/bakalari/baka_login_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/settings/settings_scaffold.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/ago_text.dart';
import 'package:schoolarc/widgets/dialogs/progress_dialog.dart';
import 'package:schoolarc/widgets/dialogs/show_my_dialog.dart';
import 'package:schoolarc/widgets/login_status_icon.dart';
import 'package:schoolarc/widgets/tiles/error_tile.dart';

class BakaLoginScreen extends ConsumerStatefulWidget {
  const BakaLoginScreen({
    super.key,
    this.askToImportTimetableOnLogin = false,
  });

  final bool askToImportTimetableOnLogin;

  @override
  ConsumerState<BakaLoginScreen> createState() => _BakalariScreenState();
}

class _BakalariScreenState extends ConsumerState<BakaLoginScreen> {
  final _schoolController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  late bool keepLoggedIn = settings.get(Setting.bakaKeepLoggedIn);
  bool obscureText = true;
  String? subtitle;
  bool shapeShown = true;

  void askToImportTimetable() {
    if (!mounted) return;
    showMyDialog(
      context: context,
      title: context.loc.importTimetableTitle,
      text: context.loc.importTimetableWarning,
      actions: [
        DialogActionButton(
          onPressed: () => Navigator.pop(context),
          text: context.loc.cancel,
        ),
        DialogActionButton(
          isDestructiveAction: true,
          onPressed: () async {
            Navigator.pop(context);

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => ProgressDialog(
                useHaptics: ref.read(themeExpressiveHapticsProvider),
                showProgressNumber: false,
              ),
            );

            try {
              await bakaService.importTimeTable(ref);
            } catch (e) {
              vibrate.error();
              if (mounted) {
                showErrorMessage(context, e);
                Navigator.pop(context);
              }
              return;
            }
            if (mounted) {
              vibrate.success();
              Navigator.pop(context);
              showMessage(context, context.loc.success);
            }
          },
          text: context.loc.import,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    setToInitialValues();
  }

  void setToInitialValues() async {
    _schoolController.text = await bakaService.schoolName;
    _usernameController.text = await bakaService.username;
    if (_usernameController.text != '') {
      setState(() {
        subtitle = _usernameController.text;
      });
    }
  }

  @override
  void dispose() {
    _schoolController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final useBaka = ref.watch(useBakaProvider);

    final baka = ref.watch(bakaLoginProvider);
    final error = baka.error;
    final isLoading = baka.isLoading;
    final isLoggedIn = baka.value == true;

    final devMode = ref.watch(devModeProvider);

    return SettingsScaffold(
      heroTag: 'bakalari',
      title: context.loc.bakalari,
      actions: [
        M3EIconButton(
          onPressed: () {
            ref.read(bakaLoginProvider.notifier).refreshLogin();
          },
          icon: const Icon(Icons.refresh_rounded),
        ),
        M3EIconButton(
          onPressed: () => showMyDialog(
            context: context,
            title: context.loc.secureLogin,
            text: context.loc.secureLoginInfo,
            actions: [
              DialogActionButton(
                text: context.loc.close,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          icon: const Icon(Icons.info_outline_rounded),
        ),
      ],
      children: [
        SettingTile.withSwitch(
          highlighted: true,
          value: useBaka,
          onChanged: (value) => ref.read(useBakaProvider.notifier).set(value),
          title: context.loc.useBakalari,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        if (error == null && !isLoading)
          SettingTile(
            trailing: devMode ? AgoText(stream: bakaLoginExpirationProvider) : null,
            isLast: true,
            isFirst: true,
            title: isLoggedIn ? context.loc.loggedIn : context.loc.loggedOut,
            subtitle: subtitle,
            leading: isLoggedIn
                ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                : const FilledIcon(Icons.logout_rounded, color: Colors.yellow),
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ExpressiveLoadingIndicator.big(
          shown: isLoading,
          useHaptics: ref.read(themeExpressiveHapticsProvider),
        ),
        if (error != null && !isLoading)
          ErrorTile(
            error: error,
            text: context.loc.errorLoggingIn,
            allowActions: false,
          ),
        if (!isLoggedIn)
          TextField(
            enabled: !baka.isLoading && useBaka,
            controller: _schoolController,
            decoration: InputDecoration(labelText: context.loc.schoolWebId),
          ),
        if (!isLoggedIn) const SizedBox(height: 8),
        if (!isLoggedIn)
          AutofillGroup(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  autofillHints: const [AutofillHints.username],
                  enabled: !baka.isLoading && useBaka,
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: context.loc.username,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        autofillHints: const [AutofillHints.password],
                        enabled: !baka.isLoading && useBaka,
                        controller: _passwordController,
                        obscureText: obscureText,
                        decoration: InputDecoration(
                          labelText: context.loc.password,
                        ),
                      ),
                    ),
                    ExcludeFocus(
                      child: M3EIconButton(
                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                        icon: Icon(
                          obscureText
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        if (!isLoggedIn)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(context.loc.rememberMe),
              ExcludeFocus(
                child: Checkbox(
                  value: keepLoggedIn,
                  onChanged: !baka.isLoading && useBaka
                      ? (value) async {
                          if (!value!) {
                            value = await showMyDialog(
                              context: context,
                              title: context.loc.rememberMeTitle,
                              text: context.loc.rememberMeWarning,
                              actions: [
                                DialogActionButton(
                                  text: context.loc.cancel,
                                  onPressed: () => Navigator.pop(context, true),
                                ),
                                DialogActionButton(
                                  isDestructiveAction: true,
                                  text: context.loc.continueAction,
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                ),
                              ],
                            );
                          }

                          setState(() {
                            keepLoggedIn = value!;
                          });
                          settings.save(Setting.bakaKeepLoggedIn, value);
                        }
                      : null,
                ),
              ),
            ],
          ),
        if (!isLoggedIn)
          M3EFilledButton.icon(
            icon: const Icon(Icons.login_rounded),
            size: .md,
            onPressed: !baka.isLoading && useBaka
                ? () async {
                    vibrate.medium();
                    final result = await ref
                        .read(bakaLoginProvider.notifier)
                        .firstLogin(
                          school: _schoolController.text,
                          username: _usernameController.text,
                          password: _passwordController.text,
                          keepLoggedIn: keepLoggedIn,
                        );

                    if (result) {
                      vibrate.success();
                      if (widget.askToImportTimetableOnLogin) {
                        askToImportTimetable();
                      }
                    } else {
                      vibrate.error();
                    }
                  }
                : null,
            label: Text(context.loc.logIn),
          ),
        if (isLoggedIn)
          M3EFilledButton.tonalIcon(
            onPressed: !isLoading ? askToImportTimetable : null,
            icon: const Icon(Icons.download_rounded),
            label: Text(context.loc.importTimetable),
          ),
        if (isLoggedIn) const Divider(),
        if (isLoggedIn)
          M3EElevatedButton.icon(
            icon: const Icon(Icons.logout_rounded),
            onPressed: baka.isLoading
                ? null
                : () async {
                    final result = await ref
                        .read(bakaLoginProvider.notifier)
                        .logOut();

                    if (result) {
                      vibrate.success();
                    } else {
                      vibrate.error();
                    }
                  },
            label: Text(context.loc.logOut),
          ),
      ],
    );
  }
}
