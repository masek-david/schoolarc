import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/widgets/expressive_loading/wavy_border.dart';

class ExpressiveLoading extends StatefulWidget {
  const ExpressiveLoading({super.key});

  @override
  State<ExpressiveLoading> createState() => _ExpressiveLoadingState();
}

class _ExpressiveLoadingState extends State<ExpressiveLoading> {
  @override
  Widget build(BuildContext context) {
    return const WavyBorder();
    
    return Container(
      width: 52,
      height: 52,
      decoration: ShapeDecoration(
        shape: StarBorder(
          points: 9,
          innerRadiusRatio: 0.7,
          pointRounding: 0.5,
          valleyRounding: 0.5,
          side: BorderSide(color: context.col.primary, width: 8),
        ),
      ),
    );
  }
}
