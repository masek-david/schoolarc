import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Used to bypass keyboard restriction on web, mainly on ios
class WebRequestFocus extends StatefulWidget {
  const WebRequestFocus({
    super.key,
    required this.child,
    required this.onPressed,
    this.offset = false,
  });

  final Widget child;
  final Future<void> Function() onPressed;

  /// offset for checkbox
  final bool offset;

  @override
  State<WebRequestFocus> createState() => _WebRequestFocusState();
}

class _WebRequestFocusState extends State<WebRequestFocus> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          right: widget.offset ? 50 : 0,
          child: Opacity(
            opacity: 0,
            child: TextField(
              focusNode: _focusNode,
              stylusHandwritingEnabled: false,
              enableInteractiveSelection: false,
              onTap: () async {
                await widget.onPressed();
                _focusNode.unfocus();
              },
            ),
          ),
        ),
      ],
    );
  }
}
