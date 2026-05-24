import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:schoolarc/m3e/buttons/button_m3e.dart';
import 'package:schoolarc/screens/recap/recap_screen.dart';
import 'package:schoolarc/screens/recap/recap_sticker_26.dart';
import 'package:schoolarc/screens/settings/widgets/color_picker_action.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:share_plus/share_plus.dart';

/// 3.5 x 2 in  |  8.9 x 5.08 cm  |  336 x 192 px
class RecapSticker extends StatefulWidget {
  const RecapSticker({super.key, required this.recapData});

  final RecapData recapData;

  @override
  State<RecapSticker> createState() => _RecapStickerState();
}

class _RecapStickerState extends State<RecapSticker> {
  late Color color = context.col.primary;
  var scr = GlobalKey();

  @override
  Widget build(BuildContext context) {
    bool enoughData = true;
    // TODO catch all data
    if (widget.recapData.subjects.length < 3) {
      enoughData = false;
    }

    if (!enoughData) return const SizedBox.shrink();

    return Column(
      spacing: 16,
      children: [
        RepaintBoundary(
          key: scr,
          child: Theme(
            data: ThemeData.from(
              colorScheme: ColorScheme.fromSeed(seedColor: color),
            ),
            child: RecapSticker26(recapData: widget.recapData),
          ),
        ),
        ColorPickerAction(
          onChanged: (newColor) {
            setState(() {
              color = newColor;
            });
          },
          color: color,
        ),
        ButtonM3E.filled(
          onPressed: () async {
            final RenderRepaintBoundary boundary =
                scr.currentContext!.findRenderObject()!
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
          child: Text(context.loc.share),
        ),
      ],
    );
  }
}
