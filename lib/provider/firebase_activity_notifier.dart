import 'package:riverpod/riverpod.dart';

class Activity {
  Activity({this.adds = 0, this.modifies = 0, this.listenReads = 0});

  final int adds;
  final int modifies;
  final int listenReads;

  Activity add() => copyWith(adds: adds + 1);
  Activity modify() => copyWith(modifies: modifies + 1);
  Activity listenRead() => copyWith(listenReads: listenReads + 1);

  Activity copyWith({int? adds, int? modifies, int? listenReads}) {
    return Activity(
      adds: adds ?? this.adds,
      modifies: modifies ?? this.modifies,
      listenReads: listenReads ?? this.listenReads,
    );
  }
}

/// 0: subject, 1: homeworks, 2: exams
final firebaseActivityProvider =
    NotifierProvider<FirebaseActivityNotifier, Map<int, Activity>>(FirebaseActivityNotifier.new);

/// 0: subject, 1: homeworks, 2: exams
class FirebaseActivityNotifier extends Notifier<Map<int, Activity>> {
  @override
  Map<int, Activity> build() {
    return {0: Activity(), 1: Activity(), 2: Activity()};
  }

  void add(int i) {
    assert(i >= 0 && i <= 2);
    state = {...state, i: state[i]!.add()};
  }

  void modify(int i) {
    assert(i >= 0 && i <= 2);
    state = {...state, i: state[i]!.modify()};
  }

  void read(int i) {
    assert(i >= 0 && i <= 2);
    state = {...state, i: state[i]!.listenRead()};
  }
}
