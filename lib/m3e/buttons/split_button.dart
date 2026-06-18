import 'package:flutter/material.dart';
import 'package:schoolarc/m3e/m3e_parameters.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class SplitButton extends StatefulWidget {
  const SplitButton({super.key, required this.size});

  final SplitButtonSize size;

  @override
  State<SplitButton> createState() => _SplitButtonState();
}

class _SplitButtonState extends State<SplitButton> {
  @override
  Widget build(BuildContext context) {
    final bg = context.col.primaryContainer;
    final fg = context.col.onPrimaryContainer;

    return Row(
      children: [
        Container(
          height: widget.size.height,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: .horizontal(
              left: Radius.circular(widget.size.height / 2),
              right: Radius.circular(widget.size.innerRadius),
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: widget.size.paddingLeft),
              Icon(
                Icons.edit,
                size: widget.size.iconSize,
              ),
              SizedBox(width: widget.size.iconSpacing),
              Text(
                'Edit',
                style: context.txt.labelLarge!.copyWith(
                  color: fg,
                  fontSize: widget.size.fontSize,
                ),
              ),
              SizedBox(width: widget.size.paddingRight),
            ],
          ),
        ),
        const SizedBox(width: 2),

        MenuAnchor(
          animated: true,
          menuChildren: const <Widget>[
            MenuItemButton(
              child: Text('label'),
            ),
            MenuItemButton(
              child: Text('label'),
            ),
            MenuItemButton(
              child: Text('label'),
            ),
          ],
          builder:
              (
                BuildContext context,
                MenuController controller,
                Widget? child,
              ) {
                return Container(
                  height: widget.size.height,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: .horizontal(
                      left: Radius.circular(widget.size.innerRadius),
                      right: Radius.circular(widget.size.height / 2),
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width:
                              widget.size.menuPadding -
                              widget.size.menuIconOffset,
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: widget.size.menuIconSize,
                        ),
                        SizedBox(
                          width:
                              widget.size.menuPadding +
                              widget.size.menuIconOffset,
                        ),
                      ],
                    ),
                  ),
                );
              },
        ),
      ],
    );
  }
}
