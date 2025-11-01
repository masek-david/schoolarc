import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/task_functions.dart';

void pickAction(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            BigButton(
              onPressed: () {
                Navigator.pop(context);
                addNewHw(context);
              },
              isFirst: true,
              child: Text(context.loc.addNewHomework),
            ),
            BigButton(
              onPressed: () {
                Navigator.pop(context);
                addNewExam(context);
              },
              isLast: true,
              child: Text(context.loc.addNewExam),
            ),
          ],
        ),
      ),
    ),
  );
}

class BigButton extends StatelessWidget {
  const BigButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isFirst = false,
    this.isLast = false,
  });

  final void Function()? onPressed;
  final Widget child;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.col.primaryContainer,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(isFirst ? 18 : 4),
            bottom: Radius.circular(isLast ? 18 : 4),
          ),
        ),
        child: Center(
          child: DefaultTextStyle(
            style: TextStyle(
              color: context.col.onPrimaryContainer,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
