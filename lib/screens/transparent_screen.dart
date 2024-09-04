import 'package:flutter/material.dart';

class TransparentScreen extends StatelessWidget {
  const TransparentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // return Text('hope this is transparent');
    return Scaffold(backgroundColor: const Color.fromARGB(0, 45, 12, 230), appBar: AppBar(),);
  }
}