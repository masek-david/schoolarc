import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:school_manager/homework_tile.dart';

class HomeworksScreen extends StatefulWidget {
  HomeworksScreen({
    super.key,
    required this.hwList,
  });

  List hwList;

  // List hwList = [
  //   ["Cj", "ps 12/5", "14.5.", false],
  //   ["Ma", "uc 23/34", "13.5.", false],
  //   ["Ma", "uc 23/34", "13.5.", false],
  // ];

  void createNewHW() {}

  @override
  State<HomeworksScreen> createState() => _HomeworkSscreenState();
}

class _HomeworkSscreenState extends State<HomeworksScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.hwList.length,
        itemBuilder: (context, index) {
          return HomeworkTile(
            hwText: widget.hwList[index][1],
            hwDeadline: widget.hwList[index][2],
            hwSubject: widget.hwList[index][0],
            completion: widget.hwList[index][3],
          );
        });
  }
}
