import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginStatusIcon extends ConsumerWidget {
  const LoginStatusIcon(
      {required this.provider, required this.showProvider, super.key});

  final AsyncNotifierProvider<AsyncNotifier<bool>, bool> provider;
  final NotifierProvider<Notifier<bool>, bool> showProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);
    final show = ref.watch(showProvider);

    if(!show){
      return const SizedBox.shrink();
    }

    return state.when(
      data: (value) => Icon(
        value ? Icons.check_circle : Icons.error,
        color: value ? Colors.green : Colors.yellow,
      ),
      error: (_, __) => const Icon(Icons.error, color: Colors.red),
      loading: () => const SizedBox(
        height: 28,
        width: 28,
        child: CircularProgressIndicator(strokeWidth: 3),
      ),
    );
  }
}
