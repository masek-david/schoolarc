import 'package:flutter/material.dart';

class SliderAction extends StatefulWidget {
  const SliderAction({
    super.key,
    required this.inititalValue,
    this.min = 0.0,
    this.max = 0.0,
    this.divisions,
    required this.onChanged,
  });

  final double inititalValue;
  final Function(double value) onChanged;
  final double min;
  final double max;
  final int? divisions;

  @override
  State<SliderAction> createState() => _SliderActionState();
}

class _SliderActionState extends State<SliderAction> {
  late double sliderValue = widget.inititalValue;

  @override
  Widget build(BuildContext context) {
    return Slider(
      min: widget.min,
      max: widget.max,
      divisions: widget.divisions,
      label: sliderValue.round().toString(),
      value: sliderValue,
      onChanged: (value) {
        setState(() {
          widget.onChanged(value);
          sliderValue = value;
        });
      },
    );
  }
}
