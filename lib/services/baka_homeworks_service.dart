import 'package:hive/hive.dart';

class BakaHomeworksService {
  final _addedBox = Hive.box('bakaAddedHw');
  final _seenBox = Hive.box('bakaSeenHw');

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
