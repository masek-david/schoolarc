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
          widget.log.date.formattedDate(),
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
            icon: Icon(
              Icons.remove,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                fontSize++;
              });
            },
            icon: Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: SingleChildScrollView(
          child: Text(
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
