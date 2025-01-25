import 'package:riverpod/riverpod.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/services/homeworks/hw_database.dart';

class HwNotifier extends StateNotifier<Map<int, Homework>>{
  final HomeworksDatabase _database;

  HwNotifier(this._database) : super(_database.getDatabase());



}

final hwNotifier =StateNotifierProvider<HwNotifier, Map<int, Homework>>((ref) {
  return HwNotifier(HomeworksDatabase());
});