import 'package:flutter/material.dart';
import 'package:schoolarc/models/exception_model.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

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

  /// If this property is null, then [ListTileThemeData.contentPadding] is used.
  /// If that is also null and [ThemeData.useMaterial3] is true, then a default value of
  /// EdgeInsetsDirectional.only(start: 16.0, end: 24.0) will be used.
  /// Otherwise, a default value of EdgeInsets.symmetric(horizontal: 16.0) will be used.
  final EdgeInsetsGeometry? contentPadding;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context){
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
                      Navigator.restorablePushNamed(context, '/strava');
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
                      Navigator.restorablePushNamed(context, '/bakalari');
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
