import 'package:flutter/material.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:schoolarc/m3e/expressive_loading/expressive_loading_indicator.dart';
import 'package:schoolarc/m3e/expressive_loading/linear_wavy_progress_indicator.dart';
import 'package:schoolarc/widgets/buttons/loading_icon_button.dart';

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
            const M3EContainedLoadingIndicator(
              padding: EdgeInsets.all(0),
            ),
            const M3ELoadingIndicator(),
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
        M3ELinearWavyProgressIndicator(
          value: value,
          width: double.infinity,
        ),
        LinearWavyProgressIndicator(value: value),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            Text(value.toStringAsPrecision(3)),
            M3ECircularProgressIndicator(value: value),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: M3ECircularProgressIndicator(
                // thickness: 14,
                // gapSize: 10,
                // wavelength: 50,
                // size: 24,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
