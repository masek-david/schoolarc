import 'package:flutter/material.dart';
import 'package:schoolarc/utils/globals.dart';

class AnimatedItem {
  AnimatedItem({
    required this.builder,
    this.transition = true,
    this.spacing,
  });

  final Widget Function(bool isShown) builder;
  final bool transition;
  final double? spacing;
}

class AnimatedPage extends StatefulWidget {
  const AnimatedPage({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.spacing = 0,
    this.duration = const Duration(milliseconds: 800),
    this.itemDelay = const Duration(milliseconds: 200),
  });

  final List<AnimatedItem> children;
  final EdgeInsetsGeometry padding;
  final double spacing;

  final Duration duration;
  final Duration itemDelay;

  @override
  State<AnimatedPage> createState() => _AnimatedPageState();
}

class _AnimatedPageState extends State<AnimatedPage> {
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
      await Future.delayed(widget.itemDelay);
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
      padding: widget.padding,
      child: ListView.builder(
        physics: const ClampingScrollPhysics(),
        itemCount: widget.children.length,
        itemBuilder: (context, index) {
          final item = widget.children[index];
          final isShown = showing >= index;
    
          if (item.transition) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: widget.spacing,
                top: item.spacing ?? 0,
              ),
              child: AnimatedOpacity(
                duration: widget.duration,
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
