import 'package:flutter/material.dart';
import 'package:school_manager/models/exception_model.dart';
import 'package:school_manager/screens/bakalari/bakalari_login_screen.dart';
import 'package:school_manager/screens/strava_cz/strava_settings_screen.dart';
import 'package:school_manager/tasks_app.dart';

class ErrorTile extends StatelessWidget {
  const ErrorTile({
    super.key,
    this.text,
    required this.error,
    this.actions,
  });

  final String? text;
  final Object? error;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    ExceptionActions? action;

    if (error.runtimeType == ServiceException) {
      ServiceException exception = error as ServiceException;
      action = exception.action;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (text != null)
                  Text(
                    text ?? '',
                    softWrap: true,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                const SizedBox(height: 10),
                Text(
                  error.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (action == ExceptionActions.stravaLogin)
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(scheme.errorContainer),
              foregroundColor: WidgetStatePropertyAll(scheme.onErrorContainer),
            ),
            onPressed: () {
              navigatorKey.currentState?.push(MaterialPageRoute(
                builder: (context) {
                  return const StravaSettingsScreen();
                },
              ));
            },
            child: Text(
              'Login',
            ),
          ),
        if (action == ExceptionActions.bakaLogin)
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(scheme.errorContainer),
              foregroundColor: WidgetStatePropertyAll(scheme.onErrorContainer),
            ),
            onPressed: () {
              navigatorKey.currentState?.push(MaterialPageRoute(
                builder: (context) {
                  return const BakaLoginScreen();
                },
              ));
            },
            child: Text(
              'Login',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        if (actions != null) ...actions!
      ],
    );
  }
}
