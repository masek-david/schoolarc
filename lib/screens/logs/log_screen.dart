
import 'package:flutter/material.dart';
import 'package:school_manager/models/logs/log_model.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key, required this.log});

  final Log log;

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  double fontSize = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.log.date.format(),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                if (fontSize > 1) {
                  fontSize--;
                }
              });
            },
            icon: const Icon(
              Icons.remove,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                fontSize++;
              });
            },
            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: SingleChildScrollView(
          child: SelectableText(
            widget.log.log,
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: 'Monospace',
            ),
          ),
        ),
      ),
    );
  }
}
