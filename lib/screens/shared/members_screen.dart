import 'package:flutter/material.dart';
import 'package:schoolarc/models/group_models.dart';
import 'package:schoolarc/screens/shared/group_screen.dart';
import 'package:schoolarc/screens/shared/username_text.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/dialogs/empty_message.dart';
import 'package:schoolarc/widgets/dialogs/show_adaptive_dialog.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key, required this.members});

  final List<Member> members;

  @override
  Widget build(BuildContext context) {
    members.sort(
      (a, b) => (a.waitingForApproval == b.waitingForApproval
          ? 0
          : (a.waitingForApproval ? 1 : -1)),
    );
    final isOwner =
        members.where((element) => element.isOwner).firstOrNull?.id ==
            fireShareService.currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
      ),
      body: members.isEmpty
          ? const EmptyMessage(message: 'No members found')
          : ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final user = members[index];
                final firstWaiting = (user.waitingForApproval &&
                    (index == 0 || !members[index - 1].waitingForApproval));

                final tile = Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NicknameText(
                        user: user,
                        radius: 24,
                      ),
                      Row(
                        children: [
                          if (user.isYou)
                            const MenuItemButton(child: Text('You')),
                          if (user.isOwner)
                            const MenuItemButton(child: Text('Owner')),
                          if (user.waitingForApproval && isOwner)
                            IconButton(
                              icon: const Icon(Icons.person_add_outlined),
                              onPressed: () async {
                                try {
                                  await fireShareService.approveJoin(user.id);
                                  if (context.mounted) {
                                    showMessage(context, 'Approved');
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    showMessage(context, e.toString(),
                                        isError: true);
                                  }
                                }
                              },
                            ),
                          if (isOwner && !user.isOwner)
                            IconButton(
                              icon: const Icon(Icons.person_remove_outlined),
                              onPressed: () async {
                                showDialogAdaptive(
                                  context: context,
                                  title: Text('Remove ${user.name} ?'),
                                  actions: [
                                    adaptiveDialogButton(
                                      context: context,
                                      child: Text(context.loc.cancel),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    adaptiveDialogButton(
                                      context: context,
                                      child: const Text('Remove'),
                                      isDestructiveAction: true,
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        try {
                                          await fireShareService
                                              .removeFromGroup(user.id);
                                          if (context.mounted) {
                                            showMessage(context, 'Removed');
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            showMessage(context, e.toString(),
                                                isError: true);
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                        ],
                      )
                    ],
                  ),
                );

                if (firstWaiting) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(8, 24, 8, 4),
                        child: Text('Waiting for approval'),
                      ),
                      const Divider(),
                      tile,
                    ],
                  );
                }
                return tile;
              },
            ),
    );
  }
}
