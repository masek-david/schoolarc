import 'package:hive_ce/hive.dart';
import 'package:school_manager/hive/hive_init.dart';

class BakaHomeworksService {
  final _addedBox = Hive.box(bakaAddedHw);
  final _seenBox = Hive.box(bakaSeenHw);

  bool isAdded(String id) {
    return _addedBox.values.contains(id);
  }

  bool isSeen(String id) {
    return _seenBox.values.contains(id);
  }

  Future<int> addedHomework(String id) async {
    return await _addedBox.add(id);
  }

  Future<int> seenHomework(String id) async {
    return await _seenBox.add(id);
  }
}
