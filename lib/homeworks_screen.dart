import 'package:flutter/material.dart';
import 'package:school_manager/homework_tile.dart';

class HomeworksScreen extends StatefulWidget {
  const HomeworksScreen({super.key});

  @override
  State<HomeworksScreen> createState() => _HomeworkSscreenState();
}

class _HomeworkSscreenState extends State<HomeworksScreen> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('this is homeworks screen!'),
        HomeworkTile(
          hwText: 'treba ps 15/3',
          hwDeadline: '13.5.',
          hwSubject: 'Cj',
        ),
        HomeworkTile(
          hwText: 'treba ps 15/3',
          hwDeadline: '13.5.',
          hwSubject: 'Cj',
        ),
      ],
    );
  }
}
