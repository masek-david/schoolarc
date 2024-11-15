import 'package:flutter/material.dart';

class FabButton extends StatefulWidget {
  const FabButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final Future<void> Function() onTap;
  final IconData icon;

  @override
  State<FabButton> createState() => _FabButtonState();
}

class _FabButtonState extends State<FabButton> {
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
                setState(() {
                  isLoading = false;
                });
              },
            );
          },
          icon: Icon(widget.icon),
        ),
      ],
    );
  }
}
