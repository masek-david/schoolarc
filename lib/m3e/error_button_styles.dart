import 'package:flutter/material.dart';
import 'package:m3e_widgets/m3e_widgets.dart';

class ErrorButtonStyle {
  static M3EButtonDecoration filled(ColorScheme col) {
    return M3EButtonDecoration(
      backgroundColor: WidgetStateColor.fromMap(
        {
          WidgetState.disabled: col.onSurface.withAlpha(26),
          WidgetState.any: col.errorContainer,
        },
      ),
      foregroundColor: WidgetStateColor.fromMap(
        {
          WidgetState.disabled: col.onSurface.withAlpha(97),
          WidgetState.any: col.onErrorContainer,
        },
      ),
      overlayColor: WidgetStatePropertyAll(col.onErrorContainer.withAlpha(26)),
    );
  }

  static M3EButtonDecoration text(ColorScheme col) {
    return M3EButtonDecoration(
      foregroundColor: WidgetStateColor.fromMap(
        {
          WidgetState.disabled: col.onSurface.withAlpha(97),
          WidgetState.any: col.error,
        },
      ),
      overlayColor: WidgetStatePropertyAll(col.error.withAlpha(26)),
    );
  }

  static M3EButtonDecoration outlined(ColorScheme col) {
    return M3EButtonDecoration(
      foregroundColor: WidgetStateColor.fromMap(
        {
          WidgetState.disabled: col.onSurface.withAlpha(97),
          WidgetState.any: col.error,
        },
      ),
      side: WidgetStatePropertyAll(
        BorderSide(color: col.errorContainer),
      ),
      overlayColor: WidgetStatePropertyAll(col.error.withAlpha(26)),
    );
  }
}
