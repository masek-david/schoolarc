import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:schoolarc/utils/color_mapper.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class ThemeColorsShowcase extends StatelessWidget {
  const ThemeColorsShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxWidth / 3 - 16;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/book.svg',
                  height: height,
                  colorMapper: BasicColorMapper(
                    context.col.primary.toARGB32(),
                  ),
                ),
                SvgPicture.asset(
                  'assets/confetti.svg',
                  height: height,
                  colorMapper: BasicColorMapper(
                    context.col.secondary.toARGB32(),
                  ),
                ),
                SvgPicture.asset(
                  'assets/pen.svg',
                  height: height,
                  colorMapper: BasicColorMapper(
                    context.col.tertiary.toARGB32(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
