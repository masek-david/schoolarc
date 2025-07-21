import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/services/firebase/firebase_service.dart';

class LoginState {
  final bool isLoading;
  final bool isLoggedIn;

  const LoginState({
    this.isLoading = false,
    this.isLoggedIn = false,
  });

  LoginState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

final firebaseLoginProvider =
    NotifierProvider<FirebaseLoginNotifier, LoginState>(
        FirebaseLoginNotifier.new);

class FirebaseLoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() {
    final isLoggedIn = ref.read(firebaseServiceProvider).isloggedIn;
    return LoginState(isLoggedIn: isLoggedIn);
  }

  Future<void> logIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true);
    try {
      await ref
          .read(firebaseServiceProvider)
          .logIn(email: email, password: password);
      state = state.copyWith(isLoading: false, isLoggedIn: true);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> logOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(firebaseServiceProvider).logOut();
      state = state.copyWith(isLoading: false, isLoggedIn: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> register({required String email, required String password}) async {
    state = state.copyWith(isLoading: true);
    try {
      await ref
          .read(firebaseServiceProvider)
          .createUser(email: email, password: password);
      state = state.copyWith(isLoading: false, isLoggedIn: true);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}
