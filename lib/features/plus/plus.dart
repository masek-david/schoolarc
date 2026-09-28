import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PlusTheme {
  static Color bg(ColorScheme col) {
    return Colors.amber.harmonizeWith(col.primary);
  }

  static Color fg(ColorScheme col) {
    return const Color.fromARGB(
      255,
      83,
      63,
      2,
    ).harmonizeWith(col.primary);
  }

  static M3EButtonDecoration button(ColorScheme col) {
    return M3EButtonDecoration(
      backgroundColor: WidgetStateColor.fromMap(
        {
          WidgetState.disabled: col.onSurface.withAlpha(26),
          WidgetState.any: bg(col),
        },
      ),
      foregroundColor: WidgetStateColor.fromMap(
        {
          WidgetState.disabled: col.onSurface.withAlpha(97),
          WidgetState.any: fg(col),
        },
      ),
      overlayColor: WidgetStatePropertyAll(col.onErrorContainer.withAlpha(26)),
    );
  }
}

Future<void> initRevenueCat() async {
  await Purchases.setLogLevel(LogLevel.debug);
  if (kIsWeb) return;

  late PurchasesConfiguration configuration;
  if (Platform.isAndroid) {
    configuration = PurchasesConfiguration('test_zQoFWtzBIIcKpXRVgRXjpioXdYt');
  } else if (Platform.isIOS) {
    configuration = PurchasesConfiguration('test_zQoFWtzBIIcKpXRVgRXjpioXdYt');
  }
  await Purchases.configure(configuration);
}

final schoolarcPlusProvider = NotifierProvider(() => SchoolarcPlusProvider());

class SchoolarcPlusProvider extends Notifier<bool?> {
  DateTime? expires;

  @override
  bool? build() {
    Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);

    _load();

    ref.onDispose(() {
      Purchases.removeCustomerInfoUpdateListener(_onCustomerInfoUpdated);
    });

    return null;
  }

  Future<void> refresh() {
    return _load();
  }

  Future<void> _load() async {
    final info = await Purchases.getCustomerInfo();
    _onCustomerInfoUpdated(info);
  }

  void _onCustomerInfoUpdated(CustomerInfo info) {
    state = info.entitlements.active.containsKey('Schoolarc Plus');
    expires = DateTime.tryParse(info.latestExpirationDate ?? '');
    state = false;
  }
}
