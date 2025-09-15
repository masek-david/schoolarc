import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/provider/firebase/firebase_login_notifier.dart';
import 'package:schoolarc/services/firebase/firebase_service.dart';

final firebaseUsernameProvider =
    AsyncNotifierProvider<FirebaseUsernameNotifier, String?>(
        FirebaseUsernameNotifier.new);

class FirebaseUsernameNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    ref.listen(
      firebaseLoginProvider,
      (previous, next) {
        loadUsername();
      },
    );
    return _fetchUsername();
  }

  Future<void> loadUsername() async {
    state = const AsyncLoading();
    try {
      final name = await _fetchUsername();
      state = AsyncData(name);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  Future<String?> _fetchUsername() async {
    return ref.read(firebaseServiceProvider).getUsername();
  }

  Future<void> saveUsername(String newUsername) async {
    state = const AsyncLoading();

    state = const AsyncValue.loading();
    try {
      await ref.read(firebaseServiceProvider).saveUsername(newUsername);
      state = AsyncData(newUsername);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
