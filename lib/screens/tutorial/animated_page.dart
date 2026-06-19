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
    this.overlayButton,
    this.vibrate = false,
  });

  final List<AnimatedItem> children;
  final EdgeInsetsGeometry padding;
  final double spacing;

  final Widget? overlayButton;

  final Duration duration;
  final Duration itemDelay;
  final bool vibrate;

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
    final animatedItems =
        widget.children.length + (widget.overlayButton == null ? 0 : 1);
    for (int i = 1; i < animatedItems; i++) {
      await Future.delayed(widget.itemDelay);
      if (mounted) {
        setState(() {
          if (widget.vibrate) {
            vibrate.light();
          }
          showing = i;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final curve = Curves.easeInOut;

    return Stack(
      children: [
        Padding(
          padding: widget.padding,
          child: ListView.builder(
            physics: const ClampingScrollPhysics(),
            itemCount: widget.children.length,
            itemBuilder: (context, index) {
              final item = widget.children[index];
              final isShown = showing >= index;
              final bottomSpacing =
                  widget.spacing +
                  (index == widget.children.length - 1 &&
                          widget.overlayButton != null
                      ? 120
                      : 0);

              if (item.transition) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: bottomSpacing,
                    top: item.spacing ?? 0,
                  ),
                  child: AnimatedOpacity(
                    duration: widget.duration,
                    curve: curve,
                    opacity: isShown ? 1 : 0,
                    child: item.builder(isShown),
                  ),
                );
              }
              return Padding(
                padding: EdgeInsets.only(bottom: bottomSpacing),
                child: item.builder(isShown),
              );
            },
          ),
        ),
        if (widget.overlayButton != null)
          Align(
            alignment: .bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IgnorePointer(
                ignoring: showing != widget.children.length,
                child: AnimatedOpacity(
                  opacity: showing == widget.children.length ? 1 : 0,
                  curve: curve,
                  duration: widget.duration,
                  child: widget.overlayButton,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
