import 'package:flutter/material.dart';
import 'package:schoolarc/widgets/expressive_loading/circular_wavy_progress_indicator.dart';
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
        Slider(
          value: value,
          onChanged: (value) {
            setState(() {
              this.value = value;
            });
          },
        ),
        LinearWavyProgressIndicator(value: value),
        // CircularWavyProgressIndicator(
        //   value: value,
        //   // amplitude: 4,
        //   // strokeWidth: 20,
        //   // wavelength: 41.2,
        //   size: 264,
        // ),
        // Container(
        //   height: 50,
        //   decoration: ShapeDecoration(
        //     color: Colors.amber,
        //     shape: ShapeBorder.lerp(
        //       RoundedPolygonBorder(polygon: MaterialShapes.arch),
        //       RoundedPolygonBorder(
        //         polygon: MaterialShapes.cookie12,
        //       ),
        //       (value * 2) - 0.5,
        //     )!,
        //   ),
        // ),
        CircularWavyProgressIndicator(
          value: value,
          // amplitude: 4,
          strokeWidth: 8,
          // wavelength: 18.1,
          // size: 100,
        ),
        const CircularWavyLoadingIndicator(),
        // Text(value.toString()),
        // LoadingIconButton(icon: Icons.refresh, onTap: () {}, isLoading: true),
      ],
    );
  }
}
