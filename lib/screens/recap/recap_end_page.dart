import 'package:flutter/material.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/m3e/buttons/button_m3e.dart';
import 'package:schoolarc/m3e/m3e_parameters.dart';
import 'package:schoolarc/screens/recap/recap_screen.dart';
import 'package:schoolarc/screens/recap/recap_sticker.dart';
import 'package:schoolarc/screens/tutorial/animated_page.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/fonts.dart';
import 'package:schoolarc/utils/globals.dart';

class RecapEndPage extends StatelessWidget {
  const RecapEndPage({super.key, required this.recapData});

  final RecapData recapData;

  @override
  Widget build(BuildContext context) {
    final curve = SpatialMotion.fast.curve;

    return AnimatedPage(
      duration: const Duration(milliseconds: 800),
      itemDelay: const Duration(milliseconds: 800),
      children: [
        AnimatedItem(
          spacing: 150,
          builder: (isShown) {
            return AnimatedDefaultTextStyle(
              style: googleSansFlex(
                size: 52,
                width: isShown ? 40 : 150,
                roundness: 100,
                weight: isShown ? 500 : 1000,
                color: context.col.onSurface,
              ),
              curve: SpatialMotion.fast.curve,
              duration: const Duration(milliseconds: 800),
              child: const Text('That\'s it for this year.'),
            );
          },
        ),
        AnimatedItem(
          builder: (isShown) {
            return AnimatedDefaultTextStyle(
              style: googleSansFlex(
                size: 40,
                width: isShown ? 40 : 120,
                roundness: 100,
                weight: isShown ? 300 : 500,
                color: context.col.onSurfaceVariant,
              ),
              curve: curve,
              duration: const Duration(milliseconds: 800),
              child: const Text(
                'Enjoy your summer break!',
              ),
            );
          },
        ),
        AnimatedItem(
          spacing: 32,
          builder: (isShown) {
            return Align(
              child: RecapSticker(recapData: recapData),
            );
          },
        ),
        AnimatedItem(
          spacing: 72,
          builder: (isShown) {
            return Align(
              child: ButtonM3E.filled(
                size: .large,
                onPressed: () {
                  settings.save(
                    Setting.recapShownForYear,
                    DateTime.now().year,
                  );
                  Navigator.pop(context);
                },
                icon: const Text('🏄'),
                child: const Text('Exit'),
              ),
            );
          },
        ),
      ],
    );
  }
}
