import 'package:flutter/material.dart';
import 'package:school_manager/models/logs/log_model.dart';
import 'package:school_manager/screens/calendar/widgets/text_separator.dart';
import 'package:school_manager/screens/empty_message.dart';
import 'package:school_manager/screens/logs/log_screen.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/utils/send_bug_report.dart';
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
        title: Text(context.loc.logs),
        actions: [
          IconButton(
            onPressed: () {
              showDialogAdaptive(
                context: context,
                title: Text(context.loc.sendReport),
                content: Text(context.loc.reportBugPolicy),
                actions: [
                  adaptiveDialogButton(
                    context: context,
                    child: Text(context.loc.cancel),
                    onPressed: () => Navigator.pop(context),
                  ),
                  adaptiveDialogButton(
                    context: context,
                    child: Text(context.loc.send),
                    isDefaultAction: true,
                    onPressed: () {
                      final message = logs
                          .getRange(0, 118)
                          .map((e) =>
                              '=====   ${e.$2.date}   =====\n${e.$2.log}')
                          .join('\n\n\n')
                          .replaceAll(
                            RegExp(r'^\s*#.*(?:\r?\n)?', multiLine: true),
                            '',
                          );

                      final trimmed = message.length > 18000
                          ? message.substring(0, 18000)
                          : message;

                      Navigator.pop(context);
                      sendBugReport(context, bug: trimmed);
                    },
                  ),
                ],
              );
            },
            icon: const Icon(Icons.bug_report_outlined),
          ),
          IconButton(
            onPressed: () {
              showDialogAdaptive(
                context: context,
                title: Text(context.loc.deleteAllLogs),
                actions: [
                  adaptiveDialogButton(
                    context: context,
                    child: Text(context.loc.cancel),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  adaptiveDialogButton(
                    context: context,
                    isDestructiveAction: true,
                    child: Text(context.loc.delete),
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
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: logsMap.isEmpty
          ? EmptyMessage(
              asset: 'assets/confetti.svg',
              message: context.loc.noLogsFound,
            )
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
                                showDialogAdaptive(
                                  context: context,
                                  title: Text(context.loc.sendReport),
                                  content: Text(context.loc.reportBugPolicy),
                                  actions: [
                                    adaptiveDialogButton(
                                      context: context,
                                      child: Text(context.loc.cancel),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    adaptiveDialogButton(
                                      context: context,
                                      child: Text(context.loc.send),
                                      isDefaultAction: true,
                                      onPressed: () {
                                        Navigator.pop(context);
                                        sendBugReport(context,
                                            bug: logs[index].$2.log);
                                      },
                                    ),
                                  ],
                                );
                              },
                              icon: const Icon(Icons.bug_report_outlined),
                            ),
                            IconButton(
                              onPressed: () {
                                showDialogAdaptive(
                                    context: context,
                                    title: Text(context.loc.deleteLog),
                                    actions: [
                                      adaptiveDialogButton(
                                        context: context,
                                        child: Text(context.loc.cancel),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      adaptiveDialogButton(
                                        context: context,
                                        child: Text(context.loc.delete),
                                        isDestructiveAction: true,
                                        onPressed: () {
                                          Navigator.pop(context);
                                          logsService.delete(logs[index].$1);
                                          setState(() {
                                            logsMap.remove(logs[index].$1);
                                          });
                                        },
                                      ),
                                    ]);
                              },
                              icon: const Icon(Icons.delete_outline),
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
                              icon: const Icon(Icons.keyboard_arrow_right),
                            ),
                          ],
                        ),
                        Text(
                          logs[index].$2.log,
                          maxLines: 3,
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
