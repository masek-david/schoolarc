import 'package:flutter/material.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class WeekdaysRow extends StatelessWidget {
  const WeekdaysRow({
    super.key,
    this.textColor,
  });

  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        7,
        (index) => Expanded(
          child: Text(
            textAlign: .center,
            style: context.txt.labelLarge!.copyWith(color: textColor),
            Date(
              2026,
              3,
              2 + index,
            ).format('EEE', context.locale.languageCode),
          ),
        ),
      ),
    );
  }
}
