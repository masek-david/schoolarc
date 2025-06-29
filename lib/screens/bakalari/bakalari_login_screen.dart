import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/provider/baka_notifier.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/show_adaptive_dialog.dart';
import 'package:school_manager/widgets/animated_star.dart';
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
          WidgetsBinding.instance.addPostFrameCallback(
            (timeStamp) {
              onError(error);
            },
          );
        }
      },
      loading: () {},
    );

    return Scaffold(
      appBar: widget.showAppbar
          ? AppBar(
              title: const Text('Bakaláři'),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: RefreshIndicator(
          onRefresh: () async {
            ref.read(bakaProvider.notifier).refreshLogin();
          },
          child: ListView(
            children: [
              SizedBox(height: 8),
              if (isLoggedIn && !baka.isLoading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AnimatedStar.success(
                    text: 'Logged in',
                    size: 100,
                    primary: colorScheme.primary,
                    isDark: isDark,
                  ),
                ),
              if (baka.isLoading)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              TextField(
                enabled: !baka.isLoading,
                controller: _schoolController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(15),
                  border: OutlineInputBorder(),
                  labelText: 'School web id',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                autofillHints: const [AutofillHints.username],
                enabled: !baka.isLoading,
                controller: _usernameController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(15),
                  border: OutlineInputBorder(),
                  labelText: 'Username',
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
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(15),
                        border: OutlineInputBorder(),
                        labelText: 'Password',
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
                  const Text('Remember me'),
                  Checkbox(
                    value: keepLoggedIn,
                    onChanged: !baka.isLoading
                        ? (value) async {
                            if (!value!) {
                              value = await showDialogAdaptive(
                                context: context,
                                title: Text('Remember me?'),
                                content: Text(
                                    'If you continue, you won\'t be able to view your current timetable and current homeworks.'),
                                actions: [
                                  adaptiveDialogButton(
                                    context: context,
                                    child: Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                  ),
                                  adaptiveDialogButton(
                                    isDestructiveAction: true,
                                    context: context,
                                    child: Text('Continue'),
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
                  )
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
                    child: const Text("Log in"),
                  ),
                  if (isLoggedIn)
                    OutlinedButton(
                      onPressed: baka.isLoading
                          ? null
                          : () async {
                              refreshIndicatorKey.currentState?.show();
                              ref.read(bakaProvider.notifier).logOut();
                            },
                      child: const Text("Log out"),
                    ),
                ],
              ),
              const Divider(),
              OutlinedButton(
                onPressed: isLoggedIn && !baka.isLoading
                    ? () {
                        showDialogAdaptive(
                          context: context,
                          title: const Text('Import timetable and subjects?'),
                          content: const Text(
                            'Importing the timetable will replace your existing timetable. Are you sure?',
                          ),
                          actions: [
                            adaptiveDialogButton(
                              context: context,
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
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
                                      ProgressDialog(showProgressNumber: false),
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
                              child: const Text('Import'),
                            ),
                          ],
                        );
                      }
                    : null,
                child: const Text('Import timetable and subjects'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
