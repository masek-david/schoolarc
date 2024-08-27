import 'package:flutter/material.dart';

Widget buildDialog(BuildContext context){
    return Dialog(child: Padding(
      padding: const EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Upcoming feature', style: TextStyle(fontSize: 24),),
          const SizedBox(height: 10),
          const Text('Upcoming feature, to edit homework or exam now head to Homeworks or Exams tab'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: Navigator.of(context).pop, child: const Text('Close')),
            ],
          )
        ],
      ),
    ),);
  }