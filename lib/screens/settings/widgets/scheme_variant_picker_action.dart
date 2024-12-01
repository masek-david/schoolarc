import 'package:flutter/material.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/tasks_app.dart';

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
  @override
  Widget build(BuildContext context) {
    const schemeVariants = DynamicSchemeVariant.values;

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

              return SizedBox(
                width: 60,
                height: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(1000),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        widget.onChanged(index);
                      },
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Expanded(
                                child: Container(
                                  color: scheme.primary,
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        color: scheme.secondary,
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        color: scheme.tertiary,
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
              );
            },
          ),
        ),
      ),
    );
  }
}
