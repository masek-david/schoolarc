import 'package:flutter/material.dart';

class ProgressDialog extends StatefulWidget {
  const ProgressDialog({super.key, required this.goal});

  final int goal;

  @override
  State<ProgressDialog> createState() => ProgressDialogState();
}

class ProgressDialogState extends State<ProgressDialog> {
  int progress = 0;

  void addProgress({int progressToAdd = 1}) {
    setState(() {
      progress += progressToAdd;
    });
  }

  void close() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Center(child: Text('Importing')),
        content: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: progress / widget.goal,
              constraints: BoxConstraints(minWidth: 140, minHeight: 140),
              strokeWidth: 14,
            ),
            Text('$progress / ${widget.goal}')
          ],
        ),
      ),
    );
  }
}
