import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:schoolarc/m3e/expressive_loading/expressive_loading_indicator.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/widgets/tiles/error_tile.dart';

class LoginStatusIcon extends ConsumerWidget {
  const LoginStatusIcon({
    required this.provider,
    required this.showProvider,
    super.key,
  });

  final ProviderListenable<AsyncValue<bool>> provider;
  final ProviderListenable<bool> showProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);
    final show = ref.watch(showProvider);

    if (!show) {
      return const SizedBox.shrink();
    }

    return state.when(
      data: (value) => value
          ? const Icon(Icons.check_circle_rounded, color: Colors.green)
          : const FilledIcon(Icons.logout_rounded, color: Colors.yellow),
      error: (e, _) {
        final info = ErrorInfoUI.fromError(
          context,
          e,
          seriousForeground: Colors.red,
        );

        return FilledIcon(info.icon, color: info.foregroundColor);
      },
      loading: () => const ExpressiveLoadingIndicator(size: 24),
    );
  }
}

class FilledIcon extends StatelessWidget {
  const FilledIcon(
    this.icon, {
    super.key,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.circle_rounded,
          color: color,
        ),
        // to set the weight of the icon
        Text(
          String.fromCharCode(icon.codePoint),
          style: TextStyle(
            inherit: false,
            color: context.col.surface,
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
            fontFamily: icon.fontFamily,
          ),
        ),
      ],
    );
  }
}
