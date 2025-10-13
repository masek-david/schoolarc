import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/services/firebase/firebase_group_service.dart';

class GroupNotifier extends AsyncNotifier<String?> {
  final _service = FirebaseGroupService();

  @override
  Future<String?> build() async {
    return _service.getGroupId();
  }
}

class GroupNameNotifier extends AsyncNotifier<String?> {
  @override
  FutureOr<String?> build() {
    // TODO: implement build
    throw UnimplementedError();
  }
}