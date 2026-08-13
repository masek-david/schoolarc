import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:schoolarc/provider/firebase/firebase_activity_notifier.dart';

final _opacityProvider = NotifierProvider<_Opacity, bool>(_Opacity.new);

class _Opacity extends Notifier<bool> {
  @override
  build() {
    return false;
  }

  void show() {
    state = true;
  }

  void hide() {
    state = false;
  }
}

class FirebaseOverlay extends ConsumerWidget {
  const FirebaseOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = ref.watch(firebaseActivityProvider);

    // Listen to changes on firebaseActivityProvider and update opacity accordingly.
    ref.listen<Map<int, Activity>>(firebaseActivityProvider, (previous, next) {
      // Immediately set the opacity to true
      ref.read(_opacityProvider.notifier).show();
      // After 2 seconds, set the opacity back to false (fade out)
      Future.delayed(const Duration(seconds: 5), () {
        // Make sure to update the provider even if the widget has rebuilt.
        ref.read(_opacityProvider.notifier).hide();
      });
    });

    return Stack(
      alignment: Alignment.topRight,
      children: [
        IgnorePointer(
          child: DefaultTextStyle(
            style: const TextStyle(),
            child: AnimatedOpacity(
              duration: Durations.long2,
              opacity: ref.watch(_opacityProvider) == true ? 1 : 0,
              child: Container(
                color: const Color.fromARGB(170, 0, 0, 0),
                height: 100,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 16,
                    children: [
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(''),
                          Text('Adds:'),
                          Text('Modifies:'),
                          Text('Reads:'),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('Subjects'),
                          Text(activity[0]!.adds.toString()),
                          Text(activity[0]!.modifies.toString()),
                          Text(activity[0]!.listenReads.toString()),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('Homeworks'),
                          Text(activity[1]!.adds.toString()),
                          Text(activity[1]!.modifies.toString()),
                          Text(activity[1]!.listenReads.toString()),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('Exams'),
                          Text(activity[2]!.adds.toString()),
                          Text(activity[2]!.modifies.toString()),
                          Text(activity[2]!.listenReads.toString()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        M3EIconButton(
          onPressed: () {
            if (ref.read(_opacityProvider)) {
              ref.read(_opacityProvider.notifier).hide();
            } else {
              ref.read(_opacityProvider.notifier).show();
            }
          },
          icon: const Icon(Icons.hide_source_rounded),
        ),
      ],
    );
  }
}
