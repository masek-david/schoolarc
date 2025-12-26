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
    this.padding = const EdgeInsets.all(8),
  });

  final String? text;
  final Object? error;
  final bool allowActions;
  final EdgeInsetsGeometry padding;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final col = context.col;
    final loc = context.loc;

    var color = context.col.error;
    var errorText = '';
    var icon = Icons.error_outline_rounded;
    ExceptionActions? action;

    switch (error) {
      case NetworkException(:var code, :var originalError):
        switch (code) {
          case .offline:
            errorText = loc.offline;
            color = col.onSurface;
            icon = Icons.cloud_off_rounded;
          case .timeout:
            errorText = loc.timedOut;
            icon = Icons.timer_off_outlined;
          case .serverError:
            errorText = loc.serverError;
        }
        if (originalError != null) {
          errorText = originalError.toString();
        }

      case AuthException(:var code, :var exceptionAction):
        action = exceptionAction;
        switch (code) {
          case .noUser:
            icon = Icons.person_off_outlined;
            errorText = loc.noUserLoggedIn;
          case .loggedOut:
            icon = Icons.person_off_outlined;
            errorText = loc.loggedOut;
          case .noCanteenId:
            errorText = loc.noCanteen;
        }

      case ValidationException(:var code):
        switch (code) {
          case .emptyField:
            errorText = loc.fillOutAllFields;
          case .invalidCanteenNumber:
            errorText = loc.invalidCanteenNumber;
          case .invalidCanteenNumberLength:
            errorText = loc.invalidCanteenNumberLength;
        }

      case GroupException(:var code):
        switch (code) {
          case .cantChangeName:
            icon = Icons.not_interested;
            errorText = loc.cantChangeGroupName;
          case .cantLeaveYourGroup:
            icon = Icons.group_off_outlined;
            errorText = loc.cantLeaveYourGroup;
          case .leaveOldGroup:
            color = col.onSurface;
            icon = Icons.group_off_outlined;
            errorText = loc.leaveOldGroup;
          case .notMemberOfAnyGroup:
            icon = Icons.group_off_outlined;
            errorText = loc.notMemberOfAnyGroup;
          case .removedFromGroup:
            icon = Icons.group_off_outlined;
            errorText = loc.removedFromGroup;
          case .waitingForApproval:
            color = col.onSurface;
            icon = Icons.timer_outlined;
            errorText = loc.waitingForApproval;
        }

      case DisabledException(:var code):
        color = col.onSurface;
        switch (code) {
          case .bakalariDisabled:
            errorText = loc.bakalariDisabled;
          case .mealsDisabled:
            errorText = loc.mealsDisabled;
        }

      case ApiException(:var apiError):
        errorText = apiError;

      default:
        errorText = error.toString();
    }

    return Padding(
      padding: padding,
      child: Row(
        spacing: 12,
        children: [
          Icon(icon, color: color),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (text != null)
                  Text(
                    text ?? '',
                    softWrap: true,
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                if (error != null)
                  Text(errorText, maxLines: 3, style: TextStyle(color: color)),
              ],
            ),
          ),
          if (allowActions && action == ExceptionActions.stravaLogin)
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
          if (allowActions && action == ExceptionActions.bakaLogin)
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
          if (allowActions && action == ExceptionActions.cloudsyncLogin)
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
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
