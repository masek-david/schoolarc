import 'package:flutter/material.dart';
import 'package:schoolarc/utils/globals.dart';

class AnimatedItem {
  AnimatedItem({
    required this.builder,
    this.transition = true,
  });

  final Widget Function(bool isShown) builder;
  final bool transition;
}

class AnimatedPage extends StatefulWidget {
  const AnimatedPage({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.spacing = 0,
  });

  final List<AnimatedItem> children;
  final EdgeInsetsGeometry padding;
  final double spacing;

  @override
  State<AnimatedPage> createState() => _AnimatedPageState();
}

class _AnimatedPageState extends State<AnimatedPage> {
  final duration = const Duration(milliseconds: 800);
  final itemDelay = const Duration(milliseconds: 200);
  late final padding = widget.padding;

  int showing = -1;

  @override
  void initState() {
    super.initState();
    _show();
  }

  void _show() async {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        setState(() {
          showing = 0;
        });
      },
    );
    for (int i = 1; i < widget.children.length; i++) {
      await Future.delayed(itemDelay);
      if (mounted) {
        setState(() {
          vibrate.light();
          showing = i;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: ListView.builder(
        itemCount: widget.children.length,
        itemBuilder: (context, index) {
          final item = widget.children[index];
          final isShown = showing >= index;

          if (item.transition) {
            return Padding(
              padding: EdgeInsets.only(bottom: widget.spacing),
              child: AnimatedOpacity(
                duration: duration,
                curve: Curves.easeInOut,
                opacity: isShown ? 1 : 0,
                child: item.builder(isShown),
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.only(bottom: widget.spacing),
            child: item.builder(isShown),
          );
        },
      ),
    );
  }
}
