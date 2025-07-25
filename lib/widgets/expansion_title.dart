import 'package:flutter/material.dart';

class TitleWithCount extends StatelessWidget {
  const TitleWithCount({
    super.key,
    required this.text,
    this.textColor,
    this.count,
    this.bold = true,
    this.countContainerColor,
  });

  final String text;
  final Color? textColor;
  final Color? countContainerColor;
  final int? count;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontSize: bold ? 14 : 16,
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
