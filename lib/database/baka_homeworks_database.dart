import 'package:hive_ce/hive.dart';
import 'package:schoolarc/database/hive/hive_init.dart';

/// Database for storing bakalari id of seen and imported homeworks from Bakalari
class BakaHomeworksDatabase {
  final _addedBox = Hive.box(bakaAddedHw);
  final _seenBox = Hive.box(bakaSeenHw);

  bool isAdded(String id) {
    return _addedBox.values.contains(id);
  }

  bool isSeen(String id) {
    return _seenBox.values.contains(id);
  }

  Future<int> markAsAdded(String id) async {
    return await _addedBox.add(id);
  }

  Future<int> markAsSeen(String id) async {
    return await _seenBox.add(id);
  }

  void deleteAllFromDisk(){
    _seenBox.deleteFromDisk();
    _addedBox.deleteFromDisk();
  }
}
