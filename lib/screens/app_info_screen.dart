import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/settings/widgets/package_info.dart';
import 'package:schoolarc/services/firebase/app_info_notifier.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/widgets/expressive_loading/expressive_loading_indicator.dart';

class AppInfoScreen extends ConsumerWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(appInfoProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (ref.watch(debugModeProvider))
            IconButton(
              onPressed: () {
                ref.read(needsUpdateProvider.notifier).bypass();
              },
              icon: const Icon(Icons.close_rounded),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          crossAxisAlignment: .start,
          children: [
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  context.loc.sorry,
                  style: context.txt.displayMedium!.copyWith(
                    color: context.col.primary,
                  ),
                  textAlign: .start,
                ),
                Icon(
                  Icons.sentiment_very_dissatisfied_rounded,
                  size: 100,
                  color: context.col.tertiary,
                ),
              ],
            ),
            Text(
              context.loc.versionNotSupported,
              style: context.txt.titleMedium,
            ),
            Text(
              context.loc.pleaseUpdateApp,
              style: context.txt.titleMedium,
            ),
            if (data.isLoading) ExpressiveLoadingIndicator.big(),
            if (data.value?.messageForOldVersion != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.col.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  data.value!.messageForOldVersion!,
                  style: context.txt.titleMedium,
                ),
              ),
            const Spacer(),
            const PackageInfoWidget(enableTap: true),
          ],
        ),
      ),
    );
  }
}
