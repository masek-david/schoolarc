import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:schoolarc/utils/color_mapper.dart';

class ThemeColorsShowcase extends StatelessWidget {
  const ThemeColorsShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/book.svg',
              height: 150,
              colorMapper: PrimaryColorMapper(Theme.of(context)),
            ),
            SvgPicture.asset(
              'assets/pen.svg',
              height: 140,
              colorMapper: TertiaryColorMapper(Theme.of(context)),
            ),
          ],
        ),
      ),
    );
  }
}
