import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/widgets/expressive_loading/expressive_loading_indicator.dart';

class LoadingIconButtonWithFuture extends StatefulWidget {
  const LoadingIconButtonWithFuture({
    super.key,
    this.icon = Icons.refresh,
    required this.onPressed,
  });

  final Future<void> Function() onPressed;
  final IconData icon;

  @override
  State<LoadingIconButtonWithFuture> createState() =>
      _LoadingIconButtonWithFutureState();
}

class _LoadingIconButtonWithFutureState
    extends State<LoadingIconButtonWithFuture> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return LoadingIconButton(
      icon: widget.icon,
      onPressed: () {
        setState(() {
          isLoading = true;
        });

        widget.onPressed().then(
          (value) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          },
        );
      },
      isLoading: isLoading,
    );
  }
}

class LoadingIconButton extends StatelessWidget {
  const LoadingIconButton({
    super.key,
    this.icon = Icons.refresh,
    required this.onPressed,
    required this.isLoading,
  });

  final void Function() onPressed;
  final IconData icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        if (isLoading)
          ExpressiveLoadingIndicator(
            color: context.col.secondaryContainer,
            size: 48,
          ),
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
        ),
      ],
    );
  }
}
