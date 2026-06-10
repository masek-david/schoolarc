import 'package:flutter/material.dart';
import 'package:schoolarc/screens/recap/recap.dart';
import 'package:schoolarc/screens/recap/sticker/recap_sticker_26.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class RecapStickerScreen extends StatelessWidget {
  const RecapStickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recapData = ModalRoute.of(context)!.settings.arguments;

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: .center,
        crossAxisAlignment: .center,
        children: [
          recapData is RecapData
              ? Center(child: RecapSticker26(recapData: recapData))
              : Text(context.loc.noData),
        ],
      ),
    );
  }
}
