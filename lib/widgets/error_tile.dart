import 'package:flutter/material.dart';
import 'package:school_manager/models/exception_model.dart';
import 'package:school_manager/screens/bakalari/bakalari_login_screen.dart';
import 'package:school_manager/screens/strava_cz/strava_login_screen.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';

class ErrorTile extends StatelessWidget {
  const ErrorTile({
    super.key,
    this.text,
    required this.error,
    this.actions,
    this.allowActions = true,
    this.contentPadding,
  });

  final String? text;
  final Object? error;
  final bool allowActions;
  final EdgeInsetsGeometry? contentPadding;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    ExceptionActions? action;

    if (error.runtimeType == ServiceException) {
      ServiceException exception = error as ServiceException;
      action = exception.action;
    }

    if (error.runtimeType == BakaLoginException) {
      action = ExceptionActions.bakaLogin;
    }

    return ListTile(
      contentPadding: contentPadding,
      leading: const Icon(Icons.error, color: Colors.red),
      title: Text(
        text ?? '',
        softWrap: true,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      subtitle: Text(
        error.toString(),
        maxLines: 5,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: allowActions
            ? [
                if (action == ExceptionActions.stravaLogin)
                  FilledButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(scheme.errorContainer),
                      foregroundColor:
                          WidgetStatePropertyAll(scheme.onErrorContainer),
                    ),
                    onPressed: () {
                      navigatorKey.currentState?.push(MaterialPageRoute(
                        builder: (context) {
                          return const StravaLoginScreen();
                        },
                      ));
                    },
                    child: Text(
                      context.loc.login,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (action == ExceptionActions.bakaLogin)
                  FilledButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(scheme.errorContainer),
                      foregroundColor:
                          WidgetStatePropertyAll(scheme.onErrorContainer),
                    ),
                    onPressed: () {
                      navigatorKey.currentState?.push(MaterialPageRoute(
                        builder: (context) {
                          return const BakaLoginScreen();
                        },
                      ));
                    },
                    child: Text(
                      context.loc.login,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (actions != null) ...actions!
              ]
            : [],
      ),
    );
  }
}
