import 'package:flutter/material.dart';
import 'package:school_manager/services/bakalari/baka_service.dart';
import 'package:school_manager/services/settings_database.dart';
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
  final _service = BakaService();
  final _settings = SettingsDatabase();

  final _schoolController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  bool isLoggedIn = false;
  bool isLoading = false;
  late bool keepLoggedIn = _settings.get(Setting.bakaKeepLoggedIn);
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

    // loadLogin();

    _service.refreshLogin().then(
          (value) => evaluateResponse(value, shouldShowMessage: true),
        );
  }

  void loadLogin() async {
    _schoolController.text = await _service.schoolName;
    _usernameController.text = await _service.username;
  }

  void evaluateResponse(
    BakaResponse response, {
    bool shouldShowMessage = true,
    String successResponse = 'Logged in successfully',
  }) {
    if (response.isSuccess) {
      if (shouldShowMessage) {
        showMessage(successResponse);
      }
      if (mounted) {
        setState(() {
          isLoading = false;
          isLoggedIn = true;
        });
      }
    } else {
      if (shouldShowMessage) {
        showMessage(response.error ?? '', isError: true);
      }
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              isLoggedIn = false;
            });
            await _service.refreshLogin().then(
                  evaluateResponse,
                );
          },
          child: ListView(
            children: [
              if (isLoggedIn)
                AnimatedStar.success(
                  text: 'Logged in',
                  size: 100,
                  primary: colorScheme.primary,
                  isDark: isDark,
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
                            _settings.save(Setting.bakaKeepLoggedIn, value!);
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

                        _service
                            .firstLogin(
                              school: _schoolController.text,
                              username: _usernameController.text,
                              password: _passwordController.text,
                              keepLoggedIn: keepLoggedIn,
                            )
                            .then(evaluateResponse);
                      },
                child: const Text("Log in"),
              ),
              const Divider(),
              OutlinedButton(
                onPressed: isLoggedIn && !isLoading
                    ? () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Import timetable?'),
                              content: const Text(
                                'Importing the timetable will replace your existing timetable. Are you sure?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      isLoading = true;
                                    });
                                    _service.importTimeTable().then(
                                          (response) => evaluateResponse(
                                            response,
                                            successResponse:
                                                'Imported timetable successfully',
                                          ),
                                        );
                                  },
                                  child: const Text('Import'),
                                ),
                              ],
                            );
                          },
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
