import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/m3e/expressive_loading/expressive_refresh_indicator.dart';
import 'package:schoolarc/models/group_models.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/models/task_model.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/screens/shared/join_group_dialog.dart';
import 'package:schoolarc/screens/shared/members_screen.dart';
import 'package:schoolarc/screens/shared/nickname_text.dart';
import 'package:schoolarc/screens/shared/shared_add_bottom_sheet.dart';
import 'package:schoolarc/services/firebase/firebase_group_service.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/buttons/loading_icon_button.dart';
import 'package:schoolarc/widgets/dialogs/empty_message.dart';
import 'package:schoolarc/widgets/dialogs/show_my_dialog.dart';
import 'package:schoolarc/widgets/tiles/exam_tile.dart';
import 'package:schoolarc/widgets/tiles/hw_tile.dart';

class GroupScreen extends ConsumerStatefulWidget {
  const GroupScreen({super.key});

  @override
  ConsumerState<GroupScreen> createState() => _GroupScreenState();
}

final fireShareService = FirebaseGroupService();

class _GroupScreenState extends ConsumerState<GroupScreen> {
  Group? group;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    try {
      await fireShareService.getGroup().then(
        (value) {
          setState(() {
            group = value;
          });
        },
        onError: (e) {
          if (mounted) {
            showErrorMessage(context, e);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        showErrorMessage(context, e);
      }
    }
    return;
  }

  void showSheet(Task task, Member member) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SharedAddBottomSheet(
          task: task,
          member: member,
          isHomework: task.runtimeType == Homework,
          subjects: ref.read(subjectsSortedProvider),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = group?.tasks;
    tasks?.sort((a, b) {
      int result = a.member.id.compareTo(b.member.id);
      if (result != 0) return result;

      result = (a is GroupHomework ? 1 : 0).compareTo(
        b is GroupHomework ? 1 : 0,
      );
      if (result != 0) return result;

      return a.date.compareTo(b.date);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(group?.groupName ?? context.loc.loading),
        actions: [
          if (needsRefreshButton())
            LoadingIconButtonWithFuture(onPressed: refresh),
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: const Text('View members'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MembersScreen(members: group?.members ?? []),
                      ),
                    );
                  },
                ),
                PopupMenuItem(
                  child: const Text('Join group'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => JoinGroupDialog(
                        title: 'Paste the code of the group:',
                        confirmText: 'Join',
                        onConfirm: (id) async {
                          if (id == '') return;
                          try {
                            await fireShareService.joinGroup(id);
                            if (context.mounted) {
                              showMessage(
                                context,
                                'Wait for the group owner to approve',
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showErrorMessage(context, e);
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
                PopupMenuItem(
                  child: const Text('Leave group'),
                  onTap: () {
                    showMyDialog(
                      context: context,
                      title: 'Leave the group?',
                      actions: [
                        DialogActionButton(
                          text: context.loc.cancel,
                          onPressed: () => Navigator.pop(context),
                        ),
                        DialogActionButton(
                          text: 'Leave',
                          isDestructiveAction: true,
                          onPressed: () async {
                            Navigator.pop(context);
                            try {
                              await fireShareService.leaveGroup();
                              if (context.mounted) {
                                showMessage(context, 'Left the group');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                showErrorMessage(context, e);
                              }
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
                PopupMenuItem(
                  child: const Text('Invite to group'),
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(text: group?.groupId ?? ''),
                    );
                    if (context.mounted) {
                      showMessage(
                        context,
                        'Share the copied code with friends',
                        duration: const Duration(seconds: 10),
                      );
                    }
                  },
                ),
                PopupMenuItem(
                  child: const Text('Create new group'),
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (_) => JoinGroupDialog(
                        title: 'Create the name for the group',
                        confirmText: 'Create',
                        onConfirm: (name) async {
                          try {
                            await fireShareService.createGroup(name: name);
                            if (context.mounted) {
                              showMessage(context, 'Created new group');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showErrorMessage(context, e);
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
                PopupMenuItem(
                  child: const Text('Change group name'),
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (_) => JoinGroupDialog(
                        title: 'Change the name of the group',
                        confirmText: 'Change',
                        onConfirm: (name) async {
                          try {
                            await fireShareService.changeGroupName(name: name);
                            if (context.mounted) {
                              showMessage(context, 'Changed the group\'s name');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showErrorMessage(context, e);
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
                PopupMenuItem(
                  child: const Text('Delete your group'),
                  onTap: () {
                    showMyDialog(
                      context: context,
                      title: 'Delete your group?',
                      content: const Text('This action is irreversible'),
                      actions: [
                        DialogActionButton(
                          text: context.loc.cancel,
                          onPressed: () => Navigator.pop(context),
                        ),
                        DialogActionButton(
                          text: 'Delete',
                          isDestructiveAction: true,
                          onPressed: () async {
                            Navigator.pop(context);
                            try {
                              await fireShareService.deleteGroup();
                              if (context.mounted) {
                                showMessage(context, 'Group deleted');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                showErrorMessage(context, e);
                              }
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
              ];
            },
          ),
        ],
      ),
      body: ExpressiveRefreshIndicator(
        onRefresh: refresh,
        child: group == null
            ? const SingleChildScrollView(
                child: EmptyMessage(message: 'no group'),
              )
            : ListView.builder(
                itemCount: group!.tasks.length,
                itemBuilder: (context, index) {
                  final task = group!.tasks[index];
                  final member = task.member;
                  final isFirstFromMember =
                      index == 0 || tasks![index - 1].member.id != member.id;
                  late final Widget tile;

                  if (task is GroupHomework) {
                    tile = Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: HwTile(
                        hw: task.toHomework(),
                        onChangedCompletion: null,
                        showBorderIfMissed: false,
                        onDelete: null,
                        onEdit: () => showSheet(task, member),
                        onConvert: null,
                      ),
                    );
                  } else {
                    task as GroupExam;
                    tile = Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ExamTile(
                        exam: task.toExam(),
                        onDelete: null,
                        onEdit: () => showSheet(task, member),
                        onConvert: null,
                      ),
                    );
                  }
                  if (isFirstFromMember) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 16, 12, 4),
                          child: NicknameText(user: member),
                        ),
                        tile,
                      ],
                    );
                  }
                  return tile;
                },
              ),
      ),
    );
  }
}
