import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/provider/baka_login_notifier.dart';
import 'package:school_manager/provider/settings_notifiers.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/utils/show_adaptive_dialog.dart';
import 'package:school_manager/widgets/error_tile.dart';
import 'package:school_manager/widgets/progress_dialog.dart';

class BakaLoginScreen extends ConsumerStatefulWidget {
  const BakaLoginScreen({super.key});

  @override
  ConsumerState<BakaLoginScreen> createState() => _BakalariScreenState();
}

class _BakalariScreenState extends ConsumerState<BakaLoginScreen> {
  final _schoolController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  late bool keepLoggedIn = settings.get(Setting.bakaKeepLoggedIn);
  bool obscureText = true;
  Object? lastError;

  @override
  void initState() {
    super.initState();

    setToInitialValues();
  }

  void setToInitialValues() async {
    _schoolController.text = await bakaService.schoolName;
    _usernameController.text = await bakaService.username;
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
    final isLoggedIn = baka.value == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.bakalari),
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
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ListView(
          children: [
            SettingTile.withSwitch(
              value: useBaka,
              onChanged: (value) =>
                  ref.read(useBakaProvider.notifier).set(value),
              title: context.loc.useBakalari,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            ),
            const Divider(),
            baka.when(
              data: (data) => SettingTile(
                title: data ? context.loc.loggedIn : context.loc.loggedOut,
                leading: data
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              error: (error, stackTrace) {
                return ErrorTile(
                  error: error,
                  text: context.loc.errorLoggingIn,
                  allowActions: false,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(height: 12),
            TextField(
              enabled: !baka.isLoading && useBaka,
              controller: _schoolController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(15),
                border: const OutlineInputBorder(),
                labelText: context.loc.schoolWebId,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              autofillHints: const [AutofillHints.username],
              enabled: !baka.isLoading && useBaka,
              controller: _usernameController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(15),
                border: const OutlineInputBorder(),
                labelText: context.loc.username,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    autofillHints: const [AutofillHints.password],
                    enabled: !baka.isLoading && useBaka,
                    controller: _passwordController,
                    obscureText: obscureText,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(15),
                      border: const OutlineInputBorder(),
                      labelText: context.loc.password,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(context.loc.rememberMe),
                Checkbox(
                  value: keepLoggedIn,
                  onChanged: !baka.isLoading && useBaka
                      ? (value) async {
                          if (!value!) {
                            value = await showDialogAdaptive(
                              context: context,
                              title: Text(context.loc.rememberMeTitle),
                              content: Text(context.loc.rememberMeWarning),
                              actions: [
                                adaptiveDialogButton(
                                  context: context,
                                  child: Text(context.loc.cancel),
                                  onPressed: () => Navigator.pop(context, true),
                                ),
                                adaptiveDialogButton(
                                  isDestructiveAction: true,
                                  context: context,
                                  child: Text(context.loc.continueAction),
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
              ],
            ),
            Row(
              spacing: 16,
              children: [
                FilledButton(
                  onPressed: !baka.isLoading && useBaka
                      ? () async {
                          ref.read(bakaLoginProvider.notifier).firstLogin(
                                school: _schoolController.text,
                                username: _usernameController.text,
                                password: _passwordController.text,
                                keepLoggedIn: keepLoggedIn,
                              );
                        }
                      : null,
                  child: Text(context.loc.logIn),
                ),
                if (isLoggedIn)
                  OutlinedButton(
                    onPressed: baka.isLoading
                        ? null
                        : () async {
                            ref.read(bakaLoginProvider.notifier).logOut();
                          },
                    child: Text(context.loc.logOut),
                  ),
              ],
            ),
            const Divider(),
            OutlinedButton(
              onPressed: isLoggedIn && !baka.isLoading
                  ? () {
                      showDialogAdaptive(
                        context: context,
                        title: Text(context.loc.importTimetableTitle),
                        content: Text(context.loc.importTimetableWarning),
                        actions: [
                          adaptiveDialogButton(
                            context: context,
                            onPressed: () => Navigator.pop(context),
                            child: Text(context.loc.cancel),
                          ),
                          adaptiveDialogButton(
                            context: context,
                            isDestructiveAction: true,
                            onPressed: () async {
                              Navigator.pop(context);

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const ProgressDialog(
                                  showProgressNumber: false,
                                ),
                              );

                              try {
                                await bakaService.importTimeTable(ref);
                              } catch (e) {
                                if (context.mounted) {
                                  showMessage(context, e.toString(),
                                      isError: true);
                                }
                              }
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            child: Text(context.loc.import),
                          ),
                        ],
                      );
                    }
                  : null,
              child: Text(context.loc.importTimetable),
            ),
          ],
        ),
      ),
    );
  }
}
