import 'package:flutter/material.dart';

/// used in calendar views for dividing exams and homeworks
class TextSeparator extends StatelessWidget {
  const TextSeparator({super.key, this.text = '', this.greydOut = false});

  final String text;
  final bool greydOut;

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).colorScheme.onSurface;

    if(greydOut){
      color = color.withAlpha(80);
    }
    
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 0),
      child: Text(text, style: TextStyle(fontSize: 16, color: color),),
    );
  }
}
