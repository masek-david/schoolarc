import 'package:flutter/material.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:schoolarc/features/qr_sharing/data/qr_task_parsing.dart';
import 'package:schoolarc/models/task_model.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/widgets/dialogs/show_my_dialog.dart';

Future<void> showQrShareDialog(
  BuildContext context,
  Task task,
  bool isHomework,
) {
  return showDialog(
    context: context,
    builder: (context) => QrShareDialog(task: task, isHomework: isHomework),
  );
}

class QrShareDialog extends StatefulWidget {
  const QrShareDialog({
    super.key,
    required this.task,
    required this.isHomework,
  });

  final Task task;
  final bool isHomework;

  @override
  State<QrShareDialog> createState() => _QrShareDialogState();
}

class _QrShareDialogState extends State<QrShareDialog> {
  late bool isHomework = widget.isHomework;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.loc.scanQr),
      actions: [
        DialogActionButton(
          text: context.loc.close,
          onPressed: () => Navigator.pop(context),
        ),
      ],
      content: Column(
        mainAxisSize: .min,
        spacing: 16,
        children: [
          SizedBox(
            height: 160,
            child: Center(
              child: PrettyQrView(
                decoration: PrettyQrDecoration(
                  shape: PrettyQrSmoothSymbol(
                    color: context.col.secondary,
                  ),
                ),
                qrImage: QrImage(
                  QrCode.fromData(
                    data: QrParse.toUri(widget.task, isHomework).toString(),
                    errorCorrectLevel: 2,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 56,
            width: 240,
            child: Center(
              child: M3EToggleButtonGroup(
                selectedIndex: isHomework ? 0 : 1,
                onSelectedIndexChanged: (value) {
                  setState(() {
                    isHomework = value == 0;
                  });
                },
                size: .md,
                actions: [
                  M3EToggleButtonGroupAction(label: Text(context.loc.homework(1))),
                  M3EToggleButtonGroupAction(label: Text(context.loc.exams(1))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
