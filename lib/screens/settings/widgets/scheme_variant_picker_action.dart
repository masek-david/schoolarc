import 'package:flutter/material.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/string_extension.dart';

class SchemeVariantPickerAction extends StatefulWidget {
  const SchemeVariantPickerAction({
    super.key,
    required this.onChanged,
    required this.initialScheme,
  });

  final void Function(int schemeVariantInt) onChanged;
  final int initialScheme;

  @override
  State<SchemeVariantPickerAction> createState() =>
      _SchemeVariantPickerActionState();
}

class _SchemeVariantPickerActionState extends State<SchemeVariantPickerAction> {
  static final schemeVariants = DynamicSchemeVariant.values;
  final List<GlobalKey<TooltipState>> keys = List.generate(
    schemeVariants.length,
    (index) => GlobalKey(),
  );

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

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
              final isHighlighted = index == widget.initialScheme;

              final brightness = Theme.of(context).brightness;

              final scheme = ColorScheme.fromSeed(
                seedColor: Color(settings.get(Setting.themeColorValue)),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(1000),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          widget.onChanged(index);
                          keys[index].currentState?.ensureTooltipVisible();
                        },
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 0,
                                        color: isDark
                                            ? scheme.primary
                                            : scheme.primaryContainer,
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
                                            border: Border.all(
                                              width: 0,
                                              color: isDark
                                                  ? scheme.secondary
                                                  : scheme.secondaryContainer,
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
                                            border: Border.all(
                                              width: 0,
                                              color: isDark
                                                  ? scheme.tertiary
                                                  : scheme.tertiaryContainer,
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
                            if (isHighlighted)
                              Center(
                                child: Icon(
                                  Icons.check,
                                  shadows: <Shadow>[
                                    Shadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onInverseSurface,
                                      blurRadius: 10,
                                    )
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
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
