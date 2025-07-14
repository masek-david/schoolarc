import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/provider/baka_notifier.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/utils/show_adaptive_dialog.dart';
import 'package:school_manager/widgets/animated_shape.dart';
import 'package:school_manager/widgets/progress_dialog.dart';

class BakaLoginScreen extends ConsumerStatefulWidget {
  const BakaLoginScreen({
    super.key,
    this.showAppbar = true,
  });

  final bool showAppbar;

  @override
  ConsumerState<BakaLoginScreen> createState() => _BakalariScreenState();
}

class _BakalariScreenState extends ConsumerState<BakaLoginScreen> {
  final _schoolController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  late bool keepLoggedIn = settings.get(Setting.bakaKeepLoggedIn);
  bool obscureText = true;
  Object? lastError;

  @override
  void dispose() {
    _schoolController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void onError(dynamic error) {
    showMessage(context, error.toString(), isError: true);
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    final baka = ref.watch(bakaProvider);
    final isLoggedIn = baka.value == true;
    baka.when(
      data: (data) {},
      error: (error, stackTrace) {
        if (lastError != error) {
          lastError = error;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onError(error);
          });
        }
      },
      loading: () {},
    );

    return Scaffold(
      appBar: widget.showAppbar
          ? AppBar(title: Text(context.loc.bakalari))
          : null,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: RefreshIndicator(
          key: refreshIndicatorKey,
          onRefresh: () async {
            ref.read(bakaProvider.notifier).refreshLogin();
          },
          child: ListView(
            children: [
              const SizedBox(height: 8),
              if (isLoggedIn && !baka.isLoading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AnimatedShape.success(
                    text: context.loc.loggedIn,
                    size: 100,
                    primary: colorScheme.primary,
                    isDark: isDark,
                  ),
                ),
              if (baka.isLoading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              TextField(
                enabled: !baka.isLoading,
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
                enabled: !baka.isLoading,
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
                      enabled: !baka.isLoading,
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
                    onChanged: !baka.isLoading
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
                                    onPressed: () =>
                                        Navigator.pop(context, true),
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
                    onPressed: baka.isLoading
                        ? null
                        : () async {
                            refreshIndicatorKey.currentState?.show();
                            ref.read(bakaProvider.notifier).firstLogin(
                                  school: _schoolController.text,
                                  username: _usernameController.text,
                                  password: _passwordController.text,
                                  keepLoggedIn: keepLoggedIn,
                                );
                          },
                    child: Text(context.loc.logIn),
                  ),
                  if (isLoggedIn)
                    OutlinedButton(
                      onPressed: baka.isLoading
                          ? null
                          : () async {
                              refreshIndicatorKey.currentState?.show();
                              ref.read(bakaProvider.notifier).logOut();
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
                                  builder: (context) =>
                                      const ProgressDialog(showProgressNumber: false),
                                );

                                ref
                                    .read(bakaProvider.notifier)
                                    .importTimeTable()
                                    .then(
                                  (value) {
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  },
                                  onError: onError,
                                );
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
      ),
    );
  }
}
