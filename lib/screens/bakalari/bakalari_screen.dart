import 'package:flutter/material.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/show_adaptive_dialog.dart';
import 'package:school_manager/widgets/animated_star.dart';

class BakalariScreen extends StatefulWidget {
  const BakalariScreen({
    super.key,
    this.showAppbar = true,
  });

  final bool showAppbar;

  @override
  State<BakalariScreen> createState() => _BakalariScreenState();
}

class _BakalariScreenState extends State<BakalariScreen> {
  final _schoolController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  bool isLoggedIn = false;
  bool isLoading = false;
  late bool keepLoggedIn = settings.get(Setting.bakaKeepLoggedIn);
  bool obscureText = true;

  @override
  void dispose() {
    _schoolController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      isLoading = true;
    });

    loadLoginInfo();

    bakaService.refreshLogin().then((value) {
      onLoginSuccess();
    }, onError: onError);
  }

  void loadLoginInfo() async {
    _schoolController.text = await bakaService.schoolName;
    _usernameController.text = await bakaService.username;
  }

  void onLoginSuccess() {
    setState(() {
      isLoggedIn = true;
      isLoading = false;
    });
  }

  void onError(dynamic error) {
    setState(() {
      isLoading = false;
    });
    showMessage(error.toString(), isError: true);
  }

  void showMessage(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor:
              isError ? Theme.of(context).colorScheme.errorContainer : null,
          content: Text(
            message,
            style: TextStyle(
              color: isError
                  ? Theme.of(context).colorScheme.onErrorContainer
                  : null,
            ),
          ),
        ),
      );
    }
  }

  bool canLogin() {
    return _schoolController.text != '' &&
        _passwordController.text != '' &&
        _usernameController.text != '';
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

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
            setState(() {
              isLoggedIn = false;
            });
            bakaService.refreshLogin().then(
              (value) {
                onLoginSuccess();
              },
              onError: onError,
            );
          },
          child: ListView(
            children: [
              if (isLoggedIn)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AnimatedStar.success(
                    text: 'Logged in',
                    size: 100,
                    primary: colorScheme.primary,
                    isDark: isDark,
                  ),
                ),
              if (isLoading) const Center(child: CircularProgressIndicator()),
              if (isLoading) const SizedBox(height: 20),
              TextField(
                enabled: !isLoading,
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
                enabled: !isLoading,
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
                      enabled: !isLoading,
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
                    onChanged: !isLoading
                        ? (value) {
                            setState(() {
                              keepLoggedIn = value!;
                            });
                            settings.save(Setting.bakaKeepLoggedIn, value!);
                          }
                        : null,
                  )
                ],
              ),
              FilledButton(
                onPressed: isLoading && !canLogin()
                    ? null
                    : () async {
                        refreshIndicatorKey.currentState?.show();
                        setState(() {
                          isLoading = true;
                          isLoggedIn = false;
                        });

                        try {
                          await bakaService.firstLogin(
                            school: _schoolController.text,
                            username: _usernameController.text,
                            password: _passwordController.text,
                            keepLoggedIn: keepLoggedIn,
                          );
                          onLoginSuccess();
                        } catch (e) {
                          onError(e);
                        }
                      },
                child: const Text("Log in"),
              ),
              const Divider(),
              OutlinedButton(
                onPressed: isLoggedIn && !isLoading
                    ? () {
                        showDialogAdaptive(
                          context: context,
                          title: const Text('Import timetable?'),
                          content: const Text(
                            'Importing the timetable will replace your existing timetable. Are you sure?',
                          ),
                          actions: [
                            adaptiveDialogButton(
                              context: context,
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                            adaptiveDialogButton(
                              context: context,
                              onPressed: () async {
                                Navigator.pop(context);
                                setState(() {
                                  isLoading = true;
                                });

                                bakaService.importTimeTable().then((value) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }, onError: onError);
                              },
                              child: const Text('Import'),
                            ),
                          ],
                        );
                      }
                    : null,
                child: const Text('Import timetable'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
