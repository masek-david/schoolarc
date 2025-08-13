import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/services/firebase/firebase_service.dart';

final firebaseLoginProvider =
    AsyncNotifierProvider<FirebaseLoginNotifier, bool>(
        FirebaseLoginNotifier.new);

class FirebaseLoginNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return ref.read(firebaseServiceProvider).isloggedIn;
  }

  Future<void> logIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      await ref
          .read(firebaseServiceProvider)
          .logIn(email: email, password: password);
      state = const AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logOut() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(firebaseServiceProvider).logOut();
      state = const AsyncValue.data(false);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref
          .read(firebaseServiceProvider)
          .createUser(email: email, password: password, username: username);
      state = const AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
