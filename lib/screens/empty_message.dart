import 'package:flutter/widgets.dart';

class EmptyMessage extends StatelessWidget {
  const EmptyMessage({
    super.key,
    required this.message,
    required this.emoji,
  });

  final String message;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 160),
            ),
          ),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
