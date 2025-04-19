import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProgressDialog extends StatefulWidget {
  const ProgressDialog({
    super.key,
    required this.goal,
    this.showProgressNumber = true,
    this.initialText = 'Importing',
  });

  final int goal;
  final bool showProgressNumber;
  final String initialText;

  @override
  State<ProgressDialog> createState() => ProgressDialogState();
}

class ProgressDialogState extends State<ProgressDialog> {
  int _progress = 0;
  late String _text = widget.initialText;

  void addProgress({int progressToAdd = 1}) {
    setState(() {
      _progress += progressToAdd;
    });
  }

  void changeText(String newText){
    setState(() {
      _text = newText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: kDebugMode,
      child: AlertDialog(
        title: Center(child: Text(_text)),
        content: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: widget.goal != 0 ? _progress / widget.goal : null,
              constraints: BoxConstraints(minWidth: 140, minHeight: 140),
              strokeWidth: 14,
            ),
            if (widget.showProgressNumber) Text('$_progress / ${widget.goal}')
          ],
        ),
      ),
    );
  }
}
