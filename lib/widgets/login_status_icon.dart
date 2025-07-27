import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/utils/extensions/color_extension.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class LoginStatusIcon extends ConsumerWidget {
  const LoginStatusIcon(
      {required this.provider, required this.showProvider, super.key});

  final AsyncNotifierProvider<AsyncNotifier<bool>, bool> provider;
  final NotifierProvider<Notifier<bool>, bool> showProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);
    final show = ref.watch(showProvider);

    if (!show) {
      return const SizedBox.shrink();
    }

    return Transform.scale(
      scale: 1,
      child: state.when(
        data: (value) => value
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const LoggedOutIcon(),
        error: (_, __) => const Icon(Icons.error, color: Colors.red),
        loading: () => const SizedBox(
          height: 28,
          width: 28,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
    );
  }
}

class LoggedOutIcon extends StatelessWidget {
  const LoggedOutIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.circle,
          color: Theme.brightnessOf(context) == Brightness.dark
              ? Colors.yellow
              : Colors.yellow.darken(0.2),
        ),
        // to set the weight of the icon
        Text(
          String.fromCharCode(Icons.logout.codePoint),
          style: TextStyle(
            inherit: false,
            color: context.col.surface,
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            fontFamily: Icons.logout.fontFamily,
          ),
        )
      ],
    );
  }
}
