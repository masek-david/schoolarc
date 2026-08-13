import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:schoolarc/m3e/expressive_loading/expressive_loading_indicator.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class ProgressDialog extends StatefulWidget {
  const ProgressDialog({
    super.key,
    this.goal = 0,
    this.showProgressNumber = true,
    this.initialText,
    this.useHaptics = false,
  });

  final int goal;
  final bool showProgressNumber;
  final String? initialText;
  final bool useHaptics;

  @override
  State<ProgressDialog> createState() => ProgressDialogState();
}

class ProgressDialogState extends State<ProgressDialog> {
  int _progress = 0;
  late String _text = widget.initialText ?? context.loc.importing;

  void addProgress({int progressToAdd = 1}) {
    setState(() {
      _progress += progressToAdd;
    });
  }

  void changeText(String newText) {
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
        actions: kDebugMode
            ? [
                M3EOutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('pop(debug)'),
                ),
              ]
            : null,
        content: Stack(
          alignment: Alignment.center,
          children: [
            widget.goal == 0
                ? ExpressiveLoadingIndicator.big(
                    useHaptics: widget.useHaptics,
                  )
                : M3ECircularProgressIndicator(
                    value: _progress / widget.goal,
                    size: 140,
                  ),
            if (widget.showProgressNumber) Text('$_progress / ${widget.goal}'),
          ],
        ),
      ),
    );
  }
}
