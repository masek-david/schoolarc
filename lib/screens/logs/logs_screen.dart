import 'package:flutter/material.dart';
import 'package:schoolarc/m3e/buttons/icon_button_m3e.dart';
import 'package:schoolarc/models/logs/log_model.dart';
import 'package:schoolarc/screens/logs/log_screen.dart';
import 'package:schoolarc/utils/contact_dev_dialog.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/dialogs/empty_message.dart';
import 'package:schoolarc/widgets/dialogs/show_my_dialog.dart';
import 'package:schoolarc/widgets/text_actions.dart';

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
          IconButtonM3E(
            onPressed: () {
              showMyDialog(
                context: context,
                title: context.loc.sendAllReports,
                text: context.loc.reportBugPolicy,
                actions: [
                  DialogActionButton(
                    text: context.loc.cancel,
                    onPressed: () => Navigator.pop(context),
                  ),
                  DialogActionButton(
                    text: context.loc.send,
                    isDefaultAction: true,
                    onPressed: () {
                      final message = logs
                          .getRange(0, 118)
                          .map(
                            (e) => '=====   ${e.$2.date}   =====\n${e.$2.log}',
                          )
                          .join('\n\n\n')
                          .replaceAll(
                            RegExp(r'^\s*#.*(?:\r?\n)?', multiLine: true),
                            '',
                          );

                      final trimmed = message.length > 18000
                          ? message.substring(0, 18000)
                          : message;

                      Navigator.pop(context);
                      emailBugReport(context, bug: trimmed);
                    },
                  ),
                ],
              );
            },
            icon: const Icon(Icons.bug_report_outlined),
          ),
          IconButtonM3E(
            onPressed: () {
              showMyDialog(
                context: context,
                title: context.loc.deleteAllLogs,
                actions: [
                  DialogActionButton(
                    text: context.loc.cancel,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  DialogActionButton(
                    text: context.loc.delete,
                    isDestructiveAction: true,
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
                        TextActions(
                          text: logs[index].$2.date.toString(),
                          actions: [
                            IconButtonM3E.tonal(
                              width: .narrow,
                              onPressed: () {
                                showMyDialog(
                                  context: context,
                                  title: context.loc.sendReport,
                                  text: context.loc.reportBugPolicy,
                                  actions: [
                                    DialogActionButton(
                                      text: context.loc.cancel,
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    DialogActionButton(
                                      text: context.loc.send,
                                      isDefaultAction: true,
                                      onPressed: () {
                                        Navigator.pop(context);
                                        emailBugReport(
                                          context,
                                          bug: logs[index].$2.log,
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                              icon: const Icon(Icons.bug_report_outlined),
                            ),
                            IconButtonM3E.tonal(
                              width: .narrow,
                              onPressed: () {
                                showMyDialog(
                                  context: context,
                                  title: context.loc.deleteLog,
                                  actions: [
                                    DialogActionButton(
                                      text: context.loc.cancel,
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    DialogActionButton(
                                      text: context.loc.delete,
                                      isDestructiveAction: true,
                                      onPressed: () {
                                        Navigator.pop(context);
                                        logsService.delete(logs[index].$1);
                                        setState(() {
                                          logsMap.remove(logs[index].$1);
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                              icon: const Icon(Icons.delete_outline),
                            ),
                            IconButtonM3E.tonal(
                              width: .wide,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LogScreen(log: logs[index].$2),
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
