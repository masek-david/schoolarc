import 'package:flutter/material.dart';
import 'package:schoolarc/widgets/buttons/loading_icon_button.dart';
import 'package:schoolarc/widgets/expressive_loading/circular_wavy_progress_indicator.dart';
import 'package:schoolarc/widgets/expressive_loading/expressive_loading_indicator.dart';
import 'package:schoolarc/widgets/expressive_loading/linear_wavy_progress_indicator.dart';

class LoadingTest extends StatefulWidget {
  const LoadingTest({super.key});

  @override
  State<LoadingTest> createState() => _LoadingTestState();
}

class _LoadingTestState extends State<LoadingTest> {
  double value = 0.5;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            ExpressiveLoadingIndicator(progress: value),
            const ExpressiveLoadingIndicator(),
            LoadingIconButton(onPressed: () {}, isLoading: true),
          ],
        ),
        Slider(
          value: value,
          onChanged: (value) {
            setState(() {
              this.value = value;
            });
          },
        ),
        LinearWavyProgressIndicator(value: value),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            Text(value.toStringAsPrecision(3)),
            CircularWavyProgressIndicator(value: value),
            const CircularWavyLoadingIndicator(),
          ],
        ),
      ],
    );
  }
}
