import 'package:flutter/material.dart';

class ExpansionTitle extends StatelessWidget {
  const ExpansionTitle({
    super.key,
    required this.titleText,
    this.titleTextColor,
    this.numberOfItems,
    this.boldText = true,
  });

  final String titleText;
  final Color? titleTextColor;
  final int? numberOfItems;
  final bool boldText;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    Color? containerColor;

    if (titleTextColor != null) {
      final colorScheme = ColorScheme.fromSeed(
        seedColor: titleTextColor!,
        brightness: brightness,
        dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
      );

      containerColor = colorScheme.onPrimary;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titleText,
          style: TextStyle(
            color: titleTextColor,
            fontWeight: boldText ? FontWeight.bold : FontWeight.normal,
            fontSize: boldText ? 14 : 16,
          ),
        ),
        // indicator of number of hw
        if (numberOfItems != null)
          Container(
            height: 22,
            // width: 22,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: containerColor,
              // color: titleTextColor == null
              //     ? Colors.transparent
              //     : titleTextColor!.dynamicLighten(
              //         makeItLighter: !isDark,
              //         amount: 0.30,
              //       ),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(numberOfItems.toString()),
          ),
      ],
    );
  }
}
