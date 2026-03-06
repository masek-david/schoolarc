// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:schoolarc/utils/globals.dart';

// final firebaseLoginProvider =
//     AsyncNotifierProvider<FirebaseLoginNotifier, bool>(
//       FirebaseLoginNotifier.new,
//     );

// class FirebaseLoginNotifier extends AsyncNotifier<bool> {
//   @override
//   Future<bool> build() async {
//     return fireService.isloggedIn;
//   }

//   Future<void> logIn({required String email, required String password}) async {
//     state = const AsyncValue.loading();
//     try {
//       await fireService.logIn(email: email, password: password);
//       state = const AsyncValue.data(true);
//     } catch (e, st) {
//       state = AsyncValue.error(e, st);
//     }
//   }

//   Future<void> logOut() async {
//     state = const AsyncValue.loading();
//     try {
//       await fireService.logOut();
//       state = const AsyncValue.data(false);
//     } catch (e, st) {
//       state = AsyncValue.error(e, st);
//     }
//   }

//   Future<void> register({
//     required String email,
//     required String password,
//     required String nickname,
//   }) async {
//     state = const AsyncValue.loading();
//     try {
//       await fireService.createUser(
//         email: email,
//         password: password,
//         nickname: nickname,
//       );
//       state = const AsyncValue.data(true);
//     } catch (e, st) {
//       state = AsyncValue.error(e, st);
//     }
//   }
// }
