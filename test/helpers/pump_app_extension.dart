import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schoolarc/l10n/app_localizations.dart';

extension BetterTester on WidgetTester {
  Future<void> pumpApp(Widget child, {List<Override>? overrides}) {
    return pumpWidget(
      ProviderScope(
        overrides: overrides ?? [],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Material(child: child),
        ),
      ),
    );
  }

  Future<BuildContext> pumpAppWithContext(
    Widget? child, {
    List<Override>? overrides,
  }) async {
    await pumpApp(Container(child: child), overrides: overrides);
    return element(find.byType(Container).first);
  }
}
