import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:schoolarc/utils/color_mapper.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class EmptyMessage extends StatelessWidget {
  const EmptyMessage({
    super.key,
    required this.message,
    this.asset = 'assets/book.svg',
  });

  final String message;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            SvgPicture.asset(
              asset,
              colorMapper: BasicColorMapper(
                context.col.primary.toARGB32(),
              ),
              height: 200,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
