import 'package:flutter/material.dart';
import 'package:schoolarc/models/exception_model.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/fonts.dart';

class ErrorInfoUI {
  final String text;
  final IconData icon;
  final ExceptionActions? action;
  final Color foregroundColor;
  final Color backgroundColor;

  ErrorInfoUI({
    required this.text,
    required this.icon,
    this.action,
    required this.foregroundColor,
    required this.backgroundColor,
  });
  static ErrorInfoUI fromNull(BuildContext context) {
    return ErrorInfoUI(
      text: context.loc.error,
      icon: Icons.error_outline_rounded,
      foregroundColor: context.col.error,
      backgroundColor: context.col.onError,
    );
  }

  // Factory method to create ErrorInfo from an error
  static ErrorInfoUI fromError(
    BuildContext context,
    Object error, {
    Color? seriousForeground,
    Color? unseriousForeground,
    Color? seriousBackground,
    Color? unseriousBackground,
  }) {
    final col = context.col;
    final loc = context.loc;

    var foreground = seriousForeground ?? col.onErrorContainer;
    var background = seriousBackground ?? col.errorContainer;
    var text = '';
    var icon = Icons.error_outline_rounded;
    ExceptionActions? action;

    switch (error) {
      case NetworkException(:var code, :var originalError):
        switch (code) {
          case .offline:
            text = loc.offline;
            foreground = unseriousForeground ?? col.onSurface;
            background = unseriousBackground ?? col.surface;
            icon = Icons.cloud_off_rounded;
          case .timeout:
            text = loc.timedOut;
            icon = Icons.timer_off_outlined;
          case .serverError:
            text = loc.serverError;
        }
        if (originalError != null) {
          text = originalError.toString();
        }

      case AuthException(:var code, :var exceptionAction):
        action = exceptionAction;
        switch (code) {
          case .noUser:
            icon = Icons.person_off_outlined;
            text = loc.noUserLoggedIn;
          case .loggedOut:
            icon = Icons.person_off_outlined;
            text = loc.loggedOut;
          case .noCanteenId:
            text = loc.noCanteen;
          case .newOldPasswordSame:
            text = loc.samePasswords;
          case .repeatedPasswordNotSame:
            text = loc.notSamePassword;
        }

      case ValidationException(:var code):
        switch (code) {
          case .emptyField:
            text = loc.fillOutAllFields;
          case .invalidCanteenNumber:
            text = loc.invalidCanteenNumber;
          case .invalidCanteenNumberLength:
            text = loc.invalidCanteenNumberLength;
        }

      case GroupException(:var code):
        switch (code) {
          case .cantChangeName:
            icon = Icons.not_interested;
            text = loc.cantChangeGroupName;
          case .cantLeaveYourGroup:
            icon = Icons.group_off_outlined;
            text = loc.cantLeaveYourGroup;
          case .leaveOldGroup:
            foreground = unseriousForeground ?? col.onSurface;
            background = unseriousBackground ?? col.surface;
            icon = Icons.group_off_outlined;
            text = loc.leaveOldGroup;
          case .notMemberOfAnyGroup:
            icon = Icons.group_off_outlined;
            text = loc.notMemberOfAnyGroup;
          case .removedFromGroup:
            icon = Icons.group_off_outlined;
            text = loc.removedFromGroup;
          case .waitingForApproval:
            foreground = unseriousForeground ?? col.onSurface;
            background = unseriousBackground ?? col.surface;
            icon = Icons.timer_outlined;
            text = loc.waitingForApproval;
        }

      case DisabledException(:var code):
        foreground = unseriousForeground ?? col.onSurface;
        background = unseriousBackground ?? col.surface;
        switch (code) {
          case .bakalariDisabled:
            text = loc.bakalariDisabled;
          case .mealsDisabled:
            text = loc.mealsDisabled;
        }

      case ApiException(:var apiError):
        text = apiError;

      default:
        text = error.toString();
    }

    return ErrorInfoUI(
      text: text,
      icon: icon,
      action: action,
      foregroundColor: foreground,
      backgroundColor: background,
    );
  }
}

List<Widget> resolveErrorAction(BuildContext context, ErrorInfoUI info) {
  final col = context.col;
  return [
    if (info.action == ExceptionActions.stravaLogin)
      FilledButton(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(col.errorContainer),
          foregroundColor: WidgetStatePropertyAll(col.onErrorContainer),
        ),
        onPressed: () {
          Navigator.restorablePushNamed(context, '/strava');
        },
        child: Text(context.loc.login),
      ),
    if (info.action == ExceptionActions.bakaLogin)
      FilledButton(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(col.errorContainer),
          foregroundColor: WidgetStatePropertyAll(col.onErrorContainer),
        ),
        onPressed: () {
          Navigator.restorablePushNamed(context, '/bakalari');
        },
        child: Text(context.loc.login),
      ),
    if (info.action == ExceptionActions.cloudsyncLogin)
      FilledButton(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(col.errorContainer),
          foregroundColor: WidgetStatePropertyAll(col.onErrorContainer),
        ),
        onPressed: () {
          Navigator.restorablePushNamed(context, '/cloudsync');
        },
        child: Text(context.loc.login),
      ),
  ];
}

class ErrorTile extends StatelessWidget {
  const ErrorTile({
    super.key,
    this.text,
    required this.error,
    this.actions,
    this.allowActions = true,
    this.padding = const EdgeInsets.all(8),
  });

  final String? text;
  final Object? error;
  final bool allowActions;
  final EdgeInsetsGeometry padding;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final info = error != null
        ? ErrorInfoUI.fromError(context, error!)
        : ErrorInfoUI.fromNull(context);

    return Padding(
      padding: padding,
      child: Row(
        spacing: 12,
        children: [
          Icon(info.icon, color: info.foregroundColor),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (text != null)
                  Text(
                    text ?? '',
                    softWrap: true,
                    style: googleSansFlex(
                      weight: 700,
                      roundness: 100,
                      size: 14,
                      color: info.foregroundColor,
                    ),
                  ),
                if (error != null)
                  Text(
                    info.text,
                    maxLines: 3,
                    style: googleSansFlex(
                      size: 12,
                      color: info.foregroundColor,
                    ),
                  ),
              ],
            ),
          ),
          if (allowActions) ...resolveErrorAction(context, info),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
