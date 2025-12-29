import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
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
              final isHighlighted = index == schemeIndex;

              final brightness = Theme.of(context).brightness;

              final scheme = ColorScheme.fromSeed(
                seedColor: color,
                brightness: brightness,
                dynamicSchemeVariant: schemeVariant,
              );

              return Tooltip(
                message: schemeVariant.name.camelToSentence(),
                preferBelow: false,
                triggerMode: TooltipTriggerMode.manual,
                key: keys[index],
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(100),
                                  topRight: Radius.circular(100),
                                ),
                                color: isDark
                                    ? scheme.primary
                                    : scheme.primaryContainer,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(100),
                                      ),
                                      color: isDark
                                          ? scheme.secondary
                                          : scheme.secondaryContainer,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        bottomRight: Radius.circular(100),
                                      ),
                                      color: isDark
                                          ? scheme.tertiary
                                          : scheme.tertiaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(1000),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            vibrate.medium();
                            ref
                                .read(
                                  themeDynamicSchemeVariantProvider.notifier,
                                )
                                .set(index);
                            keys[index].currentState?.ensureTooltipVisible();
                          },
                          onTapDown: (details) {
                            keys[index].currentState?.ensureTooltipVisible();
                          },
                        ),
                      ),
                      if (isHighlighted)
                        Center(
                          child: Icon(
                            Icons.check,
                            shadows: <Shadow>[
                              Shadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onInverseSurface,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
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
