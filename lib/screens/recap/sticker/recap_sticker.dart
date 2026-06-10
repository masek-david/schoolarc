import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:schoolarc/m3e/buttons/button_m3e.dart';
import 'package:schoolarc/screens/recap/recap.dart';
import 'package:schoolarc/screens/recap/sticker/recap_sticker_26.dart';
import 'package:schoolarc/screens/settings/widgets/color_picker_action.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:share_plus/share_plus.dart';

/// 3.5 x 2 in  |  8.9 x 5.08 cm  |  336 x 192 px
class RecapSticker extends StatefulWidget {
  const RecapSticker({super.key, required this.recapData});

  final RecapData recapData;

  @override
  State<RecapSticker> createState() => _RecapStickerState();
}

class _RecapStickerState extends State<RecapSticker> {
  late int colorIndex = _getPresetColorIndexFromCurrentTheme();
  var stickerPaint = GlobalKey();
  late var recapData = widget.recapData;

  /// returns one of the [presetColors], which is the closest to the primary color of the current theme
  int _getPresetColorIndexFromCurrentTheme() {
    final themeHue = HSLColor.fromColor(context.col.primary).hue;

    var minDelta = double.infinity;
    var closestColorIndex = 0;

    for (int i = 0; i < presetColors.length; i++) {
      final color = presetColors[i];
      final delta = (HSLColor.fromColor(color).hue - themeHue).abs();
      if (delta < minDelta) {
        minDelta = delta;
        closestColorIndex = i;
      }
    }

    return closestColorIndex;
  }

  @override
  Widget build(BuildContext context) {
    if (recapData.needsMoreData) {
      return const Text('There is\'t enough data for the sticker.');
    }

    final stickerWidget = switch (recapData.year) {
      '2025-26' => RecapSticker26(
        recapData: recapData.copyWith(colorIndex: colorIndex),
      ),
      _ => const Text('Unsupported year'),
    };

    return Column(
      spacing: 16,
      children: [
        RepaintBoundary(key: stickerPaint, child: stickerWidget),
        ColorPickerAction(
          onChanged: (_, index) {
            setState(() {
              colorIndex = index;
            });
          },
          color: presetColors[colorIndex],
        ),
        ButtonM3E.tonal(
          size: .medium,
          onPressed: () async {
            final RenderRepaintBoundary boundary =
                stickerPaint.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final ui.Image image = await boundary.toImage(pixelRatio: 5.0);

            var byteData = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            var pngBytes = byteData!.buffer.asUint8List();
            SharePlus.instance.share(
              ShareParams(
                title: 'Sticker',
                previewThumbnail: XFile.fromData(
                  pngBytes,
                  mimeType: 'image/png',
                ),
                files: [
                  XFile.fromData(
                    pngBytes,
                    mimeType: 'image/png',
                    name: 'schoolarc_sticker2526.png',
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.share_rounded),
          child: Text(context.loc.share),
        ),
      ],
    );
  }
}
