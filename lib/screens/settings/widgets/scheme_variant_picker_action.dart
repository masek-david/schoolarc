import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/m3e/buttons/raw_button_m3e.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/string_extension.dart';
import 'package:schoolarc/utils/globals.dart';

class SchemeVariantPickerAction extends ConsumerStatefulWidget {
  const SchemeVariantPickerAction({super.key});

  @override
  ConsumerState<SchemeVariantPickerAction> createState() =>
      _SchemeVariantPickerActionState();
}

class _SchemeVariantPickerActionState
    extends ConsumerState<SchemeVariantPickerAction> {
  static const schemeVariants = DynamicSchemeVariant.values;
  // for tooltips
  final List<GlobalKey<TooltipState>> keys = List.generate(
    schemeVariants.length,
    (index) => GlobalKey(),
  );

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final schemeIndex = ref.watch(themeDynamicSchemeVariantProvider);
    final color = Color(ref.watch(themeColorValueProvider));

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(
            schemeVariants.length,
            (index) {
              final schemeVariant = schemeVariants[index];
              final isSelected = index == schemeIndex;

              final brightness = Theme.of(context).brightness;

              final scheme = ColorScheme.fromSeed(
                seedColor: color,
                brightness: brightness,
                dynamicSchemeVariant: schemeVariant,
              );

              final size = 60.0;

              return Tooltip(
                message: schemeVariant.name.camelToSentence(),
                preferBelow: false,
                triggerMode: TooltipTriggerMode.manual,
                key: keys[index],
                // TODO check that the colors dont have space between them on release
                child: RawButtonM3E(
                  selected: isSelected,
                  outlineWidth: null,
                  outlineColor: null,
                  iconSpacing: 0,
                  onPressed: () {
                    vibrate.medium();
                    vibrate.medium();
                    ref
                        .read(
                          themeDynamicSchemeVariantProvider.notifier,
                        )
                        .set(index);
                    keys[index].currentState?.ensureTooltipVisible();
                  },
                  backgroundColor: const WidgetStateColor.fromMap({
                    WidgetState.any: Colors.transparent,
                  }),
                  foregroundColor: WidgetStateColor.fromMap({
                    WidgetState.any: context.col.onSurface,
                  }),
                  elevation: const WidgetStateProperty.fromMap({
                    WidgetState.any: 1,
                  }),
                  width: size,
                  height: size,
                  iconSize: 40,
                  radius: WidgetStateProperty.fromMap({
                    WidgetState.pressed: .circular(12),
                    WidgetState.selected: .circular(16),
                    WidgetState.any: .circular(size / 2),
                  }),
                  padding: 0,
                  fontSize: 0,
                  icon: null,
                  child: Stack(
                    alignment: .center,
                    children: [
                      Align(
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                color: isDark
                                    ? scheme.primary
                                    : scheme.primaryContainer,
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      color: isDark
                                          ? scheme.secondary
                                          : scheme.secondaryContainer,
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      color: isDark
                                          ? scheme.tertiary
                                          : scheme.tertiaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      isSelected
                          ? Icon(
                              Icons.check_rounded,
                              size: 40,
                              shadows: kElevationToShadow[4],
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
