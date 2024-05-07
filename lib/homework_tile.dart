import 'package:flutter/material.dart';

class HomeworkTile extends StatelessWidget {
  const HomeworkTile({
    super.key,
    required this.hwText,
    required this.hwDeadline,
    required this.hwSubject,
  });

  final String hwText;
  final String hwDeadline;
  final String hwSubject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(255, 205, 190, 230),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(hwSubject),
          Text(hwText),
          Text(hwDeadline),
          IconButton(onPressed: () {}, icon: const Icon(Icons.check_box_outline_blank_outlined))
        ],
      ),
    );
  }
}
