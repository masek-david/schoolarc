import 'package:flutter/material.dart';

class LoadingIconButton extends StatefulWidget {
  const LoadingIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isLoading,
  });

  final Future<void> Function() onTap;
  final IconData icon;
  final bool? isLoading;

  @override
  State<LoadingIconButton> createState() => _LoadingIconButtonState();
}

class _LoadingIconButtonState extends State<LoadingIconButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        if (isLoading || widget.isLoading == true)
          const CircularProgressIndicator.adaptive(),
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
