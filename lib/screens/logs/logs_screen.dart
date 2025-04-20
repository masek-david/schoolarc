import 'package:flutter/material.dart';
import 'package:school_manager/models/logs/log_model.dart';
import 'package:school_manager/screens/calendar/widgets/text_separator.dart';
import 'package:school_manager/screens/logs/log.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/show_adaptive_dialog.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final logsMap = logsService.getAllLogs();

  @override
  Widget build(BuildContext context) {
    List<(int, Log)> logs = [];
    logsMap.forEach(
      (key, value) {
        logs.add((key, value));
      },
    );
    logs.sort((a, b) => b.$2.date.compareTo(a.$2.date));

    return Scaffold(
      appBar: AppBar(
        title: Text('Logs'),
        actions: [
          IconButton(
            onPressed: () {
              showDialogAdaptive(
                context: context,
                title: Text('Delete all logs?'),
                actions: [
                  adaptiveDialogButton(
                    context: context,
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  adaptiveDialogButton(
                    context: context,
                    isDestructiveAction: true,
                    child: Text('Delete'),
                    onPressed: () {
                      Navigator.pop(context);
                      logsService.deleteAll();
                      setState(() {
                        logsMap.clear();
                      });
                    },
                  ),
                ],
              );
            },
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: logsMap.isEmpty
          ? Center(child: Text('No logs found'))
          : ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextSeparator(
                          text: logs[index].$2.date.toString(),
                          actions: [
                            IconButton(
                              onPressed: () {
                                logsService.delete(logs[index].$1);
                                setState(() {
                                  logsMap.remove(logs[index].$1);
                                });
                              },
                              icon: Icon(Icons.delete),
                            ),
                            IconButton(
                              onPressed: () {
                                navigatorKey.currentState?.push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return LogScreen(log: logs[index].$2);
                                    },
                                  ),
                                );
                              },
                              icon: Icon(Icons.keyboard_arrow_right),
                            ),
                          ],
                        ),
                        Text(
                          logs[index].$2.log,
                          maxLines: 5,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
