import 'package:flutter/material.dart';

class LoadingIconButtonWithFuture extends StatefulWidget {
  const LoadingIconButtonWithFuture({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final Future<void> Function() onTap;
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
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        if (isLoading) const CircularProgressIndicator(),
        IconButton(
          onPressed: () {
            setState(() {
              isLoading = true;
            });

            widget.onTap().then(
              (value) {
                if (mounted) {
                  setState(() {
                    isLoading = false;
                  });
                }
              },
            );
          },
          icon: Icon(widget.icon),
        ),
      ],
    );
  }
}

class LoadingIconButton extends StatelessWidget {
  const LoadingIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.isLoading,
  });

  final void Function() onTap;
  final IconData icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        if (isLoading) const CircularProgressIndicator(),
        IconButton(
          onPressed: onTap,
          icon: Icon(icon),
        ),
      ],
    );
  }
}
