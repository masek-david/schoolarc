import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/provider/firebase_activity_notifier.dart';

final _opacityProvider = StateProvider<double>((ref) => 0.0);

class FirebaseOverlay extends ConsumerWidget {
  const FirebaseOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = ref.watch(firebaseActivityProvider);

    // Listen to changes on firebaseActivityProvider and update opacity accordingly.
    ref.listen<Map<int, Activity>>(firebaseActivityProvider, (previous, next) {
      // Immediately set the opacity to 1 (fully visible)
      ref.read(_opacityProvider.notifier).state = 1.0;
      // After 2 seconds, set the opacity back to 0 (fade out)
      // Future.delayed(const Duration(seconds: 5), () {
      //   // Make sure to update the provider even if the widget has rebuilt.
      //   ref.read(_opacityProvider.notifier).state = 0.0;
      // });
    });

    return IgnorePointer(
      child: DefaultTextStyle(
        style: TextStyle(),
        child: AnimatedOpacity(
          duration: Durations.extralong1,
          opacity: ref.watch(_opacityProvider),
          child: Container(
            color: const Color.fromARGB(200, 0, 0, 0),
            height: 100,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  Column(
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
                      Text('Subjects'),
                      Text(activity[0]!.adds.toString()),
                      Text(activity[0]!.modifies.toString()),
                      Text(activity[0]!.listenReads.toString()),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Homeworks'),
                      Text(activity[1]!.adds.toString()),
                      Text(activity[1]!.modifies.toString()),
                      Text(activity[1]!.listenReads.toString()),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Exams'),
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
    );
  }
}
