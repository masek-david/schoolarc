import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

extension FilledButtonStyles on FilledButton {
  // static ButtonStyle error(BuildContext context) {
  //   final scheme = context.col;
  //   return FilledButton.styleFrom(
  //     backgroundColor: scheme.error,
  //     foregroundColor: scheme.onError,
  //   );
  // }

  static ButtonStyle surface(BuildContext context) {
    return FilledButton.styleFrom(
      backgroundColor: context.col.surfaceContainer,
      foregroundColor: context.col.onPrimaryContainer,
    );
  }
}

extension OutlinedButtonStyles on OutlinedButton {
  static ButtonStyle errorTonal(BuildContext context) {
    final scheme = context.col;
    return OutlinedButton.styleFrom(
      side: BorderSide(color: scheme.errorContainer),
      foregroundColor: scheme.error,
    );
  }
}
