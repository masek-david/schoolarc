import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class TitleWithCount extends StatelessWidget {
  const TitleWithCount({
    super.key,
    required this.text,
    this.textColor,
    this.count,
    this.countContainerColor,
  });

  final String text;
  final Color? textColor;
  final Color? countContainerColor;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: context.txt.labelLarge!.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        // indicator of number of hw
        if (count != null)
          Container(
            height: 22,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: countContainerColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Text(count.toString()),
            ),
          ),
      ],
    );
  }
}
