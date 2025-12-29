import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Used to bypass keyboard restriction on web, mainly on ios
class WebRequestFocusBuilder extends StatefulWidget {
  const WebRequestFocusBuilder({super.key, required this.builder});

  /// showKeyboard requests focus and opens keyboard, but there
  /// needs to be a new textfield to pass the focus on
  ///
  /// showKeyboard has effect only on web
  final Widget Function(void Function() showKeyboard) builder;

  @override
  State<WebRequestFocusBuilder> createState() => _WebRequestFocusBuilderState();
}

class _WebRequestFocusBuilderState extends State<WebRequestFocusBuilder> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void rejectFocus() {
    if (_focusNode.hasFocus) {
      _focusNode.canRequestFocus = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return widget.builder(
        () {},
      );
    }

    return Stack(
      children: [
        widget.builder(
          () {
            _focusNode.removeListener(rejectFocus);
            _focusNode.canRequestFocus = true;
            _focusNode.requestFocus();
            _focusNode.addListener(rejectFocus);
          },
        ),
        SizedBox.shrink(
          child: TextField(
            focusNode: _focusNode,
            stylusHandwritingEnabled: false,
            enableInteractiveSelection: false,
          ),
        ),
      ],
    );
  }
}
