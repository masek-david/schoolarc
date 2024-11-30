import 'package:flutter/material.dart';
import 'package:school_manager/utils/extensions/color_extension.dart';

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
    bool isDark = Theme.of(context).brightness == Brightness.dark;

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
              color: titleTextColor == null
                  ? Colors.transparent
                  : titleTextColor!.dynamicLighten(
                      makeItLighter: !isDark,
                      amount: 0.35,
                    ),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(numberOfItems.toString()),
          ),
      ],
    );
  }
}
