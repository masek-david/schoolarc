import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/services/firebase/firebase_service.dart';
import 'package:schoolarc/utils/globals.dart';

final firebaseNicknameProvider =
    AsyncNotifierProvider<FirebaseNicknameNotifier, String?>(
      FirebaseNicknameNotifier.new,
    );

class FirebaseNicknameNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    ref.listen(firebaseLoginProvider, (previous, next) => loadNickname());
    return _fetchNickname();
  }

  Future<void> loadNickname() async {
    state = const AsyncLoading();
    try {
      final name = await _fetchNickname();
      state = AsyncData(name);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  Future<String?> _fetchNickname() async {
    return fireService.getNickname();
  }

  Future<void> saveNickname(String newNickname) async {
    state = const AsyncLoading();

    state = const AsyncValue.loading();
    try {
      await fireService.saveNickname(newNickname);
      state = AsyncData(newNickname);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
