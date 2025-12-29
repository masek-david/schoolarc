import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/bakalari/baka_hw_model.dart';
import 'package:schoolarc/provider/bakalari/baka_homeworks_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/bakalari/baka_homeworks/baka_hw_tile.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/ago_text.dart';
import 'package:schoolarc/widgets/buttons/loading_icon_button.dart';
import 'package:schoolarc/widgets/dialogs/empty_message.dart';
import 'package:schoolarc/widgets/expressive_loading/expressive_loading_indicator.dart';
import 'package:schoolarc/widgets/tiles/error_tile.dart';

class BakaHomeworksScreen extends ConsumerWidget {
  const BakaHomeworksScreen({super.key});

  void import(
    BuildContext context,
    BakaHomework hw,
    bool isHomework,
    WidgetRef ref,
  ) async {
    await ref.read(bakaHomeworksProvider.notifier).import(hw, isHomework);

    if (context.mounted) {
      Navigator.pop(context);
      final loc = context.loc;
      showMessage(context, isHomework ? loc.addedHomework : loc.addedExam);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bakaHw = ref.watch(bakaHomeworksProvider);
    final isLoading = bakaHw.isLoading;
    final error = bakaHw.error;
    final data = bakaHw.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.hwFromBaka),
        actions: [
          AgoText(stream: bakaHomeworksAgeProvider),
          LoadingIconButton(
            isLoading: isLoading,
            onPressed: ref.read(bakaHomeworksProvider.notifier).refresh,
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (isLoading) {
            return Center(
              child: MyExpressiveLoadingIndicator.big(
                useHaptics: ref.read(themeExpressiveHaptics),
              ),
            );
          }
          if (error != null) {
            return ErrorTile(
              error: error,
              actions: [
                IconButton(
                  onPressed: ref.read(bakaHomeworksProvider.notifier).refresh,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            );
          }
          if (data == null || data.isEmpty) {
            return EmptyMessage(
              asset: 'assets/confetti.svg',
              message: context.loc.noHomework,
            );
          }

          data.sort(
            (a, b) => a.alreadySeen != b.alreadySeen
                ? (a.alreadySeen ? 1 : -1)
                : a.date.compareTo(b.date),
          );

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final hw = data[index];
              final isFirstNew = !hw.alreadySeen && index == 0;
              final isLastNew =
                  index == data.length - 1 ||
                  !hw.alreadySeen &&
                      data.elementAtOrNull(index + 1)?.alreadySeen == true;

              final tile = BakaHwTile(
                hw: hw,
                onSave: (isHomework, hw) =>
                    import(context, hw, isHomework, ref),
              );

              bakaHwDb.markAsSeen(hw.bakaId);

              if (hw.alreadySeen) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: tile,
                );
              }

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(isFirstNew ? 16 : 0),
                    bottom: Radius.circular(isLastNew ? 16 : 0),
                  ),
                  color: context.col.surfaceContainerHighest,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 8, 8),
                  child: isFirstNew
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                context.loc.newHomework,
                                style: context.txt.titleMedium,
                              ),
                            ),
                            tile,
                          ],
                        )
                      : tile,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
