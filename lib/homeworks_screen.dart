import 'package:flutter/material.dart';
import 'package:school_manager/homework_tile.dart';

class HomeworksScreen extends StatefulWidget {
  const HomeworksScreen({super.key});

  @override
  State<HomeworksScreen> createState() => _HomeworkSscreenState();
}

class _HomeworkSscreenState extends State<HomeworksScreen> {
  List hwList = [
    ["Cj", "ps 12/5", "14.5."],
    ["Ma", "uc 23/34", "13.5."],
    ["Ma", "uc 23/34", "13.5."],
  ];

  void createNewHW() {

  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: hwList.length,
        itemBuilder: (context, index) {
          return HomeworkTile(
              hwText: hwList[index][1],
              hwDeadline: hwList[index][2],
              hwSubject: hwList[index][0]);
        });
  }
}
